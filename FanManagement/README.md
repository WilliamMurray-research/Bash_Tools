# **GPU Fan Control (Tesla A2)**  
A simple Bash script that sets the fan speed on my NVIDIA Tesla A2 GPU.  
This version is the clean, portable copy; the live version runs automatically on startup through a systemd service.

---

## **Service Setup**
The systemd unit that runs this script is:

```
/etc/systemd/system/gpu-fan.service
```

It points to:

```
/usr/local/bin/gpu_fan.sh
```

The service starts after the NVIDIA driver persistence daemon and restarts automatically if needed.

---

## **Usage**
You normally don’t run this manually because systemd handles it, but the script can be invoked directly:

```
bash gpu_fan.sh --set 70
```
---

## **Notes**
- This script is installed system‑wide and starts automatically.  
- This repo version is just the clean copy for reference and version control.  
- I’ll update it here whenever I change the live version.

---
