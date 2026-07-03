# track_interactive.sh
#!/bin/bash

# --- CONFIGURATION ---
CSV_FILE="resource_log.csv"
INTERVAL=2
NUM_THREADS=12
CPU_TDP_WATTS=140          # Xeon W-2135
GPU_TDP_WATTS=60           # Tesla A2 typical sustained
CPU_RATE=0.40              # $/hr market rate
GPU_RATE=2.00              # $/hr market rate
KWH_RATE=0.30              # electricity cost per kWh

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 \"<Researcher Name>\" \"<Project/Grant>\""
    exit 1
fi

RESEARCHER="$1"
PROJECT="$2"
JOB_CMD="Manual Interactive Work / Document Sorting"

# Setup CSV header
if [ ! -f "$CSV_FILE" ]; then
    echo "Date,Researcher,Project,Job Description,Start Time,End Time,Duration (Hrs),CPU-Hours,GPU-Hours,kWh,Avg CPU (%),Peak RAM (GB),Avg GPU (%),Peak VRAM (GB),Storage Start (GB),Storage End (GB),Net RX (MB),Net TX (MB),CPU Value ($),GPU Value ($),Energy Value ($),Total Value ($),Status" > "$CSV_FILE"
fi

echo "Tracking started for: $PROJECT"
echo "Press CTRL+C to finish."

START_DATE=$(date +%Y-%m-%d)
START_TIME=$(date +%H:%M:%S)
START_EPOCH=$(date +%s)

cpu_sum=0
gpu_sum=0
samples_count=0
peak_ram=0
peak_vram=0

### NEW — capture initial storage + network counters
storage_start=$(df --output=used / | tail -1 | tr -d ' ')
net_rx_start=$(cat /sys/class/net/*/statistics/rx_bytes | paste -sd+ - | bc)
net_tx_start=$(cat /sys/class/net/*/statistics/tx_bytes | paste -sd+ - | bc)

trap cleanup SIGINT

cleanup() {
    echo -e "\nStopping tracker..."

    END_TIME=$(date +%H:%M:%S)
    END_EPOCH=$(date +%s)
    STATUS="Completed"

    duration_hrs=$(echo "($END_EPOCH - $START_EPOCH) / 3600" | bc -l)

    avg_cpu=$(echo "$cpu_sum / $samples_count" | bc -l)
    avg_gpu=$(echo "$gpu_sum / $samples_count" | bc -l)

    ### NEW — compute CPU-hours and GPU-hours
    cpu_hours=$(echo "$avg_cpu / 100 * $duration_hrs" | bc -l)
    gpu_hours=$(echo "$avg_gpu / 100 * $duration_hrs" | bc -l)

    ### NEW — compute kWh
    cpu_kwh=$(echo "$CPU_TDP_WATTS * ($avg_cpu/100) * $duration_hrs / 1000" | bc -l)
    gpu_kwh=$(echo "$GPU_TDP_WATTS * ($avg_gpu/100) * $duration_hrs / 1000" | bc -l)
    total_kwh=$(echo "$cpu_kwh + $gpu_kwh" | bc -l)

    ### NEW — compute storage + network deltas
    storage_end=$(df --output=used / | tail -1 | tr -d ' ')
    net_rx_end=$(cat /sys/class/net/*/statistics/rx_bytes | paste -sd+ - | bc)
    net_tx_end=$(cat /sys/class/net/*/statistics/tx_bytes | paste -sd+ - | bc)

    net_rx_mb=$(echo "($net_rx_end - $net_rx_start) / 1024 / 1024" | bc -l)
    net_tx_mb=$(echo "($net_tx_end - $net_tx_start) / 1024 / 1024" | bc -l)

    ### NEW — compute valuation
    cpu_value=$(echo "$cpu_hours * $CPU_RATE" | bc -l)
    gpu_value=$(echo "$gpu_hours * $GPU_RATE" | bc -l)
    energy_value=$(echo "$total_kwh * $KWH_RATE" | bc -l)
    total_value=$(echo "$cpu_value + $gpu_value + $energy_value" | bc -l)

    # Format
    printf -v d_hrs "%.4f" "$duration_hrs"
    printf -v d_cpuhrs "%.4f" "$cpu_hours"
    printf -v d_gpuhours "%.4f" "$gpu_hours"
    printf -v d_kwh "%.4f" "$total_kwh"
    printf -v d_cpuavg "%.1f%%" "$avg_cpu"
    printf -v d_gpuavg "%.1f%%" "$avg_gpu"
    printf -v d_ram "%.1f GB" "$peak_ram"
    printf -v d_vram "%.1f GB" "$peak_vram"
    printf -v d_rx "%.1f" "$net_rx_mb"
    printf -v d_tx "%.1f" "$net_tx_mb"
    printf -v d_cpuval "%.2f" "$cpu_value"
    printf -v d_gpuval "%.2f" "$gpu_value"
    printf -v d_energyval "%.2f" "$energy_value"
    printf -v d_totalval "%.2f" "$total_value"

    echo "$START_DATE,$RESEARCHER,$PROJECT,\"$JOB_CMD\",$START_TIME,$END_TIME,$d_hrs,$d_cpuhrs,$d_gpuhours,$d_kwh,$d_cpuavg,$d_ram,$d_gpuavg,$d_vram,$storage_start,$storage_end,$d_rx,$d_tx,$d_cpuval,$d_gpuval,$d_energyval,$d_totalval,$STATUS" >> "$CSV_FILE"

    echo "Saved to $CSV_FILE"
    exit 0
}

while true; do
    load_avg=$(awk '{print $1}' /proc/loadavg)
    cpu_cur=$(echo "$load_avg * 100 / $NUM_THREADS" | bc -l)
    if (( $(echo "$cpu_cur > 100" | bc -l) )); then cpu_cur=100; fi

    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    ram_cur=$(echo "($mem_total - $mem_avail) / 1024 / 1024" | bc -l)

    gpu_data=$(nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader,nounits 2>/dev/null)
    if [ $? -eq 0 ]; then
        gpu_cur=$(echo "$gpu_data" | cut -d',' -f1 | tr -d ' ')
        vram_mib=$(echo "$gpu_data" | cut -d',' -f2 | tr -d ' ')
        vram_cur=$(echo "$vram_mib / 1024" | bc -l)
    else
        gpu_cur=0
        vram_cur=0
    fi

    cpu_sum=$(echo "$cpu_sum + $cpu_cur" | bc -l)
    gpu_sum=$(echo "$gpu_sum + $gpu_cur" | bc -l)
    ((samples_count++))

    if (( $(echo "$ram_cur > $peak_ram" | bc -l) )); then peak_ram=$ram_cur; fi
    if (( $(echo "$vram_cur > $peak_vram" | bc -l) )); then peak_vram=$vram_cur; fi

    sleep $INTERVAL
done
