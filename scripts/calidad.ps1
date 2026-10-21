# Pruebas de calidad y buenas practicas para terraform/azure (y compilacion de pulumi/azure)
# Uso (desde la raiz del repo): powershell -ExecutionPolicy Bypass -File scripts\calidad.ps1
$ErrorActionPreference = "Continue"
$raiz = Split-Path -Parent $PSScriptRoot
$tfDir = Join-Path $raiz "terraform\azure"
$pulumiDir = Join-Path $raiz "pulumi\azure"
$checkovPython = Join-Path $env:USERPROFILE ".venvs\checkov\Scripts\python.exe"
$resultados = [ordered]@{}

function Paso($nombre, [scriptblock]$accion) {
  Write-Host "`n==== $nombre ====" -ForegroundColor Cyan
  & $accion
  $resultados[$nombre] = if ($LASTEXITCODE -eq 0) { "OK" } else { "FALLA" }
}

Push-Location $tfDir
try {
  Paso "terraform fmt" { terraform fmt -check -recursive }
  Paso "terraform validate" {
    terraform init -backend=false -input=false | Out-Null
    terraform validate
  }
  Paso "tflint" {
    tflint --init | Out-Null
    tflint --format compact
  }
  Paso "trivy" { trivy config --quiet --exit-code 1 . }
  Paso "checkov" { & $checkovPython -m checkov.main -d . --framework terraform --compact --quiet }
}
finally { Pop-Location }

Push-Location $pulumiDir
try {
  Paso "pulumi tsc" { npm.cmd run --silent build }
}
finally { Pop-Location }

Write-Host "`n==== Resumen ====" -ForegroundColor Cyan
$resultados.GetEnumerator() | ForEach-Object {
  $color = if ($_.Value -eq "OK") { "Green" } else { "Red" }
  Write-Host ("{0,-20} {1}" -f $_.Key, $_.Value) -ForegroundColor $color
}
if ($resultados.Values -contains "FALLA") { exit 1 }
