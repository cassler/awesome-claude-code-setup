#!/bin/bash

# NLP Helper Script - Text analysis using Python's built-in libraries
# Usage: ./nlp-helper.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    error_exit "Python 3 is required for NLP operations"
fi

case "$1" in
    "tokens"|"tokencount")
        # Estimate token count (rough approximation)
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')
if file_path == '/dev/stdin':
    text = sys.stdin.read()
else:
    with open(file_path, 'r') as f:
        text = f.read()

# Rough token estimation: ~4 chars per token
chars = len(text)
words = len(text.split())
tokens = chars // 4
print(f'Characters: {chars:,}')
print(f'Words: {words:,}')
print(f'Tokens (est): {tokens:,}')
EOF
        ;;
    
    "summary")
        # Extract first paragraph and headers
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import re
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')
if file_path == '/dev/stdin':
    text = sys.stdin.read()
else:
    with open(file_path, 'r') as f:
        text = f.read()

# Extract headers
headers = re.findall(r'^#+\s+(.+)$', text, re.MULTILINE)
if headers:
    print('Headers:', ', '.join(headers[:5]))
    
# First paragraph
paragraphs = [p.strip() for p in text.split('\n\n') if p.strip() and not p.strip().startswith('#')]
if paragraphs:
    first = paragraphs[0][:200] + '...' if len(paragraphs[0]) > 200 else paragraphs[0]
    print(f'\nFirst paragraph: {first}')
EOF
        ;;
    
    "keywords"|"frequency")
        # Word frequency analysis
        FILE="${2:-/dev/stdin}"
        TOP="${3:-10}"
        export FILE TOP
        python3 <<'EOF'
import re
import os
import sys
from collections import Counter

file_path = os.environ.get('FILE', '/dev/stdin')
top_n = int(os.environ.get('TOP', '10'))

if file_path == '/dev/stdin':
    text = sys.stdin.read().lower()
else:
    with open(file_path, 'r') as f:
        text = f.read().lower()

# Common stop words
stop_words = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
              'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'been',
              'be', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
              'could', 'should', 'may', 'might', 'must', 'can', 'this', 'that',
              'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they'}

# Extract words
words = re.findall(r'\b[a-z]+\b', text)
words = [w for w in words if len(w) > 2 and w not in stop_words]

# Count frequency
freq = Counter(words)
print(f'Top {top_n} keywords:')
for word, count in freq.most_common(top_n):
    print(f'  {word}: {count}')
EOF
        ;;
    
    "questions")
        # Extract questions
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import re
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')
if file_path == '/dev/stdin':
    text = sys.stdin.read()
else:
    with open(file_path, 'r') as f:
        text = f.read()

# Find sentences ending with ?
questions = re.findall(r'([^.!?\n]*\?)', text)
if questions:
    print('Questions found:')
    for i, q in enumerate(questions[:10], 1):
        print(f'  {i}. {q.strip()}')
    if len(questions) > 10:
        print(f'  ... and {len(questions) - 10} more')
else:
    print('No questions found')
EOF
        ;;
    
    "todos"|"fixmes")
        # Extract TODO/FIXME/HACK comments
        PATTERN="${2:-TODO|FIXME|HACK|XXX|NOTE|BUG|OPTIMIZE}"
        echo "Searching for: $PATTERN"
        echo ""
        if check_command rg; then
            rg -i "($PATTERN)[:|\s].*" --type-add 'code:*.{js,ts,py,go,rs,rb,java,c,cpp,h,hpp,sh}' -t code
        else
            grep -r -i -E "($PATTERN)[:|\s].*" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.sh" 2>/dev/null
        fi
        ;;
    
    "sentiment")
        # Basic sentiment analysis
        TEXT="${2:-}"
        if [ -z "$TEXT" ]; then
            error_exit "Usage: $0 sentiment \"text to analyze\""
        fi
        export TEXT
        python3 <<'EOF'
