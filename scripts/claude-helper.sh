#!/bin/bash

# Claude Helper - Main entry point for all helper scripts
# Usage: ./claude-helper.sh [category] [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$1" in
    "project"|"p")
        shift
        "$SCRIPT_DIR/project-info.sh" "$@"
        ;;
    
    "docker"|"d")
        shift
        "$SCRIPT_DIR/docker-quick.sh" "$@"
        ;;
    
    "git"|"g")
        shift
        "$SCRIPT_DIR/git-ops.sh" "$@"
        ;;
    
    "search"|"s")
        shift
        "$SCRIPT_DIR/search-tools.sh" "$@"
        ;;
    
    "ts"|"typescript"|"node")
        shift
        "$SCRIPT_DIR/ts-helper.sh" "$@"
        ;;
    
    "multi"|"m")
        shift
        "$SCRIPT_DIR/multi-file.sh" "$@"
        ;;
    
    "env"|"e")
        shift
        "$SCRIPT_DIR/env-check.sh" "$@"
        ;;
    
    "mcp")
        shift
        "$SCRIPT_DIR/mcp-helper.sh" "$@"
        ;;
    
    "context"|"ctx")
        shift
        "$SCRIPT_DIR/claude-context.sh" "$@"
        ;;
    
    "code-relationships"|"cr")
        shift
        "$SCRIPT_DIR/code-relationships.sh" "$@"
        ;;
    
    "code-quality"|"cq")
        shift
        "$SCRIPT_DIR/code-quality.sh" "$@"
        ;;
    
    "interactive"|"i")
        shift
        "$SCRIPT_DIR/interactive-helper.sh" "$@"
        ;;
    
    "api")
        shift
        "$SCRIPT_DIR/api-helper.sh" "$@"
        ;;
    
    "list"|"help"|"")
        echo "=== CLAUDE HELPER SCRIPTS ==="
        echo ""
        echo "Usage: $0 <category> <command> [args]"
        echo ""
        echo "Categories:"
        echo "  project|p     - Project overview and analysis"
        echo "  docker|d      - Docker operations"
        echo "  git|g         - Git operations"
        echo "  search|s      - Code searching tools"
        echo "  ts|node       - TypeScript/Node.js helpers"
        echo "  multi|m       - Multi-file operations"
        echo "  env|e         - Environment checks"
        echo "  mcp           - MCP server helpers"
        echo "  context|ctx   - Claude context generation"
        echo "  code-relationships|cr - Analyze code dependencies"
        echo "  code-quality|cq - Check code quality"
        echo ""
        echo "Enhanced Tools (optional):"
        echo "  interactive|i - Interactive file/branch selection"
        echo "  api           - API testing with JSON tools"
        echo ""
        echo "Quick Examples:"
        echo "  $0 p                    # Project overview"
        echo "  $0 g status             # Git status"
        echo "  $0 d ps                 # Docker containers"
        echo "  $0 s find-code pattern  # Search code"
        echo "  $0 ts deps              # Show dependencies"
        echo "  $0 env tools            # Check dev tools"
        echo ""
        echo "For help on specific category:"
        echo "  $0 <category> help"
        ;;
    
    *)
        echo "Unknown category: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac