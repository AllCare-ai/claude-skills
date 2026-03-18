# Orchestrator Skill

Multi-task orchestrator that plans, delegates to parallel subagents in waves, coordinates results, and verifies completeness.

## Usage

```
/orchestrate <task list or plan description>
```

The orchestrator will:
1. Analyze tasks and identify dependencies
2. Group into parallel waves
3. Delegate each task to a subagent
4. Coordinate results between waves
5. Run final verification

## Example

```
/orchestrate
1. Add timezone support to patient forms
2. Update eMAR med pass to show local time
3. Fix date formatting in provider schedule
4. Add timezone selector to settings page
```
