---
name: release
description: This skill should be used when the user asks to "make a release", "create release", "release leihs", or "/release". Automates Leihs RC.1, RC.2, and stable release workflows following the zhdk-intern process with multi-phase execution and user confirmations.
version: 1.0.0
---

# Leihs Release Automation

## Overview

Automate the Leihs release process (RC.1, RC.2, and stable releases) following the established workflow documented in the zhdk-intern repository. This skill handles all aspects of releasing: git operations, branch management, tagging, pull requests, GitHub releases, release notes formatting, and version bumping.

The workflow follows a multi-phase approach with user confirmation at each major checkpoint, ensuring safe and controlled releases. All steps are based on the canonical documentation in `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/`.

## When to Use This Skill

Use this skill when creating any of the following release types:

**RC.1 (Release Candidate 1):** Create the first release candidate from the master branch. This is the most common workflow, used when releasing a new version with accumulated changes from development.

**RC.2 (Release Candidate 2+):** Create a subsequent release candidate when issues are found during RC.1 testing. RC.2 includes cherry-picked fixes on top of the existing release candidate.

**Stable:** Promote a tested release candidate to stable, or create a stable release directly from master (less common). This is the final production-ready version.

## Prerequisites

Before starting a release, ensure the following are in place:

- Git signing key configured for creating signed tags
- Access to ci.zhdk.ch for CI/CD verification
- GitHub CLI (`gh`) authenticated
- Access to Slack channel #everybody-leihs for announcements
- zhdk-intern repository available at `/Users/nitaai/src/work/ZHdK/zhdk-intern`

## Workflow Instructions

### Step 1: Determine Release Type

Ask the user which type of release to create (RC.1, RC.2, or stable). Based on their answer, read the corresponding workflow file:

- **RC.1:** Read `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/RC.1.md`
- **RC.2:** Read `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/RC.2.md`
- **Stable:** Read `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/stable.md`

### Step 2: Ask for Version Number

Prompt the user for the version number to release. Examples:
- For RC.1: "7.12.0" (will become 7.12.0-RC.1)
- For RC.2: "7.12.0" (will become 7.12.0-RC.2)
- For stable: "7.12.0" (final version)

### Step 3: Execute Multi-Phase Workflow

Follow the workflow from the zhdk-intern documentation file with these five distinct phases. After each phase, stop and ask for user confirmation before proceeding.

## RC.1 Workflow Details

For RC.1 releases, follow this five-phase process:

### Phase 1: Preparation & Branch Creation

**Actions:**
1. Fetch all branches and submodules: `git fetch --all --recurse-submodules`
2. Checkout the base branch (typically `origin/master`): `git checkout origin/master && git submodule update --recursive --force --init`
3. Edit `./dev/release-env.sh` to set:
   - `RELEASE_MAJOR_MINOR` (e.g., 7.12)
   - `RELEASE_PATCH` (e.g., 0)
   - `RELEASE_PRE='-RC.1'`
4. Source the environment file: `source ./dev/release-env.sh`
5. Create work branch: `git checkout -B $DEV_INITIALS/v/$RELEASE_MAJOR_MINOR-staging`
6. Stash the release-env.sh file: `git stash`
7. Update `LEIHS-VERSION` file with the release version (e.g., "7.12.0-RC.1")
8. Pop the stash, add all files, and commit: `git stash pop && git add . && git commit -m "release: $RELEASE_NAME"`
9. Set RELEASE_REF: `export RELEASE_REF="$(git log -n1 --format="%H" HEAD)"`
10. Push to personal branch: `git push -f origin "$RELEASE_REF:refs/heads/$DEV_INITIALS/v/$RELEASE_MAJOR_MINOR-staging"`

**Stop Point:** Review commit before pushing to release branches

### Phase 2: Push & CI Verification

**Actions:**
1. Push to official release branches:
   - `git push -f origin "$RELEASE_REF:refs/heads/v/$RELEASE_MAJOR_MINOR-staging"`
   - `git push -f origin "$RELEASE_REF:refs/heads/zhdk/staging"`
2. Open CI for verification: `open "https://ci.zhdk.ch/cider-ci/trees/$(git cat-file -p $RELEASE_REF | grep tree | awk '{print $2}')"`
3. Verify all integration and other tests are green

**Stop Point:** Confirm CI tests are green before creating PR and tags

### Phase 3: PR & Release Creation