import os

text = os.environ.get('TEXT', '').lower()

# Positive and negative word lists
positive = {'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic',
            'love', 'best', 'happy', 'awesome', 'nice', 'super', 'perfect',
            'beautiful', 'brilliant', 'outstanding', 'positive', 'success'}
            
negative = {'bad', 'terrible', 'awful', 'horrible', 'hate', 'worst', 'sad',
            'angry', 'disappointed', 'frustrating', 'annoying', 'poor',
            'fail', 'failed', 'broken', 'wrong', 'error', 'problem', 'issue'}

# Count occurrences
pos_count = sum(1 for word in text.split() if word in positive)
neg_count = sum(1 for word in text.split() if word in negative)

# Determine sentiment
if pos_count > neg_count:
    print(f'😊 Positive (score: +{pos_count - neg_count})')
elif neg_count > pos_count:
    print(f'😞 Negative (score: -{neg_count - pos_count})')
else:
    print('😐 Neutral')
    
print(f'Positive words: {pos_count}, Negative words: {neg_count}')
EOF
        ;;
    
    "readability"|"complexity")
        # Estimate readability
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import re
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')
if file_path == '/dev/stdin':
    text = sys.stdin.read()
else:
    with open(file_path, 'r') as f:
        text = f.read()

# Count sentences, words, syllables
sentences = len(re.findall(r'[.!?]+', text)) or 1
words = len(text.split())
# Rough syllable count (count vowel groups)
syllables = len(re.findall(r'[aeiouAEIOU]+', text))

# Flesch Reading Ease approximation
if words > 0:
    avg_sentence_length = words / sentences
    avg_syllables_per_word = syllables / words
    score = 206.835 - 1.015 * avg_sentence_length - 84.6 * avg_syllables_per_word
    
    print(f'Words: {words}')
    print(f'Sentences: {sentences}')
    print(f'Avg words/sentence: {avg_sentence_length:.1f}')
    print(f'Flesch score: {score:.1f}')
    
    if score >= 90:
        print('Reading level: Very Easy (5th grade)')
    elif score >= 80:
        print('Reading level: Easy (6th grade)')
    elif score >= 70:
        print('Reading level: Fairly Easy (7th grade)')
    elif score >= 60:
        print('Reading level: Standard (8-9th grade)')
    elif score >= 50:
        print('Reading level: Fairly Difficult (10-12th grade)')
    elif score >= 30:
        print('Reading level: Difficult (College)')
    else:
        print('Reading level: Very Difficult (Graduate)')
EOF
        ;;
    
    "ngrams")
        # Extract n-grams
        N="${2:-2}"
        FILE="${3:-/dev/stdin}"
        export N FILE
        python3 <<'EOF'
import re
import os
import sys
from collections import Counter

n = int(os.environ.get('N', '2'))
file_path = os.environ.get('FILE', '/dev/stdin')

if file_path == '/dev/stdin':
    text = sys.stdin.read().lower()
else:
    with open(file_path, 'r') as f:
        text = f.read().lower()

# Extract words
words = re.findall(r'\b\w+\b', text)

# Generate n-grams
ngrams = [' '.join(words[i:i+n]) for i in range(len(words)-n+1)]

# Count frequency
freq = Counter(ngrams)
print(f'Top 10 {n}-grams:')
for ngram, count in freq.most_common(10):
    print(f'  {ngram}: {count}')
EOF
        ;;
    
    "entities"|"extract-names")
        # Simple named entity extraction
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import re
import os
import sys
from collections import Counter

file_path = os.environ.get('FILE', '/dev/stdin')
if file_path == '/dev/stdin':
    text = sys.stdin.read()
else:
    with open(file_path, 'r') as f:
        text = f.read()

