#!/bin/bash

# Go Helper Script - Go-specific development tools
# Usage: ./go-helper.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common-functions.sh"

# Check if we're in a Go module
is_go_module() {
    [[ -f "go.mod" ]]
}

# Get module name
get_module_name() {
    if is_go_module; then
        head -1 go.mod | awk '{print $2}'
    else
        echo "no-module"
    fi
}

case "$1" in
    "deps"|"dependencies")
        echo -e "${GREEN}=== GO DEPENDENCIES ===${NC}"
        
        if is_go_module; then
            echo "Module: $(get_module_name)"
            echo ""
            echo "=== DIRECT DEPENDENCIES ==="
            go list -m all | grep -v "^$(get_module_name)" | head -20
            
            echo ""
            echo "=== MODULE GRAPH ==="
            go mod graph | head -20
            
            # Check for available updates
            echo ""
            echo "=== CHECKING FOR UPDATES ==="
            go list -u -m all | grep "\[" | head -10 || echo "All dependencies up to date"
        else
            echo "Not a Go module. Run 'go mod init' to initialize."
        fi
        ;;
    
    "test")
        echo -e "${GREEN}=== RUNNING GO TESTS ===${NC}"
        
        if is_go_module; then
            # Run tests with coverage
            go test -v -cover ./...
        else
            # Try to run tests anyway
            go test -v
        fi
        ;;
    
    "lint")
        echo -e "${GREEN}=== GO LINTING ===${NC}"
        
        # Try golangci-lint first (most comprehensive)
        if command -v golangci-lint &> /dev/null; then
            echo "Running golangci-lint..."
            golangci-lint run
        elif command -v golint &> /dev/null; then
            echo "Running golint..."
            golint ./...
        elif command -v go &> /dev/null; then
            echo "Running go vet..."
            go vet ./...
        else
            echo "No Go linter found. Install golangci-lint for best results:"
            echo "  brew install golangci-lint"
            echo "  or visit: https://golangci-lint.run/usage/install/"
        fi
        ;;
    
    "fmt"|"format")
        echo -e "${GREEN}=== GO CODE FORMATTING ===${NC}"
        
        # Check if formatting is needed
        UNFORMATTED=$(gofmt -l .)
        if [[ -n "$UNFORMATTED" ]]; then
            echo "Files needing formatting:"
            echo "$UNFORMATTED"
            echo ""
            echo "To format all files, run: go fmt ./..."
        else
            echo "All files are properly formatted"
        fi
        
        # Also check imports
        if command -v goimports &> /dev/null; then
            echo ""
            echo "Checking imports..."
            goimports -l . | head -10
        fi
        ;;
    
    "build")
        echo -e "${GREEN}=== BUILDING GO PROJECT ===${NC}"
        
        shift
        BUILD_ARGS="$@"
        
        if [[ -f "main.go" ]]; then
            echo "Building main.go..."
            go build $BUILD_ARGS -o "$(basename $(pwd))" main.go
        elif [[ -d "cmd" ]]; then
            echo "Building cmd packages..."
            for cmd in cmd/*/; do
                if [[ -d "$cmd" ]]; then
                    echo "Building $cmd..."
                    go build $BUILD_ARGS -o "bin/$(basename $cmd)" "./$cmd"
                fi
            done
        else
            echo "Building current package..."
            go build $BUILD_ARGS .
        fi
        ;;
    
    "run")
        echo -e "${GREEN}=== RUNNING GO PROJECT ===${NC}"
        
        shift
        if [[ -f "main.go" ]]; then
            go run main.go "$@"
        elif [[ -d "cmd" ]] && [[ -n "$1" ]]; then
            go run "./cmd/$@"
        else
            echo "Usage: $0 run [args]"
            echo "   or: $0 run <cmd> [args] (for cmd/ structure)"
        fi
        ;;
    
    "mod"|"module")
        shift
        case "$1" in
            "tidy")
                echo "Cleaning up go.mod and go.sum..."
                go mod tidy
                ;;
            "vendor")
                echo "Creating vendor directory..."
                go mod vendor
                ;;
            "download")
                echo "Downloading dependencies..."
                go mod download
                ;;
            "graph")
                echo "Module dependency graph:"
                go mod graph
                ;;
            "why")
                if [[ -z "$2" ]]; then
                    echo "Usage: $0 mod why <package>"
                else
                    go mod why "$2"
                fi
                ;;
            *)
                echo "Module commands:"
                echo "  mod tidy      Clean up go.mod"
                echo "  mod vendor    Create vendor directory"
                echo "  mod download  Download dependencies"
                echo "  mod graph     Show dependency graph"
                echo "  mod why <pkg> Explain why a package is needed"
                ;;
        esac
        ;;
    
    "audit"|"security")
        echo -e "${GREEN}=== GO SECURITY AUDIT ===${NC}"
        
        # Try nancy first
        if command -v nancy &> /dev/null; then
            echo "Running nancy..."
            go list -json -m all | nancy sleuth
        elif command -v gosec &> /dev/null; then
            echo "Running gosec..."
            gosec ./...
        elif command -v govulncheck &> /dev/null; then
            echo "Running govulncheck..."
            govulncheck ./...
        else
            echo "No Go security scanner found. Install one of:"
            echo "  go install github.com/sonatype-nexus-community/nancy@latest"
            echo "  go install github.com/securego/gosec/v2/cmd/gosec@latest"
            echo "  go install golang.org/x/vuln/cmd/govulncheck@latest"
        fi
        ;;
    
    "bench"|"benchmark")
        echo -e "${GREEN}=== RUNNING GO BENCHMARKS ===${NC}"
        
        shift
        go test -bench="${1:-.}" -benchmem ./...
        ;;
    
    "cover"|"coverage")
        echo -e "${GREEN}=== GO TEST COVERAGE ===${NC}"
        
        # Generate coverage report
        go test -coverprofile=coverage.out ./...
        go tool cover -func=coverage.out
        
        echo ""
        echo "To view HTML coverage report: go tool cover -html=coverage.out"
        ;;
    
    "doc")
        echo -e "${GREEN}=== GO DOCUMENTATION ===${NC}"
        
        shift
        if [[ -z "$1" ]]; then
            echo "Starting godoc server on http://localhost:6060"
            echo "Press Ctrl+C to stop"
            godoc -http=:6060
        else
            go doc "$@"
        fi
        ;;
    
    "get")
        echo -e "${GREEN}=== GO GET PACKAGE ===${NC}"
        
        shift
        if [[ -z "$1" ]]; then
            echo "Usage: $0 get <package>"
        else
            go get "$@"
        fi
        ;;
    
    "work")
        echo -e "${GREEN}=== GO WORKSPACE INFO ===${NC}"
        
        if [[ -f "go.work" ]]; then
            echo "Workspace modules:"
            go work edit -json | jq -r '.Use[].DiskPath'
        else
            echo "No Go workspace found"
            echo "To create: go work init"
        fi
        ;;
    
    "help"|"")
        echo "Go Helper - Go development tools"
        echo ""
        echo "Usage: ch go <command>"
        echo ""
        echo "Commands:"
        echo "  deps        Show dependencies"
        echo "  test        Run tests"
        echo "  lint        Run linter"
        echo "  fmt         Check formatting"
        echo "  build       Build project"
        echo "  run         Run project"
        echo "  mod         Module operations"
        echo "  audit       Security scan"
        echo "  bench       Run benchmarks"
        echo "  cover       Test coverage"
        echo "  doc         Show documentation"
        echo "  get         Get package"
        echo "  work        Workspace info"
        echo ""
        echo "Detected environment:"
        is_go_module && echo "  Module: $(get_module_name)"
        echo "  Go version: $(go version | awk '{print $3}')"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run 'ch go help' for usage"
        exit 1
        ;;
esac