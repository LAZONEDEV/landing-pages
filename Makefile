# Makefile — landing-pages
# Raccourcis pour deployer / gerer les landing pages statiques sur GitHub Pages.

ORG      := LAZONEDEV
REPO     := landing-pages
BASE_URL := https://lazonedev.github.io/$(REPO)
DEPLOY   := .claude/skills/deploy-to-github-pages/deploy.sh

.DEFAULT_GOAL := help
.PHONY: help deploy list url open rm status

help: ## Affiche cette aide
	@echo "landing-pages — cibles disponibles :"
	@echo ""
	@echo "  make deploy                                    Deploie TOUS les sous-dossiers (slug = nom du dossier)"
	@echo "  make deploy FILE=./page.html [SLUG=mon-slug]   Deploie un seul HTML standalone"
	@echo "  make list                                      Liste les pages publiees + URLs"
	@echo "  make url SLUG=mon-slug                          Affiche l'URL d'une page"
	@echo "  make open SLUG=mon-slug                         Ouvre la page dans le navigateur"
	@echo "  make rm SLUG=mon-slug                           Supprime une page (commit + push)"
	@echo "  make status                                     Verifie gh auth + etat git"
	@echo ""
	@echo "URL de base : $(BASE_URL)/<slug>/"

deploy: ## Deploie un HTML (FILE=... [SLUG=...]) ; sans FILE => tous les sous-dossiers (slug = nom du dossier)
	@if [ -n "$(FILE)" ]; then \
		test -f "$(FILE)" || { echo "❌ Fichier introuvable: $(FILE)"; exit 1; }; \
		bash "$(DEPLOY)" "$(FILE)" $(SLUG); \
	else \
		found=0; rc=0; \
		for d in */; do \
			[ -f "$$d/index.html" ] || continue; \
			slug="$${d%/}"; found=1; \
			echo "🚀 Deploiement de '$$slug'…"; \
			bash "$(DEPLOY)" "$$d/index.html" "$$slug" || rc=1; \
		done; \
		[ $$found -eq 1 ] || echo "ℹ️  Aucun sous-dossier avec index.html à deployer."; \
		exit $$rc; \
	fi

list: ## Liste les pages publiees + leurs URLs
	@found=0; for d in */; do \
		if [ -f "$$d/index.html" ]; then \
			printf "  %-28s %s\n" "$${d%/}" "$(BASE_URL)/$${d%/}/"; found=1; \
		fi; \
	done; [ $$found -eq 1 ] || echo "  (aucune page pour l'instant)"

url: ## Affiche l'URL d'un slug (SLUG=...)
	@test -n "$(SLUG)" || { echo "❌ Usage: make url SLUG=mon-slug"; exit 1; }
	@echo "$(BASE_URL)/$(SLUG)/"

open: ## Ouvre la page dans le navigateur (SLUG=...)
	@test -n "$(SLUG)" || { echo "❌ Usage: make open SLUG=mon-slug"; exit 1; }
	@u="$(BASE_URL)/$(SLUG)/"; \
	if command -v open >/dev/null 2>&1; then open "$$u"; \
	elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$$u"; \
	else echo "$$u"; fi

rm: ## Supprime une page (SLUG=...)
	@test -n "$(SLUG)" || { echo "❌ Usage: make rm SLUG=mon-slug"; exit 1; }
	@test -d "$(SLUG)" || { echo "❌ Page introuvable: $(SLUG)"; exit 1; }
	git rm -r "$(SLUG)"
	git commit -m "remove: $(SLUG)"
	git push
	@echo "🗑️  Page '$(SLUG)' supprimee (recuperable via l'historique git)."

status: ## Verifie l'auth gh et l'etat git
	@gh auth status || true
	@echo ""
	@git status -s
