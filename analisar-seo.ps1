# Script simples para analisar problemas de SEO em todos os HTMLs

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$htmlFiles = @(Get-ChildItem -Path $RootPath -Recurse -Filter "*.html")

$totalFiles = $htmlFiles.Count
$filesWithIssues = 0
$issuesList = @()

Write-Host "`n=== Analisando $totalFiles arquivos HTML ===" -ForegroundColor Cyan

for ($i = 0; $i -lt $htmlFiles.Count; $i++) {
    $file = $htmlFiles[$i]
    $fileName = $file.FullName -replace [regex]::Escape($RootPath), ''
    
    $progress = [Math]::Round(($i / $htmlFiles.Count) * 100)
    Write-Host "[$progress%] " -NoNewline -ForegroundColor Gray
    Write-Host "$fileName" -NoNewline
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $problems = @()
    
    # Verificacoes
    if ($content -notmatch '<meta\s+name="description"') {
        $problems += "Meta description"
    }
    if ($content -notmatch '<meta\s+property="og:title"') {
        $problems += "Open Graph"
    }
    if ($content -notmatch '<link\s+rel="canonical"') {
        $problems += "Canonical"
    }
    if ($content -notmatch '<script\s+type="application/ld\+json"') {
        $problems += "Schema JSON-LD"
    }
    
    if ($problems.Count -gt 0) {
        Write-Host " [PROBLEMAS]" -ForegroundColor Yellow
        $filesWithIssues++
        $issuesList += @{ File = $fileName; Issues = $problems -join ', ' }
    } else {
        Write-Host " [OK]" -ForegroundColor Green
    }
}

Write-Host "`n=== RELATORIO ===" -ForegroundColor Cyan
Write-Host "Total: $totalFiles | Com problemas: $filesWithIssues | OK: $($totalFiles - $filesWithIssues)" -ForegroundColor Cyan

if ($filesWithIssues -gt 0) {
    Write-Host "`nPrimeiros 20 arquivos com problemas:" -ForegroundColor Yellow
    $issuesList | Select-Object -First 20 | ForEach-Object {
        Write-Host "  - $($_.File)" -ForegroundColor Yellow
        Write-Host "    Faltam: $($_.Issues)" -ForegroundColor Gray
    }
}
