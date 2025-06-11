#!/bin/bash

# Claude Helpers Setup Script - Foolproof Edition
# Just run ./setup.sh and follow the prompts!

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Disable strict mode for this script to handle errors gracefully
set +u
set +e

echo -e "${BLUE}🚀 Claude Helpers Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse command line arguments
SKIP_PROMPTS=false
AUTO_INSTALL=false
for arg in "$@"; do
    case $arg in
        --yes|-y)
            SKIP_PROMPTS=true
            AUTO_INSTALL=true
            ;;
        --help|-h)
            echo "Usage: ./setup.sh [options]"
            echo ""
            echo "Options:"
            echo "  --yes, -y     Auto-confirm all prompts (install everything)"
            echo "  --help, -h    Show this help message"
            echo ""
            echo "Just run ./setup.sh without options for interactive setup!"
            exit 0
            ;;
    esac
done

# Set up directories
CLAUDE_HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_INSTALL_DIR="$HOME/.claude/scripts"
COMMANDS_INSTALL_DIR="$HOME/.claude/commands"

# If running via curl, clone the repo first
if [ ! -d "$CLAUDE_HELPERS_DIR/scripts" ]; then
    echo -e "${YELLOW}📥 Downloading claude-helpers...${NC}"
    TEMP_DIR="/tmp/claude-helpers-setup-$$"
    if git clone https://github.com/cassler/awesome-claude-code-setup.git "$TEMP_DIR" 2>/dev/null; then
        CLAUDE_HELPERS_DIR="$TEMP_DIR"
        echo -e "${GREEN}✅ Downloaded successfully${NC}"
    else
        echo -e "${RED}❌ Failed to download claude-helpers${NC}"
        echo "Please check your internet connection and try again."
        exit 1
    fi
fi

# Detect OS and package manager
detect_platform() {
    local os=""
    local pkg_manager=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os="macOS"
        if command -v brew &> /dev/null; then
            pkg_manager="brew"
        else
            pkg_manager="none"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os="Linux"
        if command -v apt &> /dev/null; then
            pkg_manager="apt"
        elif command -v yum &> /dev/null; then
            pkg_manager="yum"
        elif command -v dnf &> /dev/null; then
            pkg_manager="dnf"
        elif command -v pacman &> /dev/null; then
            pkg_manager="pacman"
        else
            pkg_manager="unknown"
        fi
    else
        os="Unknown OS"
        pkg_manager="unknown"
    fi
    
    echo -e "${BLUE}🖥️  System:${NC} $os"
    echo -e "${BLUE}📦 Package Manager:${NC} ${pkg_manager:-Not found}"
    echo ""
    
    OS="$os"
    PKG_MANAGER="$pkg_manager"
}

