#!/bin/bash

# Multi-file Operations Script
# Usage: ./multi-file.sh [command] [args]

case "$1" in
    "read-many"|"rm")
        # Read multiple files at once
        shift
        if [ $# -eq 0 ]; then
            echo "Usage: $0 read-many <file1> <file2> ..."
            exit 1
        fi
        
        for file in "$@"; do
            if [ -f "$file" ]; then
                echo "=== FILE: $file ==="
                head -50 "$file"
                echo ""
            else
                echo "=== FILE: $file (NOT FOUND) ==="
                echo ""
            fi
        done
        ;;
    
    "read-pattern"|"rp")
        # Read all files matching a pattern
        PATTERN="$2"
        LINES="${3:-50}"
        if [ -z "$PATTERN" ]; then
            echo "Usage: $0 read-pattern <pattern> [lines]"
            exit 1
        fi
        
        find . -type f -name "$PATTERN" -not -path "*/node_modules/*" -not -path "*/.git/*" | while read -r file; do
            echo "=== FILE: $file ==="
            head -"$LINES" "$file"
            echo ""
        done
        ;;
    
    "list-structure"|"ls")
        # List files with structure info
        DIR="${2:-.}"
        echo "=== STRUCTURE: $DIR ==="
        find "$DIR" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" | sort | while read -r file; do
            SIZE=$(wc -c < "$file" 2>/dev/null || echo "0")
            LINES=$(wc -l < "$file" 2>/dev/null || echo "0")
            echo "$file (${LINES}L, ${SIZE}B)"
        done | column -t
        ;;
    
    "grep-many"|"gm")
        # Grep in specific files
        PATTERN="$2"
        shift 2
        if [ -z "$PATTERN" ] || [ $# -eq 0 ]; then
            echo "Usage: $0 grep-many <pattern> <file1> <file2> ..."
            exit 1
        fi
        
        for file in "$@"; do
            if [ -f "$file" ]; then
                MATCHES=$(grep -n "$PATTERN" "$file" 2>/dev/null)
                if [ -n "$MATCHES" ]; then
                    echo "=== $file ==="
                    echo "$MATCHES"
                    echo ""
                fi
            fi
        done
        ;;
    
    "compare"|"cmp")
        # Compare two files
        FILE1="$2"
        FILE2="$3"
        if [ -z "$FILE1" ] || [ -z "$FILE2" ]; then
            echo "Usage: $0 compare <file1> <file2>"
            exit 1
        fi
        
        if [ -f "$FILE1" ] && [ -f "$FILE2" ]; then
            echo "=== COMPARING: $FILE1 vs $FILE2 ==="
            diff -u "$FILE1" "$FILE2" | head -50
        else
            echo "Error: Both files must exist"
        fi
        ;;
    
    "find-similar"|"fs")
        # Find files with similar names
        BASE="$2"
        if [ -z "$BASE" ]; then
            echo "Usage: $0 find-similar <base-name>"
            exit 1
        fi
        
        echo "=== FILES SIMILAR TO: $BASE ==="
        find . -type f -name "*${BASE}*" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -20
        ;;
    
    "batch-rename"|"br")
        # Preview batch rename
        OLD="$2"
        NEW="$3"
        if [ -z "$OLD" ] || [ -z "$NEW" ]; then
            echo "Usage: $0 batch-rename <old-pattern> <new-pattern>"
            echo "Note: This only shows preview, doesn't actually rename"
            exit 1
        fi
        
        echo "=== RENAME PREVIEW ==="
        find . -type f -name "*${OLD}*" -not -path "*/node_modules/*" | while read -r file; do
            NEW_NAME=$(echo "$file" | sed "s/${OLD}/${NEW}/g")
            echo "$file -> $NEW_NAME"
        done
        ;;
    
    "read-related"|"rr")
        # Read a file and related files
        FILE="$2"
        if [ -z "$FILE" ]; then
            echo "Usage: $0 read-related <file>"
            exit 1
        fi
        
        if [ -f "$FILE" ]; then
            # Read the main file
            echo "=== MAIN FILE: $FILE ==="
            head -30 "$FILE"
            echo ""
            
            # Find and read test file
            BASE=$(basename "$FILE" | sed 's/\.[^.]*$//')
            DIR=$(dirname "$FILE")
            
            # Look for test files
            for test_pattern in "*${BASE}*.test.*" "*${BASE}*.spec.*" "test_${BASE}*"; do
                TEST_FILE=$(find "$DIR" -name "$test_pattern" -type f | head -1)
                if [ -n "$TEST_FILE" ] && [ -f "$TEST_FILE" ]; then
                    echo "=== TEST FILE: $TEST_FILE ==="
                    head -20 "$TEST_FILE"
                    echo ""
                    break
                fi
            done
            
            # Look for related files in same directory
            echo "=== RELATED FILES IN $DIR ==="
            ls -la "$DIR" | grep -E "(${BASE}|$(echo $BASE | tr '[:upper:]' '[:lower:]'))" | head -10
        else
            echo "File not found: $FILE"
        fi
        ;;
    
    "create-many"|"cm")
        # Create multiple files with boilerplate
        TYPE="$2"
        shift 2
        if [ -z "$TYPE" ] || [ $# -eq 0 ]; then
            echo "Usage: $0 create-many <type> <file1> <file2> ..."
            echo "Types: ts, js, py, sh, md"
            exit 1
        fi
        
        for file in "$@"; do
            echo "Would create: $file (type: $TYPE)"
            case "$TYPE" in
                "ts")
                    echo "Content preview: export const $(basename "$file" .ts) = {};"
                    ;;
                "js")
                    echo "Content preview: module.exports = {};"
                    ;;
                "py")
                    echo "Content preview: #!/usr/bin/env python3"
                    ;;
                "sh")
                    echo "Content preview: #!/bin/bash"
                    ;;
                "md")
                    echo "Content preview: # $(basename "$file" .md)"
                    ;;
            esac
            echo ""
        done
        ;;
    
    *)
        echo "Multi-file Operations Commands:"
        echo "  $0 read-many|rm <files>        - Read multiple files"
        echo "  $0 read-pattern|rp <pattern>   - Read files matching pattern"
        echo "  $0 list-structure|ls [dir]     - List files with info"
        echo "  $0 grep-many|gm <pat> <files>  - Grep in specific files"
        echo "  $0 compare|cmp <file1> <file2> - Compare two files"
        echo "  $0 find-similar|fs <base>      - Find similar filenames"
        echo "  $0 batch-rename|br <old> <new> - Preview batch rename"
        echo "  $0 read-related|rr <file>      - Read file and related"
        echo "  $0 create-many|cm <type> files - Preview creating files"
        ;;
esac