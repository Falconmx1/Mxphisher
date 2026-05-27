#!/bin/bash

verificar_ngrok() {
    if ! command -v ngrok &> /dev/null; then
        echo -e "${Y}[!]${W} Descargando Ngrok..."
        wget -q -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
        unzip -q ngrok.zip
        sudo mv ngrok /usr/local/bin/
        rm ngrok.zip
        echo -e "${G}[✔]${W} Ngrok instalado"
    fi
}

iniciar_ngrok() {
    local puerto=$1
    
    # Matar procesos anteriores
    killall ngrok 2>/dev/null
    
    # Iniciar
    ngrok http $puerto > /dev/null 2>&1 &
    sleep 4
    
    # Obtener URL
    local url=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])" 2>/dev/null)
    
    if [[ $url == https://* ]]; then
        echo "$url"
    else
        echo "ERROR"
    fi
}
