# **Bash Tools**
Small Bash scripts I use for system monitoring and hardware control. Nothing fancy — just practical utilities that help me manage my machine while I work.

---

## **Included Tools**

### **GPU Fan Script**
Controls the fan speed on my NVIDIA GPU (Tesla A2).  
Useful for keeping temps stable during long runs.

### **Resource Tracker**
Tracks CPU, GPU, memory, and runtime for commands or experiments.

---

## **Structure**
```
.
├── FanManagement/
│   ├── gpu_fan.sh
│   ├── gpu_fan_control.service
│   └── README.md
│
├── ResourceTracking/
│   ├── track_interactive.sh
│   ├── track_job.sh
│   └── README.md
│
├── LICENSE
└── README.md

```

---

## **Dependencies**
- Bash  
- `nvidia-smi` (for GPU tools)  
- Standard Linux utilities  

---

## **Notes**
These scripts are small, simple, and meant for personal use. I’ll add more as I write them.

---
