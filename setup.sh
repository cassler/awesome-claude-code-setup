#!/bin/bash

# Setup script to add claude-helpers to your shell

CLAUDE_HELPERS_DIR="/Users/darin/Code/claude-helpers"
SCRIPTS_INSTALL_DIR="$HOME/.claude/scripts"
COMMANDS_INSTALL_DIR="$HOME/.claude/commands"

echo "Setting up Claude helpers..."

# Create directories and copy scripts
echo "Installing bash scripts to $SCRIPTS_INSTALL_DIR..."
mkdir -p "$SCRIPTS_INSTALL_DIR"
cp -f "$CLAUDE_HELPERS_DIR/scripts/"*.sh "$SCRIPTS_INSTALL_DIR/"
chmod +x "$SCRIPTS_INSTALL_DIR/"*.sh

# Copy prompt commands
echo "Installing prompt commands to $COMMANDS_INSTALL_DIR..."
mkdir -p "$COMMANDS_INSTALL_DIR"
cp -f "$CLAUDE_HELPERS_DIR/commands/"*.md "$COMMANDS_INSTALL_DIR/"

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
cat > "$CLAUDE_HELPERS_DIR/CLAUDE_TEMPLATE.md" << 'EOF'
# Project-Specific Claude Instructions

## Helper Scripts Available
Claude has access to helper scripts at: ~/.claude/scripts/

Key scripts to use:
- Start with: `~/.claude/scripts/project-info.sh`
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
echo "To use in a project: cp $CLAUDE_HELPERS_DIR/CLAUDE_TEMPLATE.md ./CLAUDE.md"