# Find capitalized words (potential names)
# Exclude common words and single letters
entities = re.findall(r'\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b', text)
entities = [e for e in entities if len(e) > 1 and e not in 
           {'The', 'This', 'That', 'These', 'Those', 'A', 'An', 'In', 'On', 'At', 'To', 'For'}]

# Count occurrences
entity_counts = Counter(entities)

print('Potential entities:')
for entity, count in entity_counts.most_common(15):
    if count > 1:  # Only show repeated entities
        print(f'  {entity}: {count}')
EOF
        ;;
    
    "analyze-complexity")
        # Analyze code complexity
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import ast
import sys
import os

def calculate_complexity(node, complexity=1):
    '''Calculate cyclomatic complexity of an AST node'''
    # Add 1 for each decision point
    for child in ast.walk(node):
        if isinstance(child, (ast.If, ast.While, ast.For, ast.ExceptHandler)):
            complexity += 1
        elif isinstance(child, ast.BoolOp):
            complexity += len(child.values) - 1
    return complexity

file_path = os.environ.get('FILE', '/dev/stdin')

try:
    if file_path == '/dev/stdin':
        code = sys.stdin.read()
    else:
        with open(file_path, 'r') as f:
            code = f.read()
    
    tree = ast.parse(code)
    
    print('=== CODE COMPLEXITY ANALYSIS ===')
    
    # Count elements
    functions = [n for n in ast.walk(tree) if isinstance(n, ast.FunctionDef)]
    classes = [n for n in ast.walk(tree) if isinstance(n, ast.ClassDef)]
    
    print(f'Classes: {len(classes)}')
    print(f'Functions: {len(functions)}')
    print()
    
    # Analyze each function
    if functions:
        print('Function Complexity:')
        for func in functions:
            complexity = calculate_complexity(func)
            lines = len(func.body)
            params = len(func.args.args)
            
            # Determine complexity level
            if complexity > 10:
                level = '⚠️  HIGH'
            elif complexity > 5:
                level = '⚡ MEDIUM'
            else:
                level = '✅ LOW'
                
            print(f'  {func.name}():')
            print(f'    Cyclomatic complexity: {complexity} {level}')
            print(f'    Lines: {lines}, Parameters: {params}')
            
    # Overall metrics
    total_lines = len(code.splitlines())
    print(f'\nTotal lines: {total_lines}')
    
except SyntaxError as e:
    print(f'Error: Not valid Python code - {e}')
except Exception as e:
    print(f'Error analyzing file: {e}')
EOF
        ;;
    
    "security"|"security-scan")
        # Basic security pattern detection
        FILE="${2:-/dev/stdin}"
        echo "=== SECURITY SCAN ==="
        export FILE
        python3 <<'EOF'
import re
import ast
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')

try:
    if file_path == '/dev/stdin':
        code = sys.stdin.read()
    else:
        with open(file_path, 'r') as f:
            code = f.read()
    
    issues = []
    
    # Pattern-based detection
    patterns = {
        'Hardcoded Secret': [
            r'(?i)(api[_-]?key|secret|password|token)\s*=\s*["\'][^"\']+["\']',
            r'(?i)(AWS|AMAZON)_?(SECRET|ACCESS)_?KEY\s*=\s*["\'][^"\']+["\']',
        ],
        'SQL Injection Risk': [
            r'\.execute\([^)]*%[^)]*\)',
            r'\.execute\([^)]*\+[^)]*\)',
            r'f["\'].*SELECT.*{.*}.*FROM',
        ],
        'Command Injection': [
            r'os\.system\(',
            r'subprocess\.call\(.*shell=True',
            r'eval\([^)]*input\(',
        ],
        'Weak Crypto': [
            r'hashlib\.md5\(',
            r'hashlib\.sha1\(',
            r'random\.random\(\).*password',
        ],
        'Path Traversal': [
            r'open\([^)]*\+[^)]*\)',
            r'\.\./',
        ]
    }
    
    # Check each pattern
    for issue_type, pattern_list in patterns.items():
        for pattern in pattern_list:
            matches = re.findall(pattern, code, re.IGNORECASE)
            if matches:
                issues.append((issue_type, len(matches), matches[0][:50]))
    
    # AST-based detection for Python
    if file_path.endswith('.py') or file_path == '/dev/stdin':
        try:
            tree = ast.parse(code)
            
            # Check for eval/exec usage
            for node in ast.walk(tree):
                if isinstance(node, ast.Name) and node.id in ['eval', 'exec']:
                    issues.append(('Dangerous Function', 1, 'eval/exec usage'))
                    
        except:
            pass
    
    # Report findings
    if issues:
        print(f'Found {len(issues)} potential security issues:\n')
        for issue_type, count, example in issues:
            print(f'⚠️  {issue_type}: {count} occurrence(s)')
            print(f'   Example: {example}...')
            print()
    else:
        print('✅ No obvious security issues detected')
        
    print('\nNote: This is a basic scan. Use specialized tools for thorough analysis.')
    