**Actions:**
1. Create pull request: `gh pr create --title "release: $RELEASE_NAME" --body "Release candidate $RELEASE_NAME" --base stable --assignee @me`
2. Create signed git tag: `git tag --sign -f "$RELEASE_NAME" -m "$RELEASE_NAME" $RELEASE_REF && git push origin $RELEASE_NAME`
3. Tag all submodules: `./dev/git-tag-submodules "$RELEASE_NAME"`
4. Create GitHub prerelease: `gh release create $RELEASE_NAME --prerelease --title "Leihs $RELEASE_NAME"`
5. Generate release notes: `./dev/git-release-notes`
6. Format release notes according to rules (see Release Notes Formatting section below)
7. Update GitHub release with formatted notes: `gh release edit $RELEASE_NAME --notes "..."`

**Stop Point:** Review GitHub release before deployment

### Phase 4: Deploy & Announce

**Actions:**
1. Inform user to run "Deploy to staging.ruby.zhdk.ch" job from ci.zhdk.ch (manual step)
2. Prepare Slack announcement: `:bellhop_bell: Leihs $RELEASE_NAME was released :rocket: https://github.com/leihs/leihs/releases/tag/$RELEASE_NAME and is being deployed to https://staging.leihs.zhdk.ch`
3. Remind user to post in #everybody-leihs

**Stop Point:** Verify deployment before version bump

### Phase 5: Master Version Bump

**Actions (only if RC started from master):**
1. Checkout master: `git checkout origin/master`
2. Create version bump branch: `git checkout -B $DEV_INITIALS/leihs-version`
3. Update `LEIHS-VERSION` file to next version with `-beta` suffix (e.g., 7.12.0-beta → 7.13.0-beta)
4. Commit and push: `git add . && git commit -m 'chore: bump leihs version' && git push origin -f HEAD:$DEV_INITIALS/leihs-version`
5. Wait for CI to pass on the version bump branch
6. Push to master: `git push origin HEAD:master`
7. Cleanup: `git checkout origin/master && git branch -D $DEV_INITIALS/leihs-version && git push origin :$DEV_INITIALS/leihs-version`

**Stop Point:** Complete

## Release Notes Formatting

After generating release notes with `./dev/git-release-notes`, apply these formatting rules before updating the GitHub release:

### Remove Entirely
- "inventory" section (all items)
- "integration-tests" section (all items)

### Remove from All Other Sections
- All items prefixed with "chore:" EXCEPT in the "deploy" section
- Dependency updates (e.g., "update db", "update shared-clj", "npm audit fix")
- Build tool updates (e.g., "Support mise", "Update database")
- Refactor commits (e.g., "refactor: use autocomplete component")

### Keep
- All items prefixed with "feat:" (features)
- All items prefixed with "fix:" (bug fixes)
- Chore items in "deploy" section only (infrastructure changes)

### Format Requirements
- All items lowercase
- Properly prefixed with "feat:" or "fix:"
- For deploy section, "chore:" is allowed

### Add Highlight Section
At the very top of the release notes, add a highlight for notable features:
- Use prose format (complete sentence)
- Bold the text
- Mention the repo/module name
- Example: `**Borrow module now supports French (Switzerland) translation.**`
- Add horizontal rule (`---`) separator after highlight

### Example
See `examples/release-notes-example.md` for a complete before/after example from release 7.12.0-RC.1.

## Important Notes

- Always follow the zhdk-intern documentation exactly as written
- Never skip phase confirmations
- If CI tests fail, stop and investigate before proceeding
- For RC.2 and stable workflows, read the corresponding files from zhdk-intern
- The master version bump (Phase 5) only applies when RC started from master, not from stable
- Release notes formatting is critical for user communication - be thorough in cleanup

## Commands Reference

Key commands used throughout the workflow:

- `source ./dev/release-env.sh` - Load release version variables
- `./dev/git-tag-submodules "$RELEASE_NAME"` - Tag all git submodules
- `./dev/git-release-notes` - Generate release notes from git submodule commits
- `gh pr create --body "..." --base stable` - Create pull request via GitHub CLI
- `gh release create --prerelease` - Create GitHub release as prerelease
- `gh release edit --notes "..."` - Update release notes on GitHub

## Additional Resources

For other release types:
- **RC.2 workflow:** Read `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/RC.2.md`
- **Stable workflow:** Read `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/stable.md`

Source documentation: `/Users/nitaai/src/work/ZHdK/zhdk-intern/release-process/leihs/`