# Install Homebrew on macOS if not present
install_homebrew() {
    if [[ "$OS" == "macOS" ]] && [[ "$PKG_MANAGER" == "none" ]]; then
        echo -e "${YELLOW}Homebrew is not installed on your Mac.${NC}"
        echo "Homebrew is recommended for installing optional tools."
        echo ""
        
        if [ "$SKIP_PROMPTS" = true ]; then
            response="y"
        else
            echo -n "Would you like to install Homebrew now? [Y/n] "
            read -r response
            response=${response:-y}
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}📥 Installing Homebrew...${NC}"
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                # Add Homebrew to PATH for this session
                if [[ -d "/opt/homebrew" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                PKG_MANAGER="brew"
                echo -e "${GREEN}✅ Homebrew installed successfully${NC}"
            else
                echo -e "${RED}❌ Failed to install Homebrew${NC}"
                echo "Continuing without package manager..."
            fi
        fi
        echo ""
    fi
}

# Check if we need sudo for package installation
check_sudo() {
    if [[ "$PKG_MANAGER" =~ ^(apt|yum|dnf|pacman)$ ]]; then
        if ! sudo -n true 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Some tools require administrator access to install.${NC}"
            echo "You may be prompted for your password."
            echo ""
            sudo true || {
                echo -e "${RED}❌ Cannot get administrator access${NC}"
                echo "Continuing without installing system packages..."
                return 1
            }
        fi
    fi
    return 0
}

# Install core scripts
install_core_scripts() {
    echo -e "${BLUE}📂 Installing core scripts...${NC}"
    
    # Create directories
    mkdir -p "$SCRIPTS_INSTALL_DIR"
    mkdir -p "$COMMANDS_INSTALL_DIR"
    
    # Copy scripts
    if cp -f "$CLAUDE_HELPERS_DIR/scripts/"*.sh "$SCRIPTS_INSTALL_DIR/" 2>/dev/null; then
        chmod +x "$SCRIPTS_INSTALL_DIR/"*.sh
        echo -e "${GREEN}✅ Scripts installed to $SCRIPTS_INSTALL_DIR${NC}"
    else
        echo -e "${RED}❌ Failed to copy scripts${NC}"
        return 1
    fi
    
    # Copy commands
    if cp -f "$CLAUDE_HELPERS_DIR/commands/"*.md "$COMMANDS_INSTALL_DIR/" 2>/dev/null; then
        echo -e "${GREEN}✅ Commands installed to $COMMANDS_INSTALL_DIR${NC}"
    else
        echo -e "${RED}❌ Failed to copy commands${NC}"
        return 1
    fi
    
    echo ""
    return 0
}

# Add aliases to shell config
setup_shell_aliases() {
    echo -e "${BLUE}🐚 Setting up shell aliases...${NC}"
    
    # Detect shell config file
    local shell_rc=""
    if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    else
        # Create .bashrc if no config exists
        shell_rc="$HOME/.bashrc"
        touch "$shell_rc"
    fi
    
    # Define the markers
    local start_marker="# BEGIN CLAUDE HELPER SCRIPTS"
    local end_marker="# END CLAUDE HELPER SCRIPTS"
    
    # First, clean up any old entries without markers (from previous versions)
    if grep -q "claude-helper.sh" "$shell_rc" 2>/dev/null && ! grep -q "$start_marker" "$shell_rc" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Found old claude-helpers configuration${NC}"
        echo "Cleaning up previous installation..."
        
        # Create backup
        cp "$shell_rc" "${shell_rc}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Remove old entries
        local temp_file="${shell_rc}.tmp.$$"
        grep -v "CLAUDE_HELPERS" "$shell_rc" | \
        grep -v "alias ch=.*claude-helper.sh" | \
        grep -v "alias chp=.*project-info.sh" | \
        grep -v "alias chs=.*search-tools.sh" | \
        grep -v "alias chg=.*git-ops.sh" | \
        grep -v "^# Claude Helper Scripts$" > "$temp_file"
        
        mv "$temp_file" "$shell_rc"
        echo -e "${GREEN}✅ Cleaned up old entries${NC}"
    fi
    
    # Check if markers exist
    if grep -q "$start_marker" "$shell_rc" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Claude helpers already configured${NC}"
        echo "Updating to latest version..."
        
        # Create a temp file without the claude section
        local temp_file="${shell_rc}.tmp.$$"
        awk -v start="$start_marker" -v end="$end_marker" '
            $0 == start { skip = 1; next }
            $0 == end { skip = 0; next }
            !skip { print }
        ' "$shell_rc" > "$temp_file"
        
        # Move temp file back
        mv "$temp_file" "$shell_rc"
        echo -e "${GREEN}✅ Removed old configuration${NC}"
    fi
    
    # Add the new configuration with markers
    {
        echo ""
        echo "$start_marker"
        echo "# Added by claude-helpers setup script on $(date)"
        echo "# To remove, delete everything between BEGIN and END markers"
        echo "export CLAUDE_HELPERS=\"$SCRIPTS_INSTALL_DIR\""
        echo "alias ch='$SCRIPTS_INSTALL_DIR/claude-helper.sh'"
        echo "alias chp='$SCRIPTS_INSTALL_DIR/project-info.sh'"
        echo "alias chs='$SCRIPTS_INSTALL_DIR/search-tools.sh'"
        echo "alias chg='$SCRIPTS_INSTALL_DIR/git-ops.sh'"
        echo "$end_marker"
        echo ""
    } >> "$shell_rc"
    
    echo -e "${GREEN}✅ Added aliases to $shell_rc${NC}"
    
    # Create template
    local template_path="$HOME/.claude/CLAUDE_TEMPLATE.md"
    if cp "$CLAUDE_HELPERS_DIR/CLAUDE_TEMPLATE.md" "$template_path" 2>/dev/null; then
        echo -e "${GREEN}✅ Created template at $template_path${NC}"
    else
        # Create a basic template if copy fails
        cat > "$template_path" << 'EOF'
# Project-Specific Claude Instructions

## Helper Scripts Available
You have access to helper scripts via these aliases:
- ch  - Main helper menu
- chp - Project overview
- chs - Search tools
- chg - Git operations

## Project Notes
[Add project-specific instructions here]
EOF
        echo -e "${GREEN}✅ Created template at $template_path${NC}"
    fi
    
    echo ""
    SHELL_RC="$shell_rc"
}

# Check and install optional tools
check_optional_tools() {
    echo -e "${BLUE}🔍 Checking optional tool enhancements...${NC}"
    echo ""
    
    # Check what's installed
    local missing_tools=()
    local found_tools=()
    
    # Check each tool individually (bash 3 compatible)
    # fzf
    if command -v fzf &> /dev/null; then
        echo -e "${GREEN}✅ fzf${NC} - Interactive file/text selection"
        found_tools+=("fzf")
    else
        echo -e "${YELLOW}⚪ fzf${NC} - Interactive file/text selection (not installed)"
        missing_tools+=("fzf")
    fi
    
    # jq
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}✅ jq${NC} - JSON parsing and manipulation"
        found_tools+=("jq")
    else
        echo -e "${YELLOW}⚪ jq${NC} - JSON parsing and manipulation (not installed)"
        missing_tools+=("jq")
    fi
    
    # bat
    if command -v bat &> /dev/null; then
        echo -e "${GREEN}✅ bat${NC} - Syntax-highlighted file viewing"
        found_tools+=("bat")
    else
        echo -e "${YELLOW}⚪ bat${NC} - Syntax-highlighted file viewing (not installed)"
        missing_tools+=("bat")
    fi
    
    # gum
    if command -v gum &> /dev/null; then
        echo -e "${GREEN}✅ gum${NC} - Beautiful interactive prompts"
        found_tools+=("gum")
    else
        echo -e "${YELLOW}⚪ gum${NC} - Beautiful interactive prompts (not installed)"
        missing_tools+=("gum")
    fi
    
    # delta
    if command -v delta &> /dev/null; then
        echo -e "${GREEN}✅ delta${NC} - Enhanced git diffs"
        found_tools+=("delta")
    else
        echo -e "${YELLOW}⚪ delta${NC} - Enhanced git diffs (not installed)"
        missing_tools+=("delta")
    fi
    
    # ripgrep
    if command -v rg &> /dev/null || command -v ripgrep &> /dev/null; then
        echo -e "${GREEN}✅ ripgrep${NC} - Fast file content searching"
        found_tools+=("ripgrep")
    else
        echo -e "${YELLOW}⚪ ripgrep${NC} - Fast file content searching (not installed)"
        missing_tools+=("ripgrep")
    fi
    
    # If tools are missing and we have a package manager
    if [ ${#missing_tools[@]} -gt 0 ] && [ "$PKG_MANAGER" != "none" ] && [ "$PKG_MANAGER" != "unknown" ]; then
        echo ""
        echo -e "${YELLOW}📦 Optional tools can enhance your experience!${NC}"
        echo "These tools enable advanced features like better search,"
        echo "interactive selection, and syntax highlighting."
        echo ""
        
        if [ "$AUTO_INSTALL" = true ]; then
            response="y"
        else
            echo -n "Would you like to install the missing tools? [Y/n] "
            read -r response
            response=${response:-y}
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_optional_tools "${missing_tools[@]}"
        else
            echo -e "${BLUE}Skipping optional tools.${NC}"
        fi
    elif [ ${#missing_tools[@]} -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 All optional tools are already installed!${NC}"
    fi
    
    echo ""
}

# Install optional tools
install_optional_tools() {
    local tools=("$@")
    
    echo ""
    echo -e "${BLUE}📦 Installing optional tools...${NC}"
    
    # Check sudo if needed
    if [[ "$PKG_MANAGER" =~ ^(apt|yum|dnf|pacman)$ ]]; then
        if ! check_sudo; then
            echo -e "${YELLOW}Skipping tools that require admin access${NC}"
            return
        fi
    fi
    
    for tool in "${tools[@]}"; do
        echo -n "Installing $tool... "
        
        case "$PKG_MANAGER:$tool" in
            # macOS with Homebrew
            brew:*)
                if brew install "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            
            # Ubuntu/Debian special cases
            apt:ripgrep)
                if sudo apt-get update &> /dev/null && sudo apt-get install -y ripgrep &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            apt:bat)
                if sudo apt-get install -y bat &> /dev/null; then
                    # Create symlink for batcat -> bat
                    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            apt:fzf|apt:jq)
                if sudo apt-get install -y "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            apt:delta|apt:gum)
                echo -e "${YELLOW}⚠️  Manual install needed${NC}"
                case "$tool" in
                    delta) echo "   Visit: https://github.com/dandavison/delta" ;;
                    gum) echo "   Visit: https://github.com/charmbracelet/gum" ;;
                esac
                ;;
            
            # Other package managers
            yum:*|dnf:*)
                if sudo "$PKG_MANAGER" install -y "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            pacman:*)
                if sudo pacman -S --noconfirm "$tool" &> /dev/null; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                fi
                ;;
            *)
                echo -e "${YELLOW}⚠️  Cannot auto-install${NC}"
                ;;
        esac
    done
}

