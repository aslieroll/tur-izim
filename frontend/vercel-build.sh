#!/usr/bin/env bash
set -euo pipefail

FLUTTER_ROOT="${HOME}/flutter"

if [ ! -d "${FLUTTER_ROOT}/bin" ]; then
  echo "Installing Flutter stable into ${FLUTTER_ROOT}..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_ROOT}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL:-https://tur-izim-production.up.railway.app}"
