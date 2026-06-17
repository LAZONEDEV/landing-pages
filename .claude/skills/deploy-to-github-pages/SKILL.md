---
name: deploy-to-github-pages
description: >
  Déploie un fichier HTML standalone (typiquement un export Claude Design) sur GitHub Pages,
  dans le repo central LAZONEDEV/landing-pages, et renvoie l'URL en ligne. Déclenche ce skill
  quand l'utilisateur dit "déploie cette landing page", "mets cette page en ligne",
  "publie ce HTML sur github pages", "héberge cette page", "déploie le HTML de Claude Design",
  "mets ça sur github pages", "publie le standalone HTML", "déploie ce fichier HTML", ou partage
  un fichier .html en demandant de le rendre accessible via une URL publique rapidement.
  Ne pas déclencher pour un vrai projet Next.js/applicatif (là c'est un handoff Claude Code).
---

# Deploy standalone HTML → GitHub Pages (LAZONEDEV)

Publie un HTML autonome sur GitHub Pages en une commande. **Pas de clé API** : utilise le
`gh` CLI déjà authentifié. Conçu pour les exports Claude Design (fichier self-contained,
CSS/JS inlinés), donc aucun chemin d'asset relatif à gérer.

## Modèle d'hébergement

- **Un seul repo central** : `LAZONEDEV/landing-pages` (public, créé au premier run).
- **Un dossier par page** : `<slug>/index.html`.
- **URL** : `https://lazonedev.github.io/landing-pages/<slug>/`.
- Re-déployer le même slug = mise à jour de la page (overwrite).

## Utilisation

```bash
# slug auto-déduit du nom de fichier
./deploy.sh ./landing.html

# slug explicite
./deploy.sh ~/Downloads/evolve-hero.html evolve-capital
```

Le script :
1. vérifie `gh` + authentification ;
2. crée `LAZONEDEV/landing-pages` (public) s'il n'existe pas ;
3. clone, ajoute `<slug>/index.html` + `.nojekyll`, commit, push sur `main` ;
4. active GitHub Pages (branche `main`, racine `/`) au premier run uniquement ;
5. affiche l'URL finale.

## Workflow attendu de l'agent

1. Identifier le fichier HTML à déployer (chemin fourni ou fichier uploadé).
2. Proposer/confirmer le **slug** (segment d'URL). À défaut, dériver du nom de fichier.
3. Lancer `deploy.sh <fichier> <slug>`.
4. Renvoyer l'URL et préciser que le premier build prend ~1 min.

## Notes importantes

- **Repo public requis** : Pages sur un repo **privé** d'org nécessite un plan payant
  (Team/Enterprise). Le repo central est donc créé en public. Ne pas déployer de contenu
  sensible/confidentiel par ce biais.
- **Premier déploiement** : l'activation de Pages + le premier build peuvent prendre ~1 min
  avant que l'URL réponde (404 transitoire en attendant).
- **Slugs** : normalisés en `a-z0-9-`. Collision de slug ⇒ mise à jour (pas de duplication).
- **Domaine custom** (optionnel) : ajouter un fichier `CNAME` à la racine du repo et
  configurer le DNS, si on veut servir sous un domaine Evolve Capital plutôt que `github.io`.

## Variante : un repo par page

Si tu préfères un repo isolé par landing (ex. pour des domaines custom distincts), changer
`REPO` pour un nom dérivé du slug et créer le repo à la volée. Le modèle central reste
recommandé pour du déploiement rapide et répété.
