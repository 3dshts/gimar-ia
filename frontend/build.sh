#!/usr/bin/env bash
# frontend/build.sh

# Salir inmediatamente si un comando falla.
set -o errexit

# Clona el repositorio completo de Flutter (sin --depth 1).
git clone https://github.com/flutter/flutter.git --branch stable
export PATH="$PWD/flutter/bin:$PATH"

# Ejecuta flutter doctor para verificar la instalación.
flutter doctor

# Habilita el soporte web.
flutter config --enable-web

# Construye la aplicación web.
flutter build web
