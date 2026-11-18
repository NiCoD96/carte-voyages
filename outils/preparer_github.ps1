# Prepare une version publiable de la carte (GitHub Pages ou tout hebergement statique) :
#  - fusionne ajouts.js (ajouts faits depuis la page) dans data.js,
#  - extrait les images base64 en vrais fichiers (photos/, mini/, objets/),
#  - active le mode lecture (config.js) : pas de boutons de modification en ligne.
# Usage : clic droit > Executer avec PowerShell, ou
#   powershell -ExecutionPolicy Bypass -File outils\preparer_github.ps1
param(
  [string]$Source = (Split-Path $PSScriptRoot -Parent),
  [string]$Out = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'carte-voyages-github')
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Web.Extensions
$json = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$json.MaxJsonLength = [int]::MaxValue
$json.RecursionLimit = 1000
$utf8 = New-Object System.Text.UTF8Encoding $false

# Lit la valeur JSON de "window.NOM = ...;" dans un fichier .js (null si absent)
function Read-JsVar($path, $name) {
  if (-not (Test-Path $path)) { return $null }
  $text = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
  $m = [regex]::Match($text, "window\.$name\s*=\s*")
  if (-not $m.Success) { return $null }
  $start = $m.Index + $m.Length
  $e = [regex]::Match($text.Substring($start), ';\s*(\r?\n|$)')
  return ,$json.DeserializeObject($text.Substring($start, $e.Index))
}
function New-List($arr) {
  $l = New-Object System.Collections.ArrayList
  if ($null -ne $arr) { foreach ($x in $arr) { [void]$l.Add($x) } }
  return ,$l
}
# Copie "propre" pour la serialisation (retire les enveloppes PowerShell des valeurs)
function Clean($o) {
  if ($null -eq $o) { return $null }
  if ($o -is [System.Management.Automation.PSObject]) { $o = $o.PSObject.BaseObject }
  if ($o -is [System.Collections.IDictionary]) {
    $d = New-Object 'System.Collections.Generic.Dictionary[string,object]'
    foreach ($k in @($o.Keys)) { $d["$k"] = (Clean $o[$k]) }
    return ,$d
  }
  if ($o -is [System.Collections.IEnumerable] -and -not ($o -is [string])) {
    $a = New-Object System.Collections.ArrayList
    foreach ($x in $o) { [void]$a.Add((Clean $x)) }
    return ,($a.ToArray())
  }
  return $o
}
function Save-DataUrl($dataUrl, $path) {
  $b64 = $dataUrl.Substring($dataUrl.IndexOf(',') + 1)
  [IO.File]::WriteAllBytes($path, [Convert]::FromBase64String($b64))
}

Write-Host "Source : $Source"
Write-Host "Sortie : $Out"
if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }
foreach ($d in 'photos', 'mini', 'objets') { New-Item -ItemType Directory -Force (Join-Path $Out $d) | Out-Null }
Copy-Item (Join-Path $Source 'index.html') $Out
foreach ($d in 'photos', 'mini', 'objets') {
  $src = Join-Path $Source $d
  if (Test-Path $src) { Copy-Item (Join-Path $src '*') (Join-Path $Out $d) -Force }
}

# --- Donnees de base ---
$trips = New-List (Read-JsVar (Join-Path $Source 'data.js') 'TRIPS')
foreach ($t in $trips) {
  foreach ($k in 'places', 'objects', 'notes') { $t[$k] = New-List $(if ($t.ContainsKey($k)) { $t[$k] } else { $null }) }
  foreach ($p in $t['places']) { $p['photos'] = New-List $p['photos'] }
}
$wishes = [ordered]@{}
$wb = Read-JsVar (Join-Path $Source 'data.js') 'WISHES'
foreach ($w in @($wb)) { if ($w) { $wishes[$w['id']] = $w } }
$settings = @{ title = 'Mes voyages en Europe'; palette = 'classique' }
$sb = Read-JsVar (Join-Path $Source 'data.js') 'SETTINGS'
if ($sb) { foreach ($k in $sb.Keys) { $settings[$k] = $sb[$k] } }

