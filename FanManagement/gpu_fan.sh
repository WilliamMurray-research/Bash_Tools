#!/bin/bash
# Bridge script: Motherboard Fan <-> NVIDIA GPU Temp with Hysteresis & Error Protection

FAN_PATH="/sys/class/hwmon/hwmon3/pwm1"
echo 1 | tee "${FAN_PATH}_enable" > /dev/null

echo "GPU Cooling Script Started. Monitoring A2 (Persistence-Safe)..."

LAST_SPEED=75 

while true; do
    # 1. Capture temp and handle the "driver sleep" issue
    RAW_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

    # 2. Safety Check: If RAW_TEMP is not a number, skip this loop
    if ! [[ "$RAW_TEMP" =~ ^[0-9]+$ ]]; then
        # Optional: echo "Driver sleeping..." 
        sleep 5
        continue
    fi
    
    TEMP=$RAW_TEMP

    # 3. Hysteresis Logic
    if [ "$TEMP" -ge 80 ]; then
        NEW_SPEED=255
    elif [ "$TEMP" -ge 65 ] && [ "$LAST_SPEED" -lt 200 ]; then
        NEW_SPEED=200
    elif [ "$TEMP" -ge 55 ] && [ "$LAST_SPEED" -lt 150 ]; then
        NEW_SPEED=150
    elif [ "$TEMP" -lt 50 ] && [ "$LAST_SPEED" -eq 150 ]; then
        NEW_SPEED=75
    elif [ "$TEMP" -lt 60 ] && [ "$LAST_SPEED" -eq 200 ]; then
        NEW_SPEED=150
    elif [ "$TEMP" -lt 75 ] && [ "$LAST_SPEED" -eq 255 ]; then
        NEW_SPEED=200
    else
        NEW_SPEED=$LAST_SPEED
    fi

    # 4. Only act if speed changes
    if [ "$NEW_SPEED" -ne "$LAST_SPEED" ]; then
        echo "$NEW_SPEED" | tee "$FAN_PATH" > /dev/null
        LAST_SPEED=$NEW_SPEED
        echo "$(date +%H:%M:%S) - Temp: ${TEMP}°C -> Fan: $LAST_SPEED"
    fi

    sleep 2
done
