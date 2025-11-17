# Create Subagent

Create a specialized AI subagent for this project that can be invoked for specific tasks.

## What are Subagents?

Subagents are pre-configured AI personalities with:
- **Separate context window** - Prevents main conversation pollution
- **Custom tools** - Specific permissions for focused work
- **Specialized expertise** - Fine-tuned for particular domains
- **Reusable across projects** - Share with team via version control

## Interactive Creation (Recommended)

```bash
# Open subagents interface
/agents
```

Then select "Create New Agent" and:
1. Choose project-level (`.claude/agents/`) or user-level (`~/.claude/agents/`)
2. Generate with Claude first, then customize
3. Select tools to grant access (or leave blank to inherit all)
4. Save and start using immediately

## Manual Creation Workflow

If you prefer to create manually, follow this workflow:

### 1. Define the Subagent Purpose

What task or domain should this subagent handle?
- Code review and quality checks?
- Security scanning and vulnerability detection?
- Test running and debugging?
- Data analysis and SQL queries?
- Documentation generation?
- Performance optimization?

### 2. Determine Tool Access

**Common tool combinations**:

**For code review/analysis**:
- Tools: `Read, Grep, Glob, Bash`
- Can read files, search code, run linters

**For security scanning**:
- Tools: `Read, Grep, Bash`
- Can scan for vulnerabilities, check for secrets

**For debugging**:
- Tools: `Read, Edit, Bash, Grep, Glob`
- Can read, modify files, run tests

**For documentation**:
- Tools: `Read, Write, Bash`
- Can generate and update documentation

### 3. Create the Subagent File

**For project-specific subagent**:
```bash
mkdir -p .claude/agents
```

**File template** (`.claude/agents/your-agent-name.md`):
```markdown
---
name: your-agent-name
description: Brief description of when this agent should be used. Include "use PROACTIVELY" for automatic invocation.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a specialized assistant for [specific domain].

## Your Role
[Describe the agent's expertise and responsibilities]

## When Invoked
[What triggers should activate this agent]

## Your Process
1. [Step-by-step workflow]
2. [What to check or analyze]
3. [How to report findings]

## AwesomeClaude Tools Available
You have access to these efficient helper commands:
- `chp` - Project overview
- `chs find-code "pattern"` - Fast code search
- `ch nlp security file.py` - Security analysis
- `ch nlp complexity file.py` - Complexity analysis
- `ch cq secrets-scan` - Find exposed secrets
- `ch m read-many file1 file2` - Batch file reading

## Output Format
[How to structure your response]
- [What to highlight]
- [How to prioritize findings]
```

### 4. Example Subagents Using AwesomeClaude

**Security Scanner** (`.claude/agents/security-scanner.md`):
```markdown
---
name: security-scanner
description: Security expert. Use PROACTIVELY after code changes to scan for vulnerabilities and exposed secrets.
tools: Read, Grep, Bash
model: sonnet
---

You are a security expert specializing in vulnerability detection.

When invoked:
1. Run `ch cq secrets-scan` to find exposed credentials
2. Run `ch nlp security` on modified files
3. Check for common vulnerabilities with `chs find-code`

Always report:
- Critical issues (must fix immediately)
- Warnings (should fix soon)
- Recommendations (consider implementing)

Include specific line numbers and remediation steps.
```

**Code Quality Reviewer** (`.claude/agents/code-reviewer.md`):
```markdown
---
name: code-reviewer
description: Code quality expert. Use PROACTIVELY after writing or modifying code to ensure quality standards.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards.

When invoked:
1. Run `chp` to understand project context
2. Check git diff to see recent changes
3. Run `ch nlp complexity` on modified files
4. Run `ch nlp smells` to detect code smells
5. Check for duplicates with `ch nlp duplicates`

Review for:
- Readability and clarity
- Proper naming conventions
- No code duplication
- Appropriate complexity levels
- Good documentation coverage

Provide actionable feedback with examples.
```

**Test Runner** (`.claude/agents/test-runner.md`):
```markdown
---
name: test-runner
description: Test automation specialist. MUST BE USED when code changes affect functionality.
tools: Read, Edit, Bash, Grep
model: sonnet
---

You are a test automation expert.

When invoked:
1. Identify which tests to run based on changes
2. Execute appropriate test commands
3. If tests fail, analyze failures using `chs find-code`
4. Fix failing tests while preserving test intent
5. Re-run to verify fixes

For each failure:
- Identify root cause
- Check if code or test is wrong
- Apply minimal fix
- Document the change
```

## 5. Using Your Subagent

**Automatic invocation** (if description includes "PROACTIVELY"):
```
> I just updated the authentication module
[Claude automatically invokes security-scanner subagent]
```

**Explicit invocation**:
```
> Use the code-reviewer subagent to check my recent changes
> Have the security-scanner subagent audit this PR
> Ask the test-runner subagent to fix failing tests
```

**Resume previous work**:
```
> Resume agent abc123 and continue the analysis
```

## 6. Best Practices

1. **Start with generation** - Use `/agents` to generate, then customize
2. **One purpose per agent** - Keep them focused
3. **Include AwesomeClaude helpers** - Leverage our efficient commands
4. **Use descriptive triggers** - Clear description helps automatic invocation
5. **Version control** - Check `.claude/agents/` into git
6. **Test thoroughly** - Verify the subagent works as expected
7. **Iterate and improve** - Refine based on usage

## 7. Manage Existing Subagents

```bash
# View all subagents
/agents

# Edit subagent (opens in editor)
# Select the subagent in /agents interface

# Delete subagent
# Select delete option in /agents interface
```

## Pro Tips

- **Model selection**: Use `inherit` to match main conversation, or specify `sonnet`/`haiku`/`opus`
- **Tool inheritance**: Omit tools field to inherit all tools from main thread
- **Plugin agents**: Plugins can provide custom subagents automatically
- **Team sharing**: Project subagents in `.claude/agents/` are shared with team
- **User agents**: Personal subagents in `~/.claude/agents/` work across all projects

Your subagent is now ready to streamline your workflow!
