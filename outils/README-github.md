# Mes voyages en Europe

Carte interactive de mes voyages, avec mes photos souvenirs.
Version publiée : consultation seule (les ajouts se font depuis la version locale de la carte).

## Mettre en ligne avec GitHub Pages

1. Sur [github.com](https://github.com), créer un nouveau dépôt (bouton **New**), par exemple `mes-voyages`.
   GitHub Pages est gratuit pour un dépôt **public** : tout le monde pourra voir les photos.
2. Envoyer le contenu de ce dossier dans le dépôt :
   - **Sans outil** : dans le dépôt, *Add file → Upload files*, glisser **le contenu** de ce dossier
     (index.html, data.js, config.js, .nojekyll, README.md et les dossiers photos, mini, objets),
     puis *Commit changes*. Au-delà de 100 fichiers, faire plusieurs envois (par exemple un par dossier).
   - **Avec GitHub Desktop** : *File → Add local repository* sur ce dossier, puis *Publish repository*.
3. Dans le dépôt : *Settings → Pages* → *Source : Deploy from a branch* → branche `main`, dossier `/ (root)` → *Save*.
4. Après une à deux minutes, la carte est en ligne à l'adresse `https://<ton-pseudo>.github.io/mes-voyages/`.

> Le fichier `.nojekyll` peut être masqué par Windows : il n'est pas indispensable.

## Mettre à jour la version en ligne

1. Dans la carte locale (`carte-voyages/index.html`), cliquer sur **Sauvegarder mes ajouts** et placer
   `ajouts.js` dans le dossier `carte-voyages`.
2. Lancer `carte-voyages/outils/preparer_github.ps1` (clic droit → *Exécuter avec PowerShell*) :
   le dossier `carte-voyages-github` est régénéré.
3. Renvoyer son contenu dans le dépôt GitHub (remplacer les fichiers existants).
