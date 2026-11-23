- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.
- NEVER reply in a language other than English unless I initiate in that language.
- Do not make any changes until you have 95% confidence in what you need to build. Ask me follow-up questions until you reach that confidence.
- If you find code that doesn't conform to written or otherwise reasonable architectural guidelines, propose adding it to the project memory file — don't just fix it silently.

## Workflow
**In planning mode:**
1. Estimate the cost of the work (number of tool calls/requests needed)
2. Alert the user if the estimated cost would consume a significant portion of remaining quota (>10%)

## Plans
- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.
- **ALWAYS** ask me to make the plan multi-phase before starting any work.
- **NEVER** add a Verification section to a plan, in any project. Offer verification only as a suggestion after implementation is done.

## Implementation
- For clojure and clojurescript prefer threading macros to nested function calls, but only when there's more than 1 level of nesting — a single nested call stays as-is.
- Clojure/clojurescript: break too-long lines, threading macros, or fn-arg lists; keep first arg on same line as fn name.

## Code comments
- Use code comments sparingly and keep them short!
- Summarize what it does. Not how or why it was created. Avoid task-specific and transient information
- Don't explain what is obvious from the source code

## Testing
- **ALWAYS** use the value of env var `DB_NAME_TEST` for testing.
- **ALWAYS** run `bin/rspec` instead of `rspec`
- **ALWAYS** run `bin/cucumber` instead of `cucumber`
- **ALWAYS** run `bin/rblint` when working on Ruby specs, unless the project has a lint hook

## Git
- **NEVER** commit automatically.
- **NEVER** amend last commit automatically.
- **ALWAYS** commit by invoking the `/commit` or `/commit-fast` skill — never run `git commit` directly.
- Commit messages: max ~50 chars, imperative, no period, sacrifice grammar for brevity.
- When committing inside a git submodule, don't prefix the message with the submodule's own name.
- All branches must track the same-named branch on origin. Before pushing, check upstream (`git rev-parse --abbrev-ref --symbolic-full-name @{u}`); if mismatched, push by explicit refspec (`git push origin <branch>:<branch>`) with `-u` to fix tracking.

## Applied learning

When something fails repeatedly, when user has to re-explain, or when a workaround is found for a platform/tool limitation, add a one-line bullet here. Keep each bullet under 15 words. No explanations. Only add things that will save time in future sessions. Project-specific stuff only in the project memory.

- Before starting a test server, check the port; if a dev server's there, use port+1.
- After adding/renaming feature specs, check if cider-ci feature-tasks yaml needs regenerating.
- `/code-review` default base = upstream else main; pass range `origin/master...HEAD`.
- Forked skill (`context: fork`) unreliable at awaiting background skills; orchestrate inline.

## Fun stuff

- When I say "birdie birdie" to you, you name a random bird species
