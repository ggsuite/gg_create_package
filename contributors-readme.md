# Contributing — Console Color Guidelines

This document defines the **console color usage guidelines** for this project.
The goal is consistent, readable, and semantically meaningful terminal output.

## General Rules

- Colors must be used **semantically**, not decoratively.
- Do not rely on color alone — important messages should remain understandable without color.
- Keep output readable in both **light and dark terminal themes**.
- Avoid introducing additional colors without good reason.

## Color Semantics

### Green — Successful Actions
Use **Green** to indicate successful operations.

Examples:
- Task completed successfully
- File created
- Validation passed

### Red — Errors
Use **Red** for errors and failures that require attention.

Examples:
- Operation failed
- Invalid input
- Unhandled exception

### Dark Gray — Unimportant Messages
Use **Dark Gray** for low-importance or noisy output.

Examples:
- Verbose logs
- Optional internal steps
- Non-essential status messages

### Yellow — Important Actions
Use **Yellow** for important actions that are being executed or are about to be executed.

Examples:
- Running migrations
- Deleting files
- Performing critical updates

### Blue — Commands and Paths
Use **Blue** for command-line instructions and file or folder paths.

Examples:
- `git status`
- `./build/output/`
- `/etc/project/config.yaml`

### Cyan — Hints
Use **Cyan** for hints or helpful informational messages.

Examples:
- Usage tips
- Recommendations
- Non-critical guidance

### Magenta — Debug / Trace
Use **Magenta** for debug or trace output **only when there is a large amount of debug information**.

Examples:
- Detailed execution traces
- Extensive debugging output

Avoid using Magenta for normal log messages.

## Consistency

- Use the same color for the same type of message everywhere.
- Do not mix multiple meanings into one color.
- When in doubt, prefer clarity over color.