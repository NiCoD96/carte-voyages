# Genere photos-b64/<id>.js (photos de photos/) et objets-b64/<id>.js (objets de objets/), si absents.
# Ces fichiers permettent de creer les images Instagram quand la carte est ouverte par double-clic (file://) :
# le navigateur interdit alors de lire les pixels d'une image chargee depuis le disque, mais accepte un script.
param([string]$Source = (Split-Path $PSScriptRoot -Parent))
$utf8 = New-Object System.Text.UTF8Encoding $false
foreach ($set in @(
  @{ src = 'photos'; out = 'photos-b64'; filter = '*.jpg'; mime = 'image/jpeg'; global = 'PHOTO_B64' },
  @{ src = 'objets'; out = 'objets-b64'; filter = '*.png'; mime = 'image/png';  global = 'OBJET_B64' }
)) {
  $src = Join-Path $Source $set.src
  if (-not (Test-Path $src)) { continue }
  $out = Join-Path $Source $set.out
  New-Item -ItemType Directory -Force $out | Out-Null
  $n = 0
  foreach ($f in Get-ChildItem $src -Filter $set.filter) {
    $id = $f.BaseName
    $dst = Join-Path $out "$id.js"
    if (Test-Path -LiteralPath $dst) { continue }
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f.FullName))
    $idJson = $id.Replace('\', '\\').Replace('"', '\"')
    $g = $set.global
    [IO.File]::WriteAllText($dst, "(window.$g = window.$g || {})[`"$idJson`"] = `"data:$($set.mime);base64,$b64`";`n", $utf8)
    $n++
  }
  Write-Host "$n fichier(s) cree(s) dans $out"
}