except Exception as e:
    print(f'Error during security scan: {e}')
EOF
        ;;
    
    "imports"|"analyze-imports")
        # Analyze import dependencies
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import ast
import sys
import os
from collections import defaultdict

file_path = os.environ.get('FILE', '/dev/stdin')

try:
    if file_path == '/dev/stdin':
        code = sys.stdin.read()
    else:
        with open(file_path, 'r') as f:
            code = f.read()
    
    tree = ast.parse(code)
    
    print('=== IMPORT ANALYSIS ===')
    
    stdlib_modules = {
        'os', 'sys', 're', 'json', 'math', 'random', 'datetime', 'time',
        'collections', 'itertools', 'functools', 'pathlib', 'subprocess',
        'urllib', 'http', 'email', 'html', 'xml', 'csv', 'sqlite3',
        'logging', 'argparse', 'unittest', 'doctest', 'pdb', 'profile',
        'ast', 'dis', 'tokenize', 'inspect', 'traceback', 'warnings'
    }
    
    imports = defaultdict(list)
    
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                module = alias.name.split('.')[0]
                category = 'stdlib' if module in stdlib_modules else 'third-party'
                imports[category].append(alias.name)
        elif isinstance(node, ast.ImportFrom):
            if node.module:
                module = node.module.split('.')[0]
                category = 'stdlib' if module in stdlib_modules else 'third-party'
                for alias in node.names:
                    imports[category].append(f'{node.module}.{alias.name}')
    
    # Report findings
    for category in ['stdlib', 'third-party']:
        if imports[category]:
            print(f'\n{category.title()} imports ({len(set(imports[category]))})::')
            for imp in sorted(set(imports[category])):
                print(f'  - {imp}')
    
    # Check for potential issues
    print('\n=== IMPORT HEALTH ===')
    
    # Circular import risk (basic check)
    from_imports = [n for n in ast.walk(tree) if isinstance(n, ast.ImportFrom) and n.module and n.level == 0]
    if len(from_imports) > 10:
        print('⚠️  Many from imports - potential circular dependency risk')
    else:
        print('✅ Import structure looks healthy')
        
except SyntaxError:
    print('Note: Not a Python file, showing basic import patterns...')
    # Fallback to regex for other languages
    import re
    
    js_imports = re.findall(r'(?:import|require)\s*\(["\']([^"\']+)["\']\)', code)
    if js_imports:
        print('\nJavaScript/TypeScript imports:')
        for imp in sorted(set(js_imports)):
            print(f'  - {imp}')
            
except Exception as e:
    print(f'Error analyzing imports: {e}')
EOF
        ;;
    
    "duplicates"|"find-duplicates")
        # Find duplicate code blocks
        FILE="${2:-/dev/stdin}"
        MIN_LINES="${3:-4}"
        export FILE MIN_LINES
        python3 <<'EOF'
import sys
import os
from collections import defaultdict

