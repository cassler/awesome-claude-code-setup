#!/bin/bash

# Python Helper Script - Python-specific development tools
# Usage: ./python-helper.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common-functions.sh"

# Detect Python package manager
detect_python_tools() {
    if [[ -f "poetry.lock" ]] || ([[ -f "pyproject.toml" ]] && command -v poetry &> /dev/null); then
        echo "poetry"
    elif [[ -f "Pipfile" ]] && command -v pipenv &> /dev/null; then
        echo "pipenv"
    elif [[ -f "requirements.txt" ]]; then
        echo "pip"
    elif [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]]; then
        echo "pip"
    else
        echo "none"
    fi
}

# Detect Python test framework
detect_test_framework() {
    if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] && grep -q "pytest" "pyproject.toml" 2>/dev/null; then
        echo "pytest"
    elif find . -name "test_*.py" -o -name "*_test.py" | head -1 | grep -q .; then
        echo "pytest"
    else
        echo "unittest"
    fi
}

case "$1" in
    "deps"|"dependencies")
        echo -e "${GREEN}=== PYTHON DEPENDENCIES ===${NC}"
        tool=$(detect_python_tools)
        
        case $tool in
            poetry)
                echo "Package manager: Poetry"
                echo ""
                echo "=== PRODUCTION DEPENDENCIES ==="
                poetry show --no-dev 2>/dev/null | head -20 || poetry show | head -20
                echo ""
                echo "=== DEVELOPMENT DEPENDENCIES ==="
                poetry show --dev 2>/dev/null | head -20
                ;;
            pipenv)
                echo "Package manager: Pipenv"
                echo ""
                pipenv graph
                ;;
            pip)
                echo "Package manager: pip"
                if [[ -f "requirements.txt" ]]; then
                    echo ""
                    echo "=== REQUIREMENTS.TXT ==="
                    cat requirements.txt | grep -v "^#" | grep -v "^$" | head -20
                fi
                echo ""
                echo "=== INSTALLED PACKAGES ==="
                pip list | head -20
                ;;
            *)
                echo "No Python package manager detected"
                echo "Looking for Python files..."
                find . -name "*.py" -type f | head -10
                ;;
        esac
        ;;
    
    "test")
        echo -e "${GREEN}=== RUNNING PYTHON TESTS ===${NC}"
        framework=$(detect_test_framework)
        tool=$(detect_python_tools)
        
        echo "Test framework: $framework"
        echo ""
        
        case $framework in
            pytest)
                if command -v pytest &> /dev/null; then
                    pytest -v --tb=short
                else
                    echo "pytest not found. Install with: pip install pytest"
                fi
                ;;
            unittest)
                python -m unittest discover -v
                ;;
        esac
        ;;
    
    "lint")
        echo -e "${GREEN}=== PYTHON LINTING ===${NC}"
        
        # Try multiple linters in order of preference
        if command -v ruff &> /dev/null; then
            echo "Running ruff..."
            ruff check .
        elif command -v flake8 &> /dev/null; then
            echo "Running flake8..."
            flake8 . --count --statistics
        elif command -v pylint &> /dev/null; then
            echo "Running pylint..."
            find . -name "*.py" -not -path "*/venv/*" -not -path "*/.venv/*" | xargs pylint
        else
            echo "No Python linter found. Install one of: ruff, flake8, or pylint"
        fi
        
        echo ""
        
        # Type checking
        if command -v mypy &> /dev/null; then
            echo "Running mypy type checking..."
            mypy . --ignore-missing-imports
        fi
        ;;
    
    "format")
        echo -e "${GREEN}=== PYTHON CODE FORMATTING ===${NC}"
        
        if command -v black &> /dev/null; then
            echo "Running black..."
            black . --check --diff
            echo ""
            echo "To format code, run: black ."
        elif command -v autopep8 &> /dev/null; then
            echo "Running autopep8..."
            autopep8 --diff -r .
            echo ""
            echo "To format code, run: autopep8 -i -r ."
        else
            echo "No Python formatter found. Install black or autopep8"
        fi
        ;;
    
    "venv"|"env")
        echo -e "${GREEN}=== PYTHON VIRTUAL ENVIRONMENT ===${NC}"
        
        # Check if in virtual environment
        if [[ -n "${VIRTUAL_ENV:-}" ]]; then
            echo "Active virtual environment: $VIRTUAL_ENV"
            echo "Python version: $(python --version)"
            echo "Pip version: $(pip --version)"
        else
            echo "No virtual environment active"
            echo ""
            echo "Found virtual environments:"
            find . -maxdepth 2 -name "venv" -o -name ".venv" -o -name "env" -type d 2>/dev/null
            echo ""
            echo "To create: python -m venv venv"
            echo "To activate: source venv/bin/activate"
        fi
        ;;
    
    "outdated")
        echo -e "${GREEN}=== OUTDATED PYTHON PACKAGES ===${NC}"
        tool=$(detect_python_tools)
        
        case $tool in
            poetry)
                poetry show --outdated
                ;;
            pipenv)
                pipenv update --outdated
                ;;
            pip)
                pip list --outdated
                ;;
            *)
                echo "No package manager detected"
                ;;
        esac
        ;;
    
    "audit"|"security")
        echo -e "${GREEN}=== PYTHON SECURITY AUDIT ===${NC}"
        
        if command -v pip-audit &> /dev/null; then
            echo "Running pip-audit..."
            pip-audit
        elif command -v safety &> /dev/null; then
            echo "Running safety check..."
            safety check
        else
            echo "No security audit tool found"
            echo "Install with: pip install pip-audit"
            echo "         or: pip install safety"
        fi
        ;;
    
    "run")
        # Run Python script or module
        shift
        if [[ -z "$1" ]]; then
            if [[ -f "main.py" ]]; then
                echo "Running main.py..."
                python main.py
            elif [[ -f "app.py" ]]; then
                echo "Running app.py..."
                python app.py
            elif [[ -f "manage.py" ]]; then
                echo "Running Django manage.py..."
                python manage.py runserver
            else
                echo "Usage: $0 run <script.py>"
                echo "   or: $0 run -m <module>"
            fi
        else
            python "$@"
        fi
        ;;
    
    "repl"|"shell")
        echo -e "${GREEN}=== PYTHON INTERACTIVE SHELL ===${NC}"
        
        # Try enhanced REPLs first
        if command -v ipython &> /dev/null; then
            ipython
        elif command -v bpython &> /dev/null; then
            bpython
        else
            python
        fi
        ;;
    
    "help"|"")
        echo "Python Helper - Python development tools"
        echo ""
        echo "Usage: ch py <command>"
        echo ""
        echo "Commands:"
        echo "  deps        Show dependencies"
        echo "  test        Run tests"
        echo "  lint        Run linter"
        echo "  format      Check code formatting"
        echo "  venv        Virtual environment info"
        echo "  outdated    Check for outdated packages"
        echo "  audit       Security vulnerability scan"
        echo "  run         Run Python script"
        echo "  repl        Start interactive shell"
        echo ""
        echo "Detected environment:"
        echo "  Package manager: $(detect_python_tools)"
        echo "  Test framework: $(detect_test_framework)"
        [[ -n "${VIRTUAL_ENV:-}" ]] && echo "  Virtual env: Active"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run 'ch py help' for usage"
        exit 1
        ;;
esac