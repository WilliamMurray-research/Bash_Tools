# Resource Tracking & Financial Auditing Suite

A collection of lightweight Bash tools designed to track, calculate, and audit hardware utilization (CPU, GPU, RAM, VRAM, Storage, Network) and derive energy/valuation metrics during interactive developer sessions or automated batch jobs.

All tracked data is instantly structured and appended to a centralized file (`resource_log.csv`) for billing, grant drawdowns, or long-term infrastructure forecasting.

---

## Included Scripts

### 1. `track_interactive.sh`

Designed for logging manual, non-automated sessions (e.g., document sorting, exploratory data analysis, interactive research, or environment setups).

* **Execution:** Runs indefinitely until manually interrupted.
* **Termination:** Press **`CTRL + C`** to safely trigger the terminal trap, calculate final deltas, and dump stats to the ledger.

```bash
bash track_interactive.sh "<Researcher Name>" "<Project/Grant String>"

```

> [!NOTE]
> If an empty string `""` is passed for the researcher or project name, the script will default to `"Unknown Researcher"` or `"Unassigned Project"` respectively to prevent blank data gaps.

### 2. `track_job.sh`

Designed for wrapped execution of automated code scripts, model training jobs, compilation pipelines, or CLI workloads.

* **Execution:** Automatically runs, profiles, and shadows the appended command string.
* **Termination:** Automatically intercepts the parent process exit code, updates the job status to `Completed` or `Failed`, and flushes metrics directly when the targeted process terminates.

```bash
bash track_job.sh "<Researcher Name>" "<Project/Grant String>" "python3 train_model.py --epochs 50"

```

---

## Structured Output Schema (`resource_log.csv`)

Upon task completion or manual interruption, both engines push a comprehensive comma-separated matrix containing the following continuous metrics:

| Dimension | Metrics Tracked | Derived Logic |
| --- | --- | --- |
| **Identity & Context** | Date, Researcher, Project Name, Job Type/Command | Explicit metadata mapping |
| **Temporal Deltas** | Start Time, End Time, True Duration (Hours) | Epoch delta calculation |
| **Compute Density** | CPU-Hours, GPU-Hours, Avg CPU (%), Avg GPU (%) | Utilization weighted time factors |
| **Memory Boundaries** | Peak RAM Consumption, Peak VRAM Footprint | Max-value high-watermark parsing |
| **Storage & IO Flux** | Initial Storage, Final Storage, Net RX (MB), Net TX (MB) | Sysfs networking / `/` filesystem deltas |
| **Financial Ledger** | CPU Value ($), GPU Value ($), Energy Cost ($), Total Value ($) | TDP-to-kWh mapping scaled by grid cost |
| **Process State** | Exit Status (`Completed`, `Failed`, etc.) | System execution codes |

---

## License

This project is open-source and available under the MIT Licence