file_path = os.environ.get('FILE', '/dev/stdin')
min_block_size = int(os.environ.get('MIN_LINES', '4'))

if file_path == '/dev/stdin':
    code = sys.stdin.read()
else:
    with open(file_path, 'r') as f:
        code = f.read()

lines = code.splitlines()

print(f'=== DUPLICATE CODE DETECTION (min {min_block_size} lines) ===')

# Create hashes of line blocks
block_hashes = defaultdict(list)

for i in range(len(lines) - min_block_size + 1):
    block = lines[i:i + min_block_size]
    # Skip empty or comment-only blocks
    if all(not line.strip() or line.strip().startswith('#') for line in block):
        continue
        
    block_text = '\n'.join(block)
    block_hash = hash(block_text)
    block_hashes[block_hash].append((i + 1, block_text))

# Find duplicates
duplicates_found = False
for block_hash, occurrences in block_hashes.items():
    if len(occurrences) > 1:
        duplicates_found = True
        print(f'\nDuplicate block found ({len(occurrences)} occurrences):')
        print(f'Lines: {", ".join(str(occ[0]) for occ in occurrences)}')
        print('Content:')
        print('  ' + occurrences[0][1].replace('\n', '\n  '))
        print()

if not duplicates_found:
    print('✅ No duplicate blocks found')
else:
    print('💡 Consider extracting duplicate code into functions')
EOF
        ;;
    
    "docs"|"doc-quality")
        # Analyze documentation quality
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import re
import ast
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')

try:
    if file_path == '/dev/stdin':
        code = sys.stdin.read()
    else:
        with open(file_path, 'r') as f:
            code = f.read()
    
    print('=== DOCUMENTATION ANALYSIS ===')
    
    # Check if it's a Python file
    is_python = file_path.endswith('.py') or file_path == '/dev/stdin'
    
    if is_python:
        try:
            tree = ast.parse(code)
            
            # Count documented vs undocumented items
            total_items = 0
            documented_items = 0
            missing_docs = []
            
            for node in ast.walk(tree):
                if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
                    total_items += 1
                    docstring = ast.get_docstring(node)
                    if docstring:
                        documented_items += 1
                    else:
                        item_type = 'function' if isinstance(node, ast.FunctionDef) else 'class'
                        missing_docs.append((item_type, node.name))
            
            # Calculate coverage
            if total_items > 0:
                coverage = (documented_items / total_items) * 100
                print(f'Documentation coverage: {coverage:.1f}%')
                print(f'Documented: {documented_items}/{total_items}')
                
                if coverage >= 80:
                    print('✅ Good documentation coverage')
                elif coverage >= 50:
                    print('⚡ Fair documentation coverage')
                else:
                    print('⚠️  Poor documentation coverage')
                
                if missing_docs:
                    print('\nMissing documentation:')
                    for item_type, name in missing_docs[:10]:
                        print(f'  - {item_type} {name}()')
                    if len(missing_docs) > 10:
                        print(f'  ... and {len(missing_docs) - 10} more')
            else:
                print('No functions or classes found')
                
        except SyntaxError:
            print('Note: Not valid Python code')
    
    # General documentation patterns
    print('\n=== COMMENT ANALYSIS ===')
    
    lines = code.splitlines()
    total_lines = len(lines)
    comment_lines = 0
    code_lines = 0
    blank_lines = 0
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            blank_lines += 1
        elif stripped.startswith('#') or stripped.startswith('//') or stripped.startswith('/*') or stripped.startswith('*'):
            comment_lines += 1
        else:
            code_lines += 1
    
    if total_lines > 0:
        comment_ratio = (comment_lines / total_lines) * 100
        print(f'Total lines: {total_lines}')
        print(f'Code lines: {code_lines}')
        print(f'Comment lines: {comment_lines} ({comment_ratio:.1f}%)')
        print(f'Blank lines: {blank_lines}')
        
        if comment_ratio >= 20:
            print('\n✅ Well-commented code')
        elif comment_ratio >= 10:
            print('\n⚡ Adequately commented')
        else:
            print('\n⚠️  Needs more comments')
    
    # Check for README
    if file_path != '/dev/stdin':
        dir_path = os.path.dirname(file_path) or '.'
        readme_files = ['README.md', 'README.rst', 'README.txt', 'README']
        has_readme = any(os.path.exists(os.path.join(dir_path, f)) for f in readme_files)
        print(f'\nProject README: {"✅ Found" if has_readme else "❌ Not found"}')
        
