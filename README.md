# **Bash Tools**
Small Bash scripts I use for system monitoring and hardware control. Nothing fancy — just practical utilities that help me manage my machine while I work.

---

## **Included Tools**

### **GPU Fan Script**
Controls the fan speed on my NVIDIA GPU (Tesla A2).  
Useful for keeping temps stable during long runs.

Example:
```
bash gpu_fan.sh --set 70
```

### **Resource Tracker**
Tracks CPU, GPU, memory, and runtime for commands or experiments.

Example:
```
bash track.sh --cmd "python experiment.py"
```

---

## **Structure**
```
bash-tools/
├── gpu_fan.sh
├── track_interactive.sh
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
