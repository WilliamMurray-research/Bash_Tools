# Resource Tracking Scripts

Small Bash tools for tracking CPU, GPU, RAM, storage, network usage, and
energy/valuation metrics during interactive work or during a specific job.

These scripts log all metrics into `resource_log.csv` so I can keep a record
of compute usage, cost, and system behaviour over time.

## Included Scripts

### track_interactive.sh
Tracks system usage while doing manual work (sorting documents, research,
writing, etc.).  
Press CTRL+C to stop and save the session.

Usage:
    bash track_interactive.sh "<Researcher>" "<Project/Grant>"

### track_job.sh
Runs a command and tracks system usage until the command finishes.

Usage:
    bash track_job.sh "<Researcher>" "<Project/Grant>" <command>

## Output
Both scripts append a row to `resource_log.csv` containing:
- timestamps  
- CPU/GPU averages  
- RAM/VRAM peaks  
- storage usage  
- network usage  
- CPU/GPU hours  
- kWh  
- cost estimates  
- job status  

This directory contains the clean, portable copies of the scripts.
