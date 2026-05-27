#!/bin/bash
# Gestión de túneles: Ngrok, Serveo, Cloudflared

iniciar_tunel() {
    local tipo=$1
    local puerto=$2
    
    case $tipo in
        "ngrok")
            echo -e "${G}[+]${W} Iniciando Ngrok en puerto $puerto"
            ngrok http $puerto > /dev/null 2>&1 &
            sleep 3
            curl -s http://localhost:4040/api/tunnels | grep -o 'https://[a-z0-9]*\.ngrok\.io'
            ;;
        "serveo")
            echo -e "${G}[+]${W} Usando Serveo"
            ssh -R 80:localhost:$puerto serveo.net
            ;;
        *)
            echo -e "${R}[!]${W} Túnel no soportado"
            ;;
    esac
}