# Create or update global CLAUDE.md with XML formatting
setup_global_claude_md() {
    local claude_md="$HOME/.claude/CLAUDE.md"
    local backup_file="$HOME/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)"
    
    echo -e "${BLUE}📝 Setting up global CLAUDE.md...${NC}"
    
    # Backup existing file if it exists
    if [ -f "$claude_md" ]; then
        cp "$claude_md" "$backup_file"
        echo -e "${YELLOW}⚠️  Backed up existing CLAUDE.md to $backup_file${NC}"
    fi
    
    # Create the new global CLAUDE.md with XML sections - CONCISE version
    cat > "$claude_md" << 'EOF'
# Claude Helper Scripts

<ch:aliases>
ch   → Main helper: ch [category] [command]
chp  → Project overview (run first in new projects)
chs  → Search tools: find-code, find-file, search-imports
chg  → Git ops: quick-commit, pr-ready, diff
</ch:aliases>

<ch:categories>
project|p         → Project analysis
docker|d          → Container ops: ps, logs, shell, inspect
git|g             → Git workflows
search|s          → Code search (needs: ripgrep)
ts|node           → TypeScript/Node.js (needs: jq)
multi|m           → Multi-file ops (uses: bat)
env|e             → Environment checks
api               → API testing (needs: jq, httpie)
interactive|i     → Interactive tools (needs: fzf, gum)
context|ctx       → Context generation
code-relationships|cr → Dependency analysis
code-quality|cq   → Quality checks
</ch:categories>

<ch:key-commands>
# Start with project overview
chp

# Use helpers not raw commands
chs find-code "pattern"      # not grep
ch m read-many f1 f2 f3      # not multiple cats
chg quick-commit "msg"       # not git add && commit
ch i select-file             # interactive file picker
ch ctx for-task "desc"       # generate focused context
ch api test /endpoint        # test APIs
</ch:key-commands>

<ch:required-tools>
ripgrep → search-tools.sh
jq      → project-info.sh, ts-helper.sh, api-helper.sh
fzf     → interactive selections
bat     → syntax highlighting
gum     → interactive prompts
delta   → enhanced diffs
</ch:required-tools>

<ch:paths>
Scripts: ~/.claude/scripts/
Commands: ~/.claude/commands/
</ch:paths>

<ch:user-customizations>
<!-- User additions preserved here -->
</ch:user-customizations>
EOF
    
    echo -e "${GREEN}✅ Created global CLAUDE.md at $claude_md${NC}"
    
    # If there was an existing file, offer to show diff
    if [ -f "$backup_file" ]; then
        echo ""
        echo -e "${YELLOW}Your previous CLAUDE.md was backed up.${NC}"
        echo "You may want to review it and move any custom content to the <ch:user-customizations> section."
    fi
}

