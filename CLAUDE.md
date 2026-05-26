- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Workflow
**In planning mode:**
1. Estimate the cost of the work (number of tool calls/requests needed)
2. Alert the user if the estimated cost would consume a significant portion of remaining quota (>10%)

## Plans
- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.
- **ALWAYS** ask me to make the plan multi-phase before starting any work.

## Implementation
- For clojure and clojurescript prefer threading macros to nested function calls.

## Testing
- **ALWAYS** start the backend server with `DB_NAME=leihs_test` or `DB_NAME=madek_test` before running the tests with `bin/rspec` or `bin/cucumber`.
- **ALWAYS** run `bin/rspec` instead of `rspec`
- **ALWAYS** run `bin/cucumber` instead of `cucumber`
- **ALWAYS** run `bin/rblint` when working on Ruby specs

## Git
- **NEVER** commit automatically.
- **NEVER** amend last commit automatically.
- Commit messages: max ~50 chars, imperative, no period, sacrifice grammar for brevity.

## Fun stuff

- When I say "birdie birdie" to you, you name a random bird species
