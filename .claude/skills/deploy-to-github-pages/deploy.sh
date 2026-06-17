#!/usr/bin/env bash
#
# deploy.sh — Publie un fichier HTML standalone (ex: export Claude Design)
#             sur GitHub Pages, dans un repo central de l'org LAZONEDEV.
#
# Usage:
#   ./deploy.sh <chemin-vers-html> [slug]
#
# Exemples:
#   ./deploy.sh ./landing.html
#   ./deploy.sh ~/Downloads/evolve-hero.html evolve-capital
#
# Résultat: https://lazonedev.github.io/landing-pages/<slug>/
#
set -euo pipefail

# ----------------------------- Config -----------------------------
ORG="LAZONEDEV"            # org GitHub
REPO="landing-pages"       # repo central qui héberge toutes les pages
BRANCH="main"
# ------------------------------------------------------------------

HTML_FILE="${1:?Usage: deploy.sh <chemin-vers-html> [slug]}"
[ -f "$HTML_FILE" ] || { echo "❌ Fichier introuvable: $HTML_FILE" >&2; exit 1; }

# Chemin absolu (on changera de répertoire plus bas)
HTML_ABS="$(cd "$(dirname "$HTML_FILE")" && pwd)/$(basename "$HTML_FILE")"

# Slug: 2e argument, sinon nom de fichier sans extension. Slugifié.
RAW_SLUG="${2:-$(basename "${HTML_FILE%.*}")}"
SLUG="$(printf '%s' "$RAW_SLUG" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')"
[ -n "$SLUG" ] || SLUG="page-$(date +%s)"

# --------------------------- Préconditions ------------------------
command -v gh >/dev/null 2>&1 || { echo "❌ GitHub CLI (gh) non installé. → https://cli.github.com" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "❌ Non authentifié. Lance: gh auth login" >&2; exit 1; }

# ------------------- Crée le repo central si absent ----------------
if ! gh repo view "$ORG/$REPO" >/dev/null 2>&1; then
  echo "📦 Création de $ORG/$REPO (public)…"
  gh repo create "$ORG/$REPO" --public \
    --description "Landing pages standalone déployées depuis Claude Design" >/dev/null
fi

# --------------------------- Clone + ajout -------------------------
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
gh repo clone "$ORG/$REPO" "$WORKDIR" -- --depth 1 >/dev/null 2>&1 || \
  gh repo clone "$ORG/$REPO" "$WORKDIR" >/dev/null 2>&1

cd "$WORKDIR"
git checkout "$BRANCH" >/dev/null 2>&1 || git checkout -b "$BRANCH" >/dev/null 2>&1

touch .nojekyll                       # évite que Pages lance Jekyll
mkdir -p "$SLUG"
cp "$HTML_ABS" "$SLUG/index.html"

ACTION="déployé"
if git ls-files --error-unmatch "$SLUG/index.html" >/dev/null 2>&1; then
  ACTION="mis à jour"
fi

git add -A
if git diff --cached --quiet; then
  echo "ℹ️  Aucun changement pour '$SLUG' (page déjà à jour)."
else
  git commit -m "deploy: $SLUG" >/dev/null
  git branch -M "$BRANCH"
  git push -u origin "$BRANCH" >/dev/null 2>&1
fi

# ------------------------- Active GitHub Pages ---------------------
if ! gh api "repos/$ORG/$REPO/pages" >/dev/null 2>&1; then
  echo "🌐 Activation de GitHub Pages…"
  gh api --method POST "repos/$ORG/$REPO/pages" --input - >/dev/null 2>&1 <<JSON || true
{"source":{"branch":"$BRANCH","path":"/"}}
JSON
fi

# ------------------------------ Sortie -----------------------------
ORG_LC="$(printf '%s' "$ORG" | tr '[:upper:]' '[:lower:]')"
URL="https://${ORG_LC}.github.io/${REPO}/${SLUG}/"
echo ""
echo "✅ Page $ACTION : $URL"
echo "   (le premier build Pages peut prendre ~1 min avant d'être en ligne)"