# Main setup flow
main() {
    # Step 1: Detect platform
    detect_platform
    
    # Step 2: Install Homebrew on macOS if needed
    if [[ "$OS" == "macOS" ]]; then
        install_homebrew
    fi
    
    # Step 3: Install core scripts
    if ! install_core_scripts; then
        echo -e "${RED}❌ Failed to install core scripts${NC}"
        exit 1
    fi
    
    # Step 4: Setup shell aliases
    setup_shell_aliases
    
    # Step 5: Create/update global CLAUDE.md
    setup_global_claude_md
    
    # Step 6: Check and offer to install optional tools
    check_optional_tools
    
    # Final instructions
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ Setup Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}📝 Quick Start:${NC}"
    echo "1. Reload your shell config:"
    echo -e "   ${YELLOW}source $SHELL_RC${NC}"
    echo ""
    echo "2. Try the main helper:"
    echo -e "   ${YELLOW}ch${NC}"
    echo ""
    echo "3. In any project, create a CLAUDE.md file:"
    echo -e "   ${YELLOW}cp ~/.claude/CLAUDE_TEMPLATE.md ./CLAUDE.md${NC}"
    echo ""
    echo -e "${BLUE}Enjoy your enhanced Claude experience! 🚀${NC}"
    
    # Cleanup temp directory if used
    if [[ "$CLAUDE_HELPERS_DIR" =~ ^/tmp/claude-helpers-setup- ]]; then
        rm -rf "$CLAUDE_HELPERS_DIR"
    fi
}

# Run main setup
main

# Make sure we exit successfully
exit 0