function Find-City($name) {
  foreach ($t in $trips) { if ("$($t['name'])".ToLower() -eq "$name".ToLower()) { return ,$t } }
  return $null
}
function Get-Place($city, $name) {
  foreach ($p in $city['places']) {
    if (($name -and $p['name'] -eq $name) -or (-not $name -and $p['general'])) { return ,$p }
  }
  $p = @{ name = "$name"; general = [bool](-not $name); lat = $city['lat']; lon = $city['lon']; photos = (New-List $null) }
  [void]$city['places'].Add($p)
  return ,$p
}

# --- Ajouts faits depuis la page (ajouts.js) ---
$items = Read-JsVar (Join-Path $Source 'ajouts.js') 'AJOUTS'
$items = @(@($items) | Where-Object { $_ })
$deleted = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($i in $items) { if ($i['type'] -eq 'deleted') { [void]$deleted.Add($i['target']) } }
$live = @($items | Where-Object { $_['type'] -ne 'deleted' -and -not $deleted.Contains($_['id']) })
Write-Host "Ajouts lus : $($items.Count)"

$baseIds = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($t in $trips) { foreach ($p in $t['places']) { foreach ($ph in $p['photos']) { [void]$baseIds.Add($ph['id']) } } }

foreach ($i in $live | Where-Object { $_['type'] -eq 'city' }) {
  if (-not (Find-City $i['name'])) {
    [void]$trips.Add(@{ name = $i['name']; country = "$($i['country'])"; lat = $i['lat']; lon = $i['lon']; start = $null; end = $null
      places = (New-List $null); objects = (New-List $null); notes = (New-List $null) })
  }
}
foreach ($i in $live | Where-Object { $_['type'] -eq 'dates' }) {
  $c = Find-City $i['city']
  if ($c) { $c['start'] = $i['start']; $c['end'] = $(if ($i['end']) { $i['end'] } else { $i['start'] }) }
}
foreach ($i in $live | Where-Object { $_['type'] -eq 'place' }) {
  $c = Find-City $i['city']
  if ($c) { $p = Get-Place $c $i['name']; if ($i['lat']) { $p['lat'] = $i['lat']; $p['lon'] = $i['lon'] } }
}
$nPhotos = 0
foreach ($i in $live | Where-Object { $_['type'] -eq 'photo' } | Sort-Object { "$($_['date'])" }) {
  if ($baseIds.Contains($i['id'])) { continue }
  $c = Find-City $i['city']; if (-not $c) { continue }
  Save-DataUrl $i['full'] (Join-Path $Out "photos\$($i['id']).jpg")
  Save-DataUrl $i['mini'] (Join-Path $Out "mini\$($i['id']).jpg")
  $p = Get-Place $c "$($i['place'])"
  [void]$p['photos'].Add(@{ id = $i['id']; date = $i['date'] })
  $nPhotos++
}
$nObj = 0
foreach ($i in $live | Where-Object { $_['type'] -eq 'object' }) {
  $c = Find-City $i['city']; if (-not $c) { continue }
  Save-DataUrl $i['img'] (Join-Path $Out "objets\$($i['id']).png")
  [void]$c['objects'].Add(@{ id = $i['id'] })
  $nObj++
}
foreach ($i in $live | Where-Object { $_['type'] -eq 'note' }) {
  $c = Find-City $i['city']; if (-not $c) { continue }
  [void]$c['notes'].Add(@{ id = $i['id']; text = $i['text']; color = $(if ($i['color']) { $i['color'] } else { 'jaune' }) })
}
foreach ($i in $live | Where-Object { $_['type'] -eq 'cover' }) {
  $c = Find-City $i['city']; if ($c) { $c['cover'] = $i['photo'] }
}
$captions = @{}
foreach ($i in $live | Where-Object { $_['type'] -eq 'caption' }) { $captions[$i['photo']] = "$($i['text'])" }
foreach ($t in $trips) { foreach ($p in $t['places']) { foreach ($ph in $p['photos']) {
  if ($captions.ContainsKey($ph['id'])) {
    if ($captions[$ph['id']]) { $ph['caption'] = $captions[$ph['id']] } elseif ($ph.ContainsKey('caption')) { [void]$ph.Remove('caption') }
  }
} } }
foreach ($i in $live | Where-Object { $_['type'] -eq 'wish' }) {
  $w = @{}; foreach ($k in $i.Keys) { if ($k -ne 'type') { $w[$k] = $i[$k] } }
  $wishes[$i['id']] = $w
}
foreach ($id in @($wishes.Keys)) { if ($deleted.Contains("$id")) { $wishes.Remove($id) } }
foreach ($i in $live | Where-Object { $_['type'] -eq 'settings' }) {
  foreach ($k in 'title', 'palette') { if ($i.ContainsKey($k) -and $i[$k]) { $settings[$k] = $i[$k] } }
}
# Elements prives (champ "private" ou choix fait depuis la page) et supprimes : jamais publies
$private = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($t in $trips) {
  foreach ($x in @($t['objects']) + @($t['notes']) + @($t['places'] | ForEach-Object { $_['photos'] })) {
    if ($x -and $x.ContainsKey('private') -and $x['private']) { [void]$private.Add($x['id']) }
  }
}
foreach ($i in $live | Where-Object { $_['type'] -eq 'private' }) {
  if ($i['on']) { [void]$private.Add($i['target']) } else { [void]$private.Remove($i['target']) }
}
$nHidden = 0
foreach ($t in $trips) {
  foreach ($k in 'objects', 'notes') {
    foreach ($x in @($t[$k])) { if ($deleted.Contains($x['id']) -or $private.Contains($x['id'])) { $t[$k].Remove($x); $nHidden++ } }
  }
  foreach ($p in $t['places']) {
    foreach ($ph in @($p['photos'])) { if ($deleted.Contains($ph['id']) -or $private.Contains($ph['id'])) { $p['photos'].Remove($ph); $nHidden++ } }
  }
  if ($t.ContainsKey('cover') -and ($deleted.Contains("$($t['cover'])") -or $private.Contains("$($t['cover'])"))) { [void]$t.Remove('cover') }
}
# Les lieux sans photo ne sont pas affiches : on les retire
foreach ($t in $trips) {
  foreach ($p in @($t['places'])) { if ($p['photos'].Count -eq 0) { $t['places'].Remove($p) } }
}
# Fichiers images des elements retires (prives, supprimes) : on ne les publie pas
$keep = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($t in $trips) {
  foreach ($p in $t['places']) { foreach ($ph in $p['photos']) { [void]$keep.Add("$($ph['id']).jpg") } }
  foreach ($o in $t['objects']) { [void]$keep.Add("$($o['id']).png") }
}
foreach ($d in 'photos', 'mini', 'objets') {
  Get-ChildItem (Join-Path $Out $d) -File | Where-Object { -not $keep.Contains($_.Name) } | Remove-Item -Force
}

