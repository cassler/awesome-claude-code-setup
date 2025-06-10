#!/bin/bash

# API testing and development helper with jq and httpie

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# Default values
BASE_URL=""
HEADERS_FILE=""
OUTPUT_DIR="./api-responses"

# Help function
show_help() {
    echo "API Helper - Enhanced API testing and development"
    echo ""
    echo "Usage: $(basename "$0") <command> [options]"
    echo ""
    echo "Commands:"
    echo "  test <endpoint>       Send request to endpoint"
    echo "  parse <file> [query]  Parse JSON response with jq"
    echo "  compare <f1> <f2>     Compare two API responses"
    echo "  extract <file> <path> Extract specific data from response"
    echo "  validate <file>       Validate JSON structure"
    echo "  save-headers          Save common headers for reuse"
    echo "  help                  Show this help message"
    echo ""
    echo "Options:"
    echo "  --base-url URL       Set base URL for requests"
    echo "  --headers FILE       Use headers from file"
    echo "  --method METHOD      HTTP method (GET, POST, etc.)"
    echo "  --data DATA          Request body data"
    echo "  --save               Save response to file"
    echo ""
    
    # Show tool availability
    echo "Tool Status:"
    check_optional_tool "jq" "JSON parsing" false
    check_optional_tool "httpie" "HTTP requests" false
    check_optional_tool "curl" "HTTP requests (fallback)" false
}

# Send API request
test_endpoint() {
    local endpoint="$1"
    local method="${METHOD:-GET}"
    local data="$DATA"
    local save_response="$SAVE_RESPONSE"
    
    if [ -z "$endpoint" ]; then
        echo "❌ Endpoint required"
        return 1
    fi
    
    # Build full URL
    local url="$endpoint"
    if [ -n "$BASE_URL" ]; then
        # Handle trailing/leading slashes
        url="${BASE_URL%/}/${endpoint#/}"
    fi
    
    echo "🌐 ${method} ${url}"
    
    # Prepare headers
    local headers_args=""
    if [ -n "$HEADERS_FILE" ] && [ -f "$HEADERS_FILE" ]; then
        if command -v jq &> /dev/null; then
            # Parse headers file with jq
            headers_args=$(jq -r 'to_entries | .[] | "--header \(.key):\(.value)"' "$HEADERS_FILE" 2>/dev/null)
        fi
    fi
    
    # Make request
    local response_file=""
    if [ "$save_response" = "true" ]; then
        mkdir -p "$OUTPUT_DIR"
        response_file="$OUTPUT_DIR/$(date +%Y%m%d_%H%M%S)_${endpoint//\//_}.json"
    fi
    
    if command -v http &> /dev/null; then
        # Use httpie
        local cmd="http $method '$url'"
        [ -n "$headers_args" ] && cmd="$cmd $headers_args"
        [ -n "$data" ] && cmd="$cmd '$data'"
        
        if [ -n "$response_file" ]; then
            eval "$cmd" | tee "$response_file"
            echo ""
            echo "💾 Saved to: $response_file"
        else
            eval "$cmd"
        fi
    elif command -v curl &> /dev/null; then
        # Fallback to curl
        local curl_args="-X $method"
        [ -n "$headers_args" ] && curl_args="$curl_args $headers_args"
        [ -n "$data" ] && curl_args="$curl_args -d '$data'"
        
        if [ -n "$response_file" ]; then
            curl -s $curl_args "$url" | tee "$response_file"
            echo ""
            echo "💾 Saved to: $response_file"
        else
            curl -s $curl_args "$url"
        fi
    else
        echo "❌ No HTTP client found (install httpie or curl)"
        suggest_install_tool "httpie"
        return 1
    fi
}

# Parse JSON with jq
parse_json() {
    local file="$1"
    local query="${2:-.}"
    
    if [ ! -f "$file" ]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        # Pretty print with colors if available
        if [ -t 1 ]; then
            jq -C "$query" "$file"
        else
            jq "$query" "$file"
        fi
    else
        echo "⚠️  jq not installed - showing raw content"
        suggest_install_tool "jq"
        echo ""
        cat "$file"
    fi
}

