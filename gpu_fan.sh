[Unit]
Description=A2 GPU Fan Control Persistence
After=nvidia-persistenced.service multi-user.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/gpu_fan.sh
Restart=always
RestartSec=5
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target

