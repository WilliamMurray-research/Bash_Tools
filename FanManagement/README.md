### Suggested File Name

For Git, a clean, descriptive file name for this systemd service file is:
**`gpu_fan_control.service`**

---

### Updated README.md

Here is the updated README including a new **Systemd Autostart Configuration** section. It also matches your script's location path (`/usr/local/bin/gpu_fan.sh`) used in the unit file.

---

# GPU-Driven Motherboard Fan Controller

A lightweight Bash bridge script that dynamically controls a motherboard fan header based on NVIDIA GPU temperatures. It features built-in **hysteresis** to prevent rapid fan speed oscillations (fan "revving") and **error protection** to handle cases where the NVIDIA driver briefly goes to sleep or fails to report temperatures.

## Features

* **Hardware Bridging:** Links Linux `hwmon` motherboard PWM fan controls directly to NVIDIA GPU thermal metrics.
* **Hysteresis Logic:** Prevents noisy, rapid fan speed fluctuations by requiring explicit thermal thresholds to be crossed before shifting speeds down.
* **Driver Sleep Protection:** Gracefully handles instances where `nvidia-smi` fails to report numbers (e.g., during low-power states or driver resets) rather than crashing or defaulting to zero cooling.
* **Differential Updates:** Only writes to the `sysfs` fan path when a speed change is actually required, reducing unnecessary disk/system writes.

---

## Technical Logic

### Fan Speed Mapping

The script uses standard Linux PWM values (**0 to 255**) to regulate the fan speed:

| GPU Temp Range | Target PWM Speed | Description |
| --- | --- | --- |
| **$\ge$ 80°C** | `255` | Maximum Cooling |
| **65°C - 79°C** | `200` | High Speed |
| **55°C - 64°C** | `150` | Medium Speed |
| **< 50°C** | `75` | Idle / Quiet Speed |

### Hysteresis Behavior

To protect fan bearings, the script uses directional padding. For example:

* The fan steps up to `200` PWM when the GPU hits **65°C**.
* The fan will *not* step back down to `150` PWM until the GPU drops below **60°C**.

---

## Prerequisites & Configuration

> [!WARNING]
> **Hardware paths vary by system.** You must verify your specific fan path before running this script to avoid overheating or modifying the wrong hardware controller.

### 1. Identify Your Fan Path

Locate the correct `hwmon` directory for your motherboard's fan controller (usually under `/sys/class/hwmon/`). Open the script and modify the `FAN_PATH` variable:

```bash
FAN_PATH="/sys/class/hwmon/hwmon3/pwm1"

```

### 2. Dependencies

Ensure you have the proprietary NVIDIA drivers installed, which include the `nvidia-smi` CLI utility:

```bash
nvidia-smi

```

---

## Manual Installation & Usage

1. **Clone the repository:**
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME

```


2. **Move the script to your binaries directory and make it executable:**
```bash
sudo cp gpu_fan.sh /usr/local/bin/gpu_fan.sh
sudo chmod +x /usr/local/bin/gpu_fan.sh

```


3. **Run manually (Optional):**
```bash
sudo /usr/local/bin/gpu_fan.sh

```



---

## Systemd Autostart Configuration

To have this controller run automatically in the background on system boot, you can install it as a `systemd` service using the provided `gpu_fan_control.service` file.

### 1. Copy the Service File

Copy the configuration file to the systemd directory:

```bash
sudo cp gpu_fan_control.service /etc/systemd/system/

```

### 2. Reload and Enable the Service

Tell systemd to recognize the new file, enable it to start on boot, and start it immediately:

```bash
sudo systemctl daemon-reload
sudo systemctl enable gpu_fan_control.service
sudo systemctl start gpu_fan_control.service

```

### 3. Managing the Service

* **Check current status and fan adjustments:**
```bash
sudo systemctl status gpu_fan_control.service

```


* **View real-time logs:**
```bash
sudo journalctl -u gpu_fan_control.service -f

```


* **Stop the service:**
```bash
sudo systemctl stop gpu_fan_control.service

```



---

## License

This project is open-source and available under the [MIT License](https://www.google.com/search?q=LICENSE).
