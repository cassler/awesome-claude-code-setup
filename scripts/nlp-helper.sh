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
        python3 -c "
import sys
text = open('$FILE').read() if '$FILE' != '/dev/stdin' else sys.stdin.read()
# Rough token estimation: ~4 chars per token
chars = len(text)
words = len(text.split())
tokens = chars // 4
print(f'Characters: {chars:,}')
print(f'Words: {words:,}')
print(f'Tokens (est): {tokens:,}')
"
        ;;
    
    "summary")
        # Extract first paragraph and headers
        FILE="${2:-/dev/stdin}"
        python3 -c "
import re
text = open('$FILE').read() if '$FILE' != '/dev/stdin' else __import__('sys').stdin.read()

# Extract headers
headers = re.findall(r'^#+\s+(.+)$', text, re.MULTILINE)
if headers:
    print('Headers:', ', '.join(headers[:5]))
    
# First paragraph
paragraphs = [p.strip() for p in text.split('\n\n') if p.strip() and not p.strip().startswith('#')]
if paragraphs:
    first = paragraphs[0][:200] + '...' if len(paragraphs[0]) > 200 else paragraphs[0]
    print(f'\nFirst paragraph: {first}')
"
        ;;
    
    "keywords"|"frequency")
        # Word frequency analysis
        FILE="${2:-/dev/stdin}"
        TOP="${3:-10}"
        python3 -c "
import re
from collections import Counter

text = open('$FILE').read().lower() if '$FILE' != '/dev/stdin' else __import__('sys').stdin.read().lower()

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
print(f'Top {$TOP} keywords:')
for word, count in freq.most_common($TOP):
    print(f'  {word}: {count}')
"
        ;;
    
    "questions")
        # Extract questions
        FILE="${2:-/dev/stdin}"
        python3 -c "
import re
text = open('$FILE').read() if '$FILE' != '/dev/stdin' else __import__('sys').stdin.read()

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
"
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
        python3 -c "
text = '''$TEXT'''.lower()

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
"
        ;;
    
    "readability"|"complexity")
        # Estimate readability
        FILE="${2:-/dev/stdin}"
        python3 -c "
import re
text = open('$FILE').read() if '$FILE' != '/dev/stdin' else __import__('sys').stdin.read()

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
"
        ;;
    
    "ngrams")
        # Extract n-grams
        N="${2:-2}"
        FILE="${3:-/dev/stdin}"
        python3 -c "
import re
from collections import Counter

n = int('$N')
text = open('$FILE').read().lower() if '$FILE' != '/dev/stdin' else __import__('sys').stdin.read().lower()

# Extract words
words = re.findall(r'\b\w+\b', text)

# Generate n-grams
ngrams = [' '.join(words[i:i+n]) for i in range(len(words)-n+1)]

# Count frequency
freq = Counter(ngrams)
print(f'Top 10 {n}-grams:')
for ngram, count in freq.most_common(10):
    print(f'  {ngram}: {count}')
"
        ;;
    
    "entities"|"extract-names")
        # Simple named entity extraction
        FILE="${2:-/dev/stdin}"
        python3 -c "
import re
text = open('$FILE').read() if '$FILE' != '/dev/stdin' else __import__('sys').stdin.read()

# Find capitalized words (potential names)
# Exclude common words and single letters
entities = re.findall(r'\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b', text)
entities = [e for e in entities if len(e) > 1 and e not in 
           {'The', 'This', 'That', 'These', 'Those', 'A', 'An', 'In', 'On', 'At', 'To', 'For'}]

# Count occurrences
from collections import Counter
entity_counts = Counter(entities)

print('Potential entities:')
for entity, count in entity_counts.most_common(15):
    if count > 1:  # Only show repeated entities
        print(f'  {entity}: {count}')
"
        ;;
    
    "complexity"|"analyze-complexity")
        # Analyze code complexity
        FILE="${2:-/dev/stdin}"
        python3 -c "
import ast
import sys

def calculate_complexity(node, complexity=1):
    '''Calculate cyclomatic complexity of an AST node'''
    # Add 1 for each decision point
    for child in ast.walk(node):
        if isinstance(child, (ast.If, ast.While, ast.For, ast.ExceptHandler)):
            complexity += 1
        elif isinstance(child, ast.BoolOp):
            complexity += len(child.values) - 1
    return complexity

try:
    code = open('$FILE').read() if '$FILE' != '/dev/stdin' else sys.stdin.read()
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
"
        ;;
    
    "security"|"security-scan")
        # Basic security pattern detection
        FILE="${2:-/dev/stdin}"
        echo "=== SECURITY SCAN ==="
        export FILE
        python3 <<'PYTHON_SCRIPT'
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
PYTHON_SCRIPT
        ;;
    
    "imports"|"analyze-imports")
        # Analyze import dependencies
        FILE="${2:-/dev/stdin}"
        python3 -c "
import ast
import sys
from collections import defaultdict

try:
    code = open('$FILE').read() if '$FILE' != '/dev/stdin' else sys.stdin.read()
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
"
        ;;
    
    "duplicates"|"find-duplicates")
        # Find duplicate code blocks
        FILE="${2:-/dev/stdin}"
        MIN_LINES="${3:-4}"
        python3 -c "
import sys
from collections import defaultdict

code = open('$FILE').read() if '$FILE' != '/dev/stdin' else sys.stdin.read()
lines = code.splitlines()
min_block_size = int('$MIN_LINES')

print(f'=== DUPLICATE CODE DETECTION (min {min_block_size} lines) ===')

# Create hashes of line blocks
block_hashes = defaultdict(list)

for i in range(len(lines) - min_block_size + 1):
    block = lines[i:i + min_block_size]
    # Skip empty or comment-only blocks
    if all(not line.strip() or line.strip().startswith('#') for line in block):
        continue
        
    block_text = '\\n'.join(block)
    block_hash = hash(block_text)
    block_hashes[block_hash].append((i + 1, block_text))

# Find duplicates
duplicates_found = False
for block_hash, occurrences in block_hashes.items():
    if len(occurrences) > 1:
        duplicates_found = True
        print(f'\\nDuplicate block found ({len(occurrences)} occurrences):')
        print(f'Lines: {", ".join(str(occ[0]) for occ in occurrences)}')
        print('Content:')
        print('  ' + occurrences[0][1].replace('\\n', '\\n  '))
        print()

if not duplicates_found:
    print('✅ No duplicate blocks found')
else:
    print('💡 Consider extracting duplicate code into functions')
"
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
                "$0" complexity "$FILE"
                echo ""
                "$0" imports "$FILE"
                ;;
            js|ts|jsx|tsx)
                "$0" keywords "$FILE" 15
                ;;
            *)
                "$0" summary "$FILE"
                ;;
        esac
        
        echo ""
        "$0" duplicates "$FILE" 3
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
        echo "  complexity <file>     - Analyze cyclomatic complexity (Python)"
        echo "  security <file>       - Basic security vulnerability scan"
        echo "  imports <file>        - Analyze import dependencies"
        echo "  duplicates <file> [n] - Find duplicate code blocks (min n lines)"
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