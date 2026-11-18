# Carte de voyages

Une carte d'Europe interactive pour garder ses souvenirs de voyage : chaque ville visitée apparaît sur la carte
avec ses photos, posées comme des polaroïds, ses objets (billets, magnets…) et ses post-it.
On peut aussi partager sa carte avec la famille et consulter la leur.

La carte s'ouvre dans le navigateur, sans installation ni compte. Tout reste sur ton ordinateur.

## Démarrer

1. Sur cette page GitHub, bouton vert **Code → Download ZIP**, puis **décompresse** le dossier
   (par exemple dans *Documents*), et renomme-le si tu veux (« Ma carte de voyages »).
2. Ouvre **`index.html`** avec **Google Chrome** ou **Microsoft Edge** (double-clic, ou clic droit → *Ouvrir avec*).
   Une connexion internet est nécessaire pour le fond de carte.
3. Un **tutoriel** se lance au premier démarrage. Tu peux le relancer avec le bouton **?** en haut du menu.
4. Clique sur le bouton rouge **« Activer la sauvegarde »** et choisis **le dossier de la carte**
   (celui qui contient `index.html`), puis accepte l'accès (idéalement « Autoriser à chaque visite »).
   Ensuite, tout ce que tu fais est sauvegardé automatiquement dans le fichier `ajouts.js` de ce dossier.

> Sur Firefox ou Safari, la sauvegarde automatique n'est pas possible : le bouton rouge télécharge `ajouts.js`,
> qu'il faut ensuite placer dans le dossier de la carte, à côté de `index.html`.

## Remplir sa carte

- **＋ Ajouter** : crée une ville (recherche par son nom ou clic sur la carte), ses dates, puis ajoute
  des **photos**, des **objets** (images PNG détourées, sans fond) et des **post-it**.
- **Clic sur une ville** (carte ou liste) : ses photos s'étalent autour. Clic sur une photo pour l'ouvrir en grand :
  modifier sa légende, la mettre en couverture, la **rendre privée** ou la supprimer.
- **✎** à côté d'une ville : modifier ses dates. Bouton **Instagram** : créer une image carrée à partager.
- **♡ À visiter** : les villes dont tu rêves ou un voyage prévu.
- Clic sur le **titre** pour le changer, **🎨** pour les couleurs.

## Partager avec la famille

- Bloc **Amis**, en bas du menu → **Partager ma carte** : crée un fichier `carte-<prénom>-<date>.json`
  à envoyer par mail (ou WeTransfer s'il est gros). **Les éléments privés ne sont jamais partagés.**
- Celui qui le reçoit clique sur **＋ Importer** dans son bloc Amis : il voit ta carte en lecture seule,
  avec tes couleurs. Si tu lui renvoies un fichier plus tard, il remplace l'ancien.
- La carte de **Camille (exemple)** est là pour découvrir à quoi ressemble la carte d'un proche :
  le **✕** à côté de son nom la retire.

## Bon à savoir

- **Ne supprime pas `ajouts.js`** : c'est ta carte (villes, photos, réglages). Pour la mettre à l'abri,
  copie le dossier entier sur une clé USB ou un cloud de temps en temps.
- **Ne publie pas ton `ajouts.js` sur GitHub** si le dépôt est public : il contient tes photos
  (le fichier `.gitignore` l'exclut déjà).
- **Mettre à jour l'application** quand une nouvelle version est publiée : remplace seulement `index.html`
  (garde ton `ajouts.js`).

## Pour aller plus loin (facultatif)

- `outils/generer_photos_b64.ps1` : si tu places toi-même des photos dans un dossier `photos/`, ce script
  permet d'en faire des images Instagram en ouvrant la carte par double-clic.
- `outils/preparer_github.ps1` : prépare une version de **ta** carte à mettre en ligne en lecture seule
  (sans les éléments privés), voir `outils/README-github.md`.

### Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | L'application (tout le code est dedans). |
| `data.js` | Voyages de base : vide au départ. |
| `amis-par-defaut.js` | Carte d'exemple de Camille, ajoutée aux amis au premier lancement (peut être supprimé). |
| `ajouts.js` | Créé par la sauvegarde : **ta carte**. |
| `outils/` | Scripts facultatifs (PowerShell, Windows). |
