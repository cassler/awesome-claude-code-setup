# Deep Dive: Understanding the Codebase

Take a step back and deeply understand this codebase by exploring these questions:

## Questions to Investigate

1. **Architecture & Design**
   - How do the different services communicate with each other?
   - What are the key data flows through the system?
   - Are there any circular dependencies or architectural smells?
   - How is state managed across different components?

2. **Integration Points**
   - How does the AI prompt system connect to Langfuse?
   - What's the relationship between n8n workflows and the prompt playground?
   - How do MCP servers integrate with the main application?
   - Where are the boundaries between services?

3. **Data Flow**
   - How does customer data flow from input to AI processing to output?
   - What gets stored in PostgreSQL vs Redis?
   - How are AI responses tracked and analyzed?
   - What's the lifecycle of a collection workflow?

4. **Hidden Complexity**
   - What assumptions are baked into the code?
   - Are there any implicit dependencies?
   - What edge cases might not be handled?
   - Where might performance bottlenecks occur?

5. **Development Experience**
   - What makes development easy or hard in this codebase?
   - Are there patterns that could be extracted or reused?
   - What's missing from the developer tooling?

## Action Items

1. Pick 2-3 questions that seem most important or unclear
2. Use search and code reading to find concrete answers
3. Challenge any assumptions you've made
4. Update your mental model of how the system works
5. Document any surprising findings or insights
6. Note any potential improvements or concerns

Remember: The goal is to build a deeper, more accurate understanding of the system's actual behavior, not just its intended design.