# Compare two JSON responses
compare_responses() {
    local file1="$1"
    local file2="$2"
    
    if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
        echo "❌ Both files must exist"
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        # Sort keys for consistent comparison
        local temp1=$(mktemp)
        local temp2=$(mktemp)
        
        jq -S . "$file1" > "$temp1"
        jq -S . "$file2" > "$temp2"
        
        if command -v delta &> /dev/null; then
            delta "$temp1" "$temp2"
        elif command -v diff &> /dev/null; then
            diff -u "$temp1" "$temp2" | bat --language=diff --style=plain 2>/dev/null || diff -u "$temp1" "$temp2"
        fi
        
        rm -f "$temp1" "$temp2"
    else
        echo "⚠️  jq required for JSON comparison"
        suggest_install_tool "jq"
        echo ""
        echo "Falling back to text diff:"
        diff -u "$file1" "$file2"
    fi
}

# Extract specific data
extract_data() {
    local file="$1"
    local path="$2"
    
    if [ ! -f "$file" ]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    if [ -z "$path" ]; then
        echo "❌ Path required (e.g., '.data.users[0].name')"
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        local result=$(jq -r "$path" "$file" 2>&1)
        if [ $? -eq 0 ]; then
            echo "$result"
            
            # Offer to save if complex
            if [ $(echo "$result" | wc -l) -gt 10 ]; then
                echo ""
                if command -v gum &> /dev/null; then
                    if gum confirm "Save extracted data to file?"; then
                        local output_file="extracted_$(date +%Y%m%d_%H%M%S).json"
                        echo "$result" > "$output_file"
                        echo "💾 Saved to: $output_file"
                    fi
                else
                    echo -n "Save extracted data to file? [y/N] "
                    read -r response
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        local output_file="extracted_$(date +%Y%m%d_%H%M%S).json"
                        echo "$result" > "$output_file"
                        echo "💾 Saved to: $output_file"
                    fi
                fi
            fi
        else
            echo "❌ jq error: $result"
            echo ""
            echo "Available paths in file:"
            jq -r 'paths | join(".")' "$file" 2>/dev/null | head -20
        fi
    else
        echo "❌ jq required for data extraction"
        suggest_install_tool "jq"
    fi
}

# Validate JSON structure
validate_json() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        if jq empty "$file" 2>/dev/null; then
            echo "✅ Valid JSON"
            
            # Show structure summary
            echo ""
            echo "Structure summary:"
            jq -r '
                def typeinfo: 
                    if type == "array" then 
                        "array[\(length)]"
                    elif type == "object" then
                        "object{\(keys|length) keys}"
                    else 
                        type
                    end;
                    
                def summarize($prefix): 
                    if type == "object" then
                        to_entries | .[] | "\($prefix)\(.key): \(.value | typeinfo)"
                    elif type == "array" then
                        "\($prefix): array[\(length)]"
                    else
                        "\($prefix): \(typeinfo)"
                    end;
                    
                summarize("")
            ' "$file" | head -20
        else
            echo "❌ Invalid JSON"
            jq . "$file" 2>&1 | head -10
        fi
    else
        echo "⚠️  jq required for JSON validation"
        suggest_install_tool "jq"
        echo ""
        # Basic check with python if available
        if command -v python3 &> /dev/null; then
            python3 -m json.tool "$file" > /dev/null 2>&1 && echo "✅ Valid JSON (basic check)" || echo "❌ Invalid JSON"
        fi
    fi
}

# Save common headers
save_headers() {
    local headers_file="${1:-headers.json}"
    
    if command -v gum &> /dev/null; then
        echo "Enter headers (one per line, format: Header-Name: value)"
        echo "Press Ctrl+D when done"
        
        local headers="{}"
        while IFS= read -r line; do
            if [[ "$line" =~ ^([^:]+):[[:space:]]*(.+)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                headers=$(echo "$headers" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
            fi
        done
        
        echo "$headers" > "$headers_file"
        echo "💾 Headers saved to: $headers_file"
    else
        echo "Creating headers file: $headers_file"
        echo "{"
        echo '  "Content-Type": "application/json",'
        echo '  "Authorization": "Bearer YOUR_TOKEN"'
        echo "}" > "$headers_file"
        echo "Edit $headers_file with your headers"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base-url)
            BASE_URL="$2"
            shift 2
            ;;
        --headers)
            HEADERS_FILE="$2"
            shift 2
            ;;
        --method)
            METHOD="$2"
            shift 2
            ;;
        --data)
            DATA="$2"
            shift 2
            ;;
        --save)
            SAVE_RESPONSE="true"
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Main command handling
case "$1" in
    test)
        shift
        test_endpoint "$@"
        ;;
    parse)
        parse_json "$2" "$3"
        ;;
    compare)
        compare_responses "$2" "$3"
        ;;
    extract)
        extract_data "$2" "$3"
        ;;
    validate)
        validate_json "$2"
        ;;
    save-headers)
        save_headers "$2"
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac