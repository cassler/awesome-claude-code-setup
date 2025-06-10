#!/bin/bash

# Setup script to add claude-helpers to your shell with optional tool enhancements

# Parse command line arguments
INSTALL_TOOLS=false
for arg in "$@"; do
    case $arg in
        --install-tools)
            INSTALL_TOOLS=true
            shift
            ;;
        --help|-h)
            echo "Claude Helpers Setup"
            echo ""
            echo "Usage: ./setup.sh [options]"
            echo ""
            echo "Options:"
            echo "  --install-tools    Automatically install optional tool enhancements"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "Optional tools include: fzf, jq, bat, gum, delta, ripgrep"
            exit 0
            ;;
    esac
done

# Source common functions if available
if [ -f "scripts/common-functions.sh" ]; then
    source scripts/common-functions.sh
elif [ -f "$HOME/.claude/scripts/common-functions.sh" ]; then
    source "$HOME/.claude/scripts/common-functions.sh"
fi

# If running via curl, clone the repo first
if [ ! -d "scripts" ]; then
    echo "Downloading claude-helpers..."
    git clone https://github.com/cassler/awesome-claude-code-setup.git /tmp/claude-helpers-setup
    cd /tmp/claude-helpers-setup
    CLAUDE_HELPERS_DIR="/tmp/claude-helpers-setup"
else
    CLAUDE_HELPERS_DIR="$(pwd)"
fi
SCRIPTS_INSTALL_DIR="$HOME/.claude/scripts"
COMMANDS_INSTALL_DIR="$HOME/.claude/commands"

echo "Setting up Claude helpers..."

# Detect OS and package manager
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if command -v brew &> /dev/null; then
            PKG_MANAGER="brew"
        else
            echo "⚠️  Homebrew not found on macOS"
            echo "   Install from: https://brew.sh"
            echo "   Continuing with basic setup..."
            PKG_MANAGER="none"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if command -v apt &> /dev/null; then
            PKG_MANAGER="apt"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
        elif command -v pacman &> /dev/null; then
            PKG_MANAGER="pacman"
        else
            PKG_MANAGER="unknown"
        fi
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
    
    echo "🖥️  Detected: $OS with $PKG_MANAGER package manager"
}

# Check for optional tools
check_optional_tools() {
    echo ""
    echo "🔍 Checking for optional tool enhancements..."
    
    # Define optional tools and their benefits
    declare -A TOOLS=(
        ["fzf"]="Interactive file/text selection"
        ["jq"]="JSON parsing and manipulation"
        ["bat"]="Syntax-highlighted file viewing"
        ["gum"]="Beautiful interactive prompts"
        ["delta"]="Enhanced git diffs"
        ["ripgrep"]="Fast file content searching"
    )
    
    # Track missing tools
    MISSING_TOOLS=()
    FOUND_TOOLS=()
    
    for tool in "${!TOOLS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "✅ $tool - ${TOOLS[$tool]}"
            FOUND_TOOLS+=("$tool")
        else
            echo "⚪ $tool - ${TOOLS[$tool]} (not installed)"
            MISSING_TOOLS+=("$tool")
        fi
    done
    
    # Offer to install missing tools
    if [ ${#MISSING_TOOLS[@]} -gt 0 ] && [ "$PKG_MANAGER" != "none" ] && [ "$PKG_MANAGER" != "unknown" ]; then
        if [ "$INSTALL_TOOLS" = true ]; then
            echo ""
            echo "🚀 Installing optional enhancements automatically..."
            install_optional_tools
        else
            echo ""
            echo "🚀 Would you like to install optional enhancements?"
            echo "   These tools enable advanced features but are not required."
            echo ""
            echo -n "Install missing tools? [y/N] "
            read -r response
            
            if [[ "$response" =~ ^[Yy]$ ]]; then
                install_optional_tools
            else
                echo "Continuing with basic setup..."
            fi
        fi
    fi
}

# Install optional tools based on package manager
install_optional_tools() {
    echo ""
    echo "📦 Installing optional tools..."
    
    for tool in "${MISSING_TOOLS[@]}"; do
        echo -n "Installing $tool... "
        case $PKG_MANAGER in
            brew)
                if brew install "$tool" &> /dev/null; then
                    echo "✅"
                else
                    echo "❌ Failed"
                fi
                ;;
            apt)
                # Special handling for some tools on apt
                case $tool in
                    "ripgrep")
                        if sudo apt-get update &> /dev/null && sudo apt-get install -y ripgrep &> /dev/null; then
                            echo "✅"
                        else
                            echo "❌ Failed"
                        fi
                        ;;
                    "bat")
                        if sudo apt-get install -y bat &> /dev/null; then
                            echo "✅"
                            # Create alias for batcat -> bat on Ubuntu/Debian
                            mkdir -p "$HOME/.local/bin"
                            ln -sf /usr/bin/batcat "$HOME/.local/bin/bat" 2>/dev/null
                        else
                            echo "❌ Failed"
                        fi
                        ;;
                    "delta")
                        echo "❌ (manual install required - see https://github.com/dandavison/delta)"
                        ;;
                    "gum")
                        echo "❌ (manual install required - see https://github.com/charmbracelet/gum)"
                        ;;
                    *)
                        if sudo apt-get install -y "$tool" &> /dev/null; then
                            echo "✅"
                        else
                            echo "❌ Failed"
                        fi
                        ;;
                esac
                ;;
            yum|dnf)
                if sudo $PKG_MANAGER install -y "$tool" &> /dev/null; then
                    echo "✅"
                else
                    echo "❌ Failed"
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm "$tool" &> /dev/null; then
                    echo "✅"
                else
                    echo "❌ Failed"
                fi
                ;;
        esac
    done
}

# Run platform detection
detect_platform

# Create directories and copy scripts
echo "Installing bash scripts to $SCRIPTS_INSTALL_DIR..."
mkdir -p "$SCRIPTS_INSTALL_DIR"
cp -f "$CLAUDE_HELPERS_DIR/scripts/"*.sh "$SCRIPTS_INSTALL_DIR/"
chmod +x "$SCRIPTS_INSTALL_DIR/"*.sh

# Copy prompt commands
echo "Installing prompt commands to $COMMANDS_INSTALL_DIR..."
mkdir -p "$COMMANDS_INSTALL_DIR"
cp -f "$CLAUDE_HELPERS_DIR/commands/"*.md "$COMMANDS_INSTALL_DIR/"

# Check for optional tools after basic setup
check_optional_tools

# Add to ~/.bashrc or ~/.zshrc
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    # Check if already added
    if ! grep -q "claude-helpers" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Claude Helper Scripts" >> "$SHELL_RC"
        echo "export CLAUDE_HELPERS=\"$SCRIPTS_INSTALL_DIR\"" >> "$SHELL_RC"
        echo "alias ch='$SCRIPTS_INSTALL_DIR/claude-helper.sh'" >> "$SHELL_RC"
        echo "alias chp='$SCRIPTS_INSTALL_DIR/project-info.sh'" >> "$SHELL_RC"
        echo "alias chs='$SCRIPTS_INSTALL_DIR/search-tools.sh'" >> "$SHELL_RC"
        echo "alias chg='$SCRIPTS_INSTALL_DIR/git-ops.sh'" >> "$SHELL_RC"
        echo "" >> "$SHELL_RC"
        
        echo "✓ Added aliases to $SHELL_RC"
        echo ""
        echo "Aliases added:"
        echo "  ch  - Main claude helper"
        echo "  chp - Project info"
        echo "  chs - Search tools"
        echo "  chg - Git operations"
        echo ""
        echo "Run: source $SHELL_RC"
    else
        echo "Claude helpers already in $SHELL_RC - updating scripts..."
        # Just update the scripts and commands even if aliases exist
        cp -f "$CLAUDE_HELPERS_DIR/scripts/"*.sh "$SCRIPTS_INSTALL_DIR/"
        chmod +x "$SCRIPTS_INSTALL_DIR/"*.sh
        cp -f "$CLAUDE_HELPERS_DIR/commands/"*.md "$COMMANDS_INSTALL_DIR/"
        echo "✓ Scripts updated in $SCRIPTS_INSTALL_DIR"
        echo "✓ Commands updated in $COMMANDS_INSTALL_DIR"
    fi
fi

# Create a global CLAUDE.md template
TEMPLATE_PATH="$HOME/.claude/CLAUDE_TEMPLATE.md"
cat > "$TEMPLATE_PATH" << 'EOF'
# Project-Specific Claude Instructions

## Helper Scripts Available
Claude has access to helper scripts at: ~/.claude/scripts/

Key scripts to use:
- Start with: `~/.claude/scripts/project-info.sh`
- Generate context: `~/.claude/scripts/claude-context.sh for-task "your task"`
- Search code: `~/.claude/scripts/search-tools.sh find-code "pattern"`
- Git ops: `~/.claude/scripts/git-ops.sh status`

## Project-Specific Notes
[Add project-specific instructions here]

## Common Commands
[Add frequently used commands for this project]
EOF

echo "✓ Created CLAUDE_TEMPLATE.md"
echo ""
echo "Setup complete!"
echo ""
echo "📁 Bash scripts installed to: $SCRIPTS_INSTALL_DIR/"
echo "📄 Prompt commands installed to: $COMMANDS_INSTALL_DIR/"
echo ""

# Show summary of tool availability
echo "🛠️  Tool Enhancement Status:"
if [ ${#FOUND_TOOLS[@]} -gt 0 ]; then
    echo "   Enhanced features available with: ${FOUND_TOOLS[*]}"
fi
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "   Optional tools not installed: ${MISSING_TOOLS[*]}"
    echo "   Run 'ch env tools' to see installation instructions"
fi

echo ""
echo "To use in a project: cp ~/.claude/CLAUDE_TEMPLATE.md ./CLAUDE.md"

# Cleanup temp directory if we used it
if [ "$CLAUDE_HELPERS_DIR" = "/tmp/claude-helpers-setup" ]; then
    rm -rf /tmp/claude-helpers-setup
fi