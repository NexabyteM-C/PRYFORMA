#!/usr/bin/env bash
# Build script for Render (static site). Installs the Flutter SDK on the build
# host, resolves the workspace and compiles the web app into
# apps/fitness_app/build/web, which Render then serves.
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo ">> Instalando Flutter SDK ($FLUTTER_CHANNEL)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_CHANNEL" "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_DIR" || true

flutter --version
flutter config --enable-web

echo ">> Resolviendo dependencias del workspace..."
flutter pub get

echo ">> Compilando Flutter Web (release)..."
cd apps/fitness_app
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-https://sxrnykzboumtpqcokkxf.supabase.co}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4cm55a3pib3VtdHBxY29ra3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyMzA2ODksImV4cCI6MjEwOTgwNjY4OX0.xbgEr-YEnfeLq5AgJLgjohyTk1xWsnbC0igmxtGR9go}"

echo ">> Listo: apps/fitness_app/build/web"
