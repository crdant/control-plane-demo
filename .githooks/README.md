# Git Hooks

This directory contains custom git hooks for the project.

## Setup

To activate the git hooks, run:

```bash
git config core.hooksPath .githooks
```

Or use the setup target:

```bash
make setup
```

## Available Hooks

### pre-commit

Automatically formats code using `make format` before each commit.

- Runs formatting tools (prettier, black, rustfmt, gofmt) based on what's available
- Stages any files that were reformatted
- Fails the commit if formatting fails
- Shows clear feedback about what was formatted

The hook is designed to be non-disruptive - it will only format files that need it and automatically stage the changes.

## Customization

Modify `.githooks/pre-commit` to add additional checks like:
- Running linters
- Checking commit message format
- Running quick tests
- Validating file sizes

Keep hooks fast - they run on every commit!