# --- Ecriture ---
$data = "// Donnees de la carte (genere par outils/preparer_github.ps1, ne pas modifier a la main)`n" +
  "window.TRIPS = " + $json.Serialize((Clean $trips)) + ";`n" +
  "window.WISHES = " + $json.Serialize((Clean @($wishes.Values))) + ";`n" +
  "window.SETTINGS = " + $json.Serialize((Clean $settings)) + ";`n"
[IO.File]::WriteAllText((Join-Path $Out 'data.js'), $data, $utf8)
[IO.File]::WriteAllText((Join-Path $Out 'config.js'), "// Version publiee : consultation seule`nwindow.MODE_LECTURE = true;`n", $utf8)
[IO.File]::WriteAllText((Join-Path $Out '.nojekyll'), '', $utf8)
$readme = Join-Path $PSScriptRoot 'README-github.md'
if (Test-Path $readme) { Copy-Item $readme (Join-Path $Out 'README.md') }

foreach ($d in 'objets', 'photos', 'mini') {
  $p = Join-Path $Out $d
  if (-not (Get-ChildItem $p)) { Remove-Item $p }     # dossier vide : inutile (GitHub ne garde pas les dossiers vides)
}
$files = Get-ChildItem $Out -Recurse -File
$size = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 1)
Write-Host ""
Write-Host "Termine : $($trips.Count) villes, $nPhotos photo(s) et $nObj objet(s) ajoutes depuis ajouts.js, $($wishes.Count) ville(s) a visiter."
Write-Host "Elements prives ou supprimes non publies : $nHidden"
Write-Host "Dossier pret : $Out ($($files.Count) fichiers, $size Mo)"
