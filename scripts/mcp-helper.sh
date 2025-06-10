#!/bin/bash

# MCP Helper Script - Shortcuts for MCP server operations
# Usage: ./mcp-helper.sh [command] [args]

case "$1" in
    "linear-issues"|"li")
        # Quick Linear issues overview
        echo "=== LINEAR ISSUES OVERVIEW ==="
        echo "This would list recent Linear issues"
        echo "Use MCP: mcp__linear__list_my_issues"
        ;;
    
    "linear-search"|"ls")
        # Search Linear issues
        QUERY="$2"
        if [ -z "$QUERY" ]; then
            echo "Usage: $0 linear-search <query>"
            exit 1
        fi
        echo "Would search Linear for: $QUERY"
        echo "Use MCP: mcp__linear__list_issues with query parameter"
        ;;
    
    "notion-search"|"ns")
        # Search Notion
        QUERY="$2"
        if [ -z "$QUERY" ]; then
            echo "Usage: $0 notion-search <query>"
            exit 1
        fi
        echo "Would search Notion for: $QUERY"
        echo "Use MCP: mcp__notion__search"
        ;;
    
    "notion-page"|"np")
        # View Notion page
        PAGE_ID="$2"
        if [ -z "$PAGE_ID" ]; then
            echo "Usage: $0 notion-page <page-id-or-url>"
            exit 1
        fi
        echo "Would view Notion page: $PAGE_ID"
        echo "Use MCP: mcp__notion__view"
        ;;
    
    "browser-open"|"bo")
        # Open browser URL
        URL="$2"
        if [ -z "$URL" ]; then
            echo "Usage: $0 browser-open <url>"
            exit 1
        fi
        echo "Would navigate browser to: $URL"
        echo "Use MCP: mcp__playwright__browser_navigate"
        ;;
    
    "browser-screenshot"|"bs")
        # Take browser screenshot
        FILENAME="${2:-screenshot.png}"
        echo "Would take screenshot: $FILENAME"
        echo "Use MCP: mcp__playwright__browser_take_screenshot"
        ;;
    
    "mastra-docs"|"md")
        # Search Mastra docs
        TOPIC="$2"
        if [ -z "$TOPIC" ]; then
            echo "=== MASTRA DOCS TOPICS ==="
            echo "agents, workflows, tools, memory, rag, deployment, etc."
            echo "Usage: $0 mastra-docs <topic>"
        else
            echo "Would fetch Mastra docs for: $TOPIC"
            echo "Use MCP: mcp__mastra__mastraDocs"
        fi
        ;;
    
    "context7"|"c7")
        # Context7 library lookup
        LIBRARY="$2"
        if [ -z "$LIBRARY" ]; then
            echo "Usage: $0 context7 <library-name>"
            exit 1
        fi
        echo "Would lookup library: $LIBRARY"
        echo "Use MCP: mcp__context7__resolve-library-id"
        echo "Then: mcp__context7__get-library-docs"
        ;;
    
    "mcp-list"|"list")
        echo "=== AVAILABLE MCP SERVERS ==="
        echo ""
        echo "Linear (Issue tracking):"
        echo "  - list_my_issues"
        echo "  - create_issue"
        echo "  - update_issue"
        echo "  - list_comments"
        echo ""
        echo "Notion (Documentation):"
        echo "  - search"
        echo "  - view"
        echo "  - create-pages"
        echo "  - update-page"
        echo ""
        echo "Playwright (Browser automation):"
        echo "  - browser_navigate"
        echo "  - browser_snapshot"
        echo "  - browser_click"
        echo "  - browser_type"
        echo "  - browser_take_screenshot"
        echo ""
        echo "Mastra (AI framework):"
        echo "  - mastraDocs"
        echo "  - mastraBlog"
        echo "  - mastraExamples"
        echo ""
        echo "Context7 (Library docs):"
        echo "  - resolve-library-id"
        echo "  - get-library-docs"
        ;;
    
    "quick-task"|"qt")
        # Quick task creation helper
        TITLE="$2"
        if [ -z "$TITLE" ]; then
            echo "Usage: $0 quick-task <title>"
            exit 1
        fi
        echo "Task creation helper for: $TITLE"
        echo "Suggested MCP calls:"
        echo "1. Create Linear issue: mcp__linear__create_issue"
        echo "2. Create Notion page: mcp__notion__create-pages"
        echo "3. Or use TodoWrite for local tracking"
        ;;
    
    *)
        echo "MCP Helper Commands:"
        echo "  $0 linear-issues|li         - List Linear issues"
        echo "  $0 linear-search|ls <q>     - Search Linear"
        echo "  $0 notion-search|ns <q>     - Search Notion"
        echo "  $0 notion-page|np <id>      - View Notion page"
        echo "  $0 browser-open|bo <url>    - Open in browser"
        echo "  $0 browser-screenshot|bs    - Take screenshot"
        echo "  $0 mastra-docs|md [topic]   - Mastra documentation"
        echo "  $0 context7|c7 <lib>        - Library docs lookup"
        echo "  $0 mcp-list|list            - List all MCP servers"
        echo "  $0 quick-task|qt <title>    - Task creation helper"
        echo ""
        echo "Note: This script provides guidance on which MCP tools to use."
        echo "The actual MCP calls need to be made separately."
        ;;
esac