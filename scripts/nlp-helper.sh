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
    
    "help"|"")
        echo "=== NLP HELPER ==="
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
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