except Exception as e:
    print(f'Error analyzing documentation: {e}')
EOF
        ;;
    
    "smells"|"code-smells")
        # Detect common code smells
        FILE="${2:-/dev/stdin}"
        export FILE
        python3 <<'EOF'
import ast
import sys
import os

file_path = os.environ.get('FILE', '/dev/stdin')

try:
    if file_path == '/dev/stdin':
        code = sys.stdin.read()
    else:
        with open(file_path, 'r') as f:
            code = f.read()
    
    print('=== CODE SMELL DETECTION ===')
    
    smells_found = []
    
    # Check if it's Python
    is_python = file_path.endswith('.py') or file_path == '/dev/stdin'
    
    if is_python:
        try:
            tree = ast.parse(code)
            
            # Analyze functions
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    # Long function
                    func_lines = node.end_lineno - node.lineno + 1 if hasattr(node, 'end_lineno') else 0
                    if func_lines > 50:
                        smells_found.append(f'Long function: {node.name} ({func_lines} lines)')
                    
                    # Too many parameters
                    param_count = len(node.args.args)
                    if param_count > 5:
                        smells_found.append(f'Too many parameters: {node.name} ({param_count} params)')
                    
                    # Deep nesting
                    def get_max_depth(n, depth=0):
                        max_d = depth
                        for child in ast.iter_child_nodes(n):
                            if isinstance(child, (ast.If, ast.For, ast.While, ast.With)):
                                max_d = max(max_d, get_max_depth(child, depth + 1))
                            else:
                                max_d = max(max_d, get_max_depth(child, depth))
                        return max_d
                    
                    max_depth = get_max_depth(node)
                    if max_depth > 3:
                        smells_found.append(f'Deep nesting: {node.name} (depth {max_depth})')
                
                # Large classes
                elif isinstance(node, ast.ClassDef):
                    methods = [n for n in node.body if isinstance(n, ast.FunctionDef)]
                    if len(methods) > 20:
                        smells_found.append(f'Large class: {node.name} ({len(methods)} methods)')
                    
                    # God class (too many responsibilities)
                    attrs = [n for n in node.body if isinstance(n, ast.Assign)]
                    if len(attrs) > 15:
                        smells_found.append(f'God class candidate: {node.name} ({len(attrs)} attributes)')
        
        except SyntaxError:
            pass
    
    # General code smell patterns (language agnostic)
    lines = code.splitlines()
    
    # Check for long lines
    long_lines = [(i+1, len(line)) for i, line in enumerate(lines) if len(line) > 120]
    if long_lines:
        smells_found.append(f'Long lines: {len(long_lines)} lines over 120 chars')
    
    # Magic numbers
    import re
    magic_numbers = re.findall(r'\b(?<!\.)\d{2,}\b(?!\.)', code)
    magic_numbers = [n for n in magic_numbers if n not in ['100', '1000', '200', '404', '500', '10', '20', '30', '40', '50', '60', '70', '80', '90']]
    if len(magic_numbers) > 5:
        smells_found.append(f'Magic numbers: {len(set(magic_numbers))} unique values')
    
    # Commented out code
    commented_code_patterns = [
        r'#\s*(if|for|while|def|class|import|return)\s',
        r'//\s*(if|for|while|function|class|import|return)\s',
        r'/\*.*?(if|for|while|function|class|import|return).*?\*/'
    ]
    commented_code_count = 0
    for pattern in commented_code_patterns:
        commented_code_count += len(re.findall(pattern, code, re.IGNORECASE))
    
    if commented_code_count > 3:
        smells_found.append(f'Commented out code: {commented_code_count} blocks')
    
    # Report findings
    if smells_found:
        print(f'Found {len(smells_found)} code smells:\n')
        for smell in smells_found:
            print(f'⚠️  {smell}')
        
        print('\n💡 Recommendations:')
        print('- Break long functions into smaller ones')
        print('- Reduce parameter count using objects/configs')
        print('- Extract nested logic into separate functions')
        print('- Split large classes based on responsibilities')
        print('- Replace magic numbers with named constants')
        print('- Remove commented out code')
    else:
        print('✅ No significant code smells detected')
        
