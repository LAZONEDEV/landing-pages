# CLAUDE.md — `landing-pages`

## Rôle de ce repo

Hôte **statique** central pour des landing pages HTML **standalone**, servies via **GitHub Pages**.
La plupart des pages sont des exports **Claude Design** (fichier auto-contenu : CSS/JS inlinés).

Ce n'est **PAS** un projet applicatif : pas de framework, pas de build, pas de backend, pas de CI.
Le repo reste un « bête » bucket de fichiers statiques. Garde-le ainsi.

## Modèle d'hébergement

- **1 page = 1 dossier** à la racine, contenant un `index.html`.
- **Nom du dossier = slug = segment d'URL.** Format strict : `a-z0-9-` (kebab-case).
- **URL publique :** `https://lazonedev.github.io/landing-pages/<slug>/`
- **`.nojekyll`** à la racine : **NE PAS supprimer** (désactive Jekyll, sinon certains fichiers sont ignorés).
- **GitHub Pages déjà configuré** : branche `main`, dossier `/` (root). **NE PAS modifier** la source.

## Structure attendue

```
landing-pages/
├── CLAUDE.md
├── .nojekyll
├── .claude/skills/deploy-to-github-pages/   ← le skill de déploiement
│   ├── SKILL.md
│   └── deploy.sh
├── evolve-capital/
│   └── index.html
└── <autre-slug>/
    └── index.html
```

## Réflexes attendus

### Déployer une page
**TOUJOURS** utiliser le skill `deploy-to-github-pages`. Ne pas refaire les étapes git/Pages à la main.

```bash
.claude/skills/deploy-to-github-pages/deploy.sh <chemin-vers-html> [slug]
```

- Si le slug n'est pas fourni : le proposer (dérivé du nom de fichier) et **confirmer avant de pousser**.
- Le script gère : ajout du dossier `<slug>/index.html`, commit, push, et l'URL de sortie.

### Règles dures
- Fichier servi : **toujours `index.html`** dans le dossier de la page (sinon Pages ne sert rien à la racine du dossier).
- **Re-déployer un slug existant = mise à jour** (overwrite), jamais de duplication ni de suffixe.
- Messages de commit : format **`deploy: <slug>`**.
- **Repo PUBLIC** → ne **jamais** committer de contenu confidentiel : clés/API, secrets, `.env`, données client sensibles. Tout est visible publiquement.
- HTML attendu = **self-contained**. Si une page référence des assets externes en chemin relatif, vérifier qu'ils résolvent bien depuis le sous-dossier `<slug>/` ; sinon les inliner ou les copier dans le dossier.
- **Ne pas ajouter** : `package.json`, bundler, framework, GitHub Actions, dépendances. Ce repo n'a pas de toolchain.

### Quand ce repo n'est PAS le bon endroit
Si une page a besoin de **logique réelle** (formulaire qui soumet vraiment, authentification, paiement,
base de données, appel API serveur), ce n'est pas un déploiement Pages statique.
→ Le signaler clairement et orienter vers un vrai projet (handoff Claude Code / Next.js), **pas** vers ce repo.

## Prérequis (poste local)
- `gh` (GitHub CLI) installé et authentifié avec accès à l'org **LAZONEDEV** (`gh auth status`).

## Contexte
Pages produites surtout via le pipeline **Claude Design → export standalone HTML**, pour Evolve Capital
et les projets clients. Objectif : mettre une maquette en ligne en quelques secondes pour partage ou validation rapide.