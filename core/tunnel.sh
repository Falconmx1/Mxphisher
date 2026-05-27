#!/bin/bash

# ===== NGROK =====
iniciar_ngrok() {
    local puerto=$1
    
    if ! command -v ngrok &> /dev/null; then
        echo -e "${Y}[!]${W} Ngrok no instalado. Descargando..."
        wget -q -O ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
        unzip -q ngrok.zip
        sudo mv ngrok /usr/local/bin/
        rm ngrok.zip
    fi
    
    killall ngrok 2>/dev/null
    ngrok http $puerto > /dev/null 2>&1 &
    sleep 4
    
    local url=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])" 2>/dev/null)
    
    if [[ $url == https://* ]]; then
        echo "$url"
    else
        echo "ERROR"
    fi
}

# ===== SERVEO (SSH reverse tunnel) =====
iniciar_serveo() {
    local puerto=$1
    
    echo -e "${C}[*]${W} Conectando a Serveo..."
    
    # Generar subdominio aleatorio
    local subdominio=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1)
    
    # Usar ssh para crear el túnel (requiere ssh instalado)
    ssh -R ${subdominio}:80:localhost:$puerto serveo.net 2>&1 &
    local ssh_pid=$!
    sleep 5
    
    # La URL sería http://$subdominio.serveo.net
    local url="http://${subdominio}.serveo.net"
    
    # Verificar si funciona
    if curl -s --max-time 3 "$url" > /dev/null; then
        echo "$url"
    else
        echo "ERROR"
    fi
}

# ===== LOCALHOST.RUN =====
iniciar_localhost_run() {
    local puerto=$1
    
    echo -e "${C}[*]${W} Conectando a Localhost.run..."
    
    # Usar ssh para crear el túnel
    ssh -R 80:localhost:$puerto localhost.run 2>&1 &
    local ssh_pid=$!
    sleep 5
    
    # Intentar extraer la URL de la salida
    local url=$(ps aux | grep "localhost.run" | grep -oP 'https?://[a-z0-9.-]+\.localhost\.run' | head -1)
    
    if [ -n "$url" ]; then
        echo "$url"
    else
        echo "ERROR"
    fi
}

# ===== CLOUDFLARED (Argo Tunnel) =====
iniciar_cloudflared() {
    local puerto=$1
    
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${Y}[!]${W} cloudflared no instalado. Descargando..."
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
        chmod +x cloudflared-linux-amd64
        sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
    fi
    
    killall cloudflared 2>/dev/null
    
    # Iniciar tunnel
    cloudflared tunnel --url http://localhost:$puerto > /tmp/cloudflared.log 2>&1 &
    local cf_pid=$!
    sleep 5
    
    # Extraer URL del log
    local url=$(grep -o 'https://[a-z0-9.-]*\.trycloudflare\.com' /tmp/cloudflared.log | head -1)
    
    if [ -n "$url" ]; then
        echo "$url"
    else
        echo "ERROR"
    fi
}

# ===== LOCALHOST (solo para pruebas locales) =====
iniciar_local() {
    local puerto=$1
    echo "http://localhost:$puerto"
}