except Exception as e:
    print(f'Error detecting code smells: {e}')
EOF
        ;;
    
    "overview"|"analyze")
        # Comprehensive file analysis
        FILE="${2:-}"
        if [ -z "$FILE" ]; then
            error_exit "Usage: $0 overview <file>"
        fi
        
        echo "=== COMPREHENSIVE ANALYSIS: $FILE ==="
        echo ""
        
        # Token count
        "$0" tokens "$FILE"
        echo ""
        
        # Language detection
        EXT="${FILE##*.}"
        echo "File type: .$EXT"
        echo ""
        
        # Run appropriate analysis based on extension
        case "$EXT" in
            py)
                "$0" analyze-complexity "$FILE"
                echo ""
                "$0" imports "$FILE"
                echo ""
                "$0" smells "$FILE"
                ;;
            js|ts|jsx|tsx)
                "$0" keywords "$FILE" 15
                echo ""
                "$0" smells "$FILE"
                ;;
            md|rst|txt)
                "$0" readability "$FILE"
                echo ""
                "$0" summary "$FILE"
                ;;
            *)
                "$0" summary "$FILE"
                echo ""
                "$0" smells "$FILE"
                ;;
        esac
        
        echo ""
        "$0" duplicates "$FILE" 3
        echo ""
        "$0" docs "$FILE"
        ;;
    
    "help"|"")
        echo "=== NLP & STATIC ANALYSIS HELPER ==="
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Text Analysis Commands:"
        echo "  tokens <file>         - Count characters, words, and estimate tokens"
        echo "  summary <file>        - Extract headers and first paragraph"
        echo "  keywords <file> [n]   - Show top N keywords (default: 10)"
        echo "  questions <file>      - Extract all questions from text"
        echo "  todos [pattern]       - Find TODO/FIXME/HACK comments"
        echo "  sentiment \"text\"      - Analyze sentiment of text"
        echo "  readability <file>    - Calculate readability score"
        echo "  ngrams <n> <file>     - Extract n-grams (word pairs, triplets, etc)"
        echo "  entities <file>       - Extract potential named entities"
        echo ""
        echo "Code Analysis Commands:"
        echo "  overview <file>       - Comprehensive file analysis"
        echo "  analyze-complexity <file> - Analyze cyclomatic complexity (Python)"
        echo "  security <file>       - Basic security vulnerability scan"
        echo "  imports <file>        - Analyze import dependencies"
        echo "  duplicates <file> [n] - Find duplicate code blocks (min n lines)"
        echo "  docs <file>           - Analyze documentation quality"
        echo "  smells <file>         - Detect common code smells"
        echo ""
        echo "Examples:"
        echo "  $0 tokens README.md"
        echo "  $0 keywords code.js 20"
        echo "  $0 sentiment \"This is a great feature!\""
        echo "  $0 ngrams 3 document.txt"
        echo ""
        echo "All commands accept stdin if no file is provided:"
        echo "  cat README.md | $0 summary"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac