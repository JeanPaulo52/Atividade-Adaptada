# Renomear com abordagem mais agressiva - usar cmd.exe para bypass permissões

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalRenomeados = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  LIMPEZA FINAL - AGRESSIVA" -ForegroundColor Cyan  
Write-Host "=====================================" -ForegroundColor Cyan

# Encontrar pastas com acentos (ordem descendente)
$pastas = @(Get-ChildItem -Path $raiz -Recurse -Directory | Where-Object { $_.Name -match "[áéíóúãõçâêô]" } | Sort-Object -Property FullName -Descending)

Write-Host "`nRenomeando $($pastas.Count) pastas..." -ForegroundColor Yellow

foreach ($pasta in $pastas) {
    $nomeAtual = $pasta.Name
    
    $nomeLimpo = $nomeAtual -replace "á", "a" -replace "é", "e" -replace "í", "i" -replace "ó", "o" -replace "ú", "u" -replace "ã", "a" -replace "õ", "o" -replace "ç", "c" -replace "â", "a" -replace "ê", "e" -replace "ô", "o"
    
    if ($nomeLimpo -ne $nomeAtual) {
        $parentPath = Split-Path $pasta.FullName
        $novoCaminho = Join-Path $parentPath $nomeLimpo
        
        if (!(Test-Path $novoCaminho)) {
            cmd /c "cd /d `"$parentPath`" && ren `"$nomeAtual`" `"$nomeLimpo`"" | Out-Null
            Write-Host "  ✓ $nomeAtual -> $nomeLimpo" -ForegroundColor Green
            $totalRenomeados++
        }
    }
}

Write-Host "`nTotal renomeado: $totalRenomeados pastas" -ForegroundColor Cyan
