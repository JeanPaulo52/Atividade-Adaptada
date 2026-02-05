# Script para varrer o projeto e gerar mapa de ALL old->new paths

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"

Write-Host "Gerando mapa de paths antigos e novos..." -ForegroundColor Cyan

# Encontrar todos os paths que contêm espaço ou acento
$pathsComProblemas = @(Get-ChildItem -Path $raiz -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô ]" })

Write-Host "Encontradas $($pathsComProblemas.Count) pastas com espaços/acentos:" -ForegroundColor Yellow

foreach ($pasta in $pathsComProblemas) {
    Write-Host "  $($pasta.FullName)" -ForegroundColor Green
}

# Verificar se existem pastas renomeadas correspondentes
Write-Host "`nVerificando pastas renomeadas correspondentes..." -ForegroundColor Cyan

foreach ($pasta in $pathsComProblemas) {
    $nomeAtual = $pasta.Name
    
    # Gerar o novo nome esperado
    $nomeLimpo = $nomeAtual
    $nomeLimpo = $nomeLimpo -replace "á", "a"
    $nomeLimpo = $nomeLimpo -replace "é", "e"
    $nomeLimpo = $nomeLimpo -replace "í", "i"
    $nomeLimpo = $nomeLimpo -replace "ó", "o"
    $nomeLimpo = $nomeLimpo -replace "ú", "u"
    $nomeLimpo = $nomeLimpo -replace "ã", "a"
    $nomeLimpo = $nomeLimpo -replace "õ", "o"
    $nomeLimpo = $nomeLimpo -replace "ç", "c"
    $nomeLimpo = $nomeLimpo -replace "â", "a"
    $nomeLimpo = $nomeLimpo -replace "ê", "e"
    $nomeLimpo = $nomeLimpo -replace "ô", "o"
    $nomeLimpo = $nomeLimpo -replace " ", "-"
    $nomeLimpo = $nomeLimpo.ToLower()
    
    $caminhoNovo = Join-Path (Split-Path $pasta.FullName) $nomeLimpo
    
    if (Test-Path $caminhoNovo) {
        Write-Host "    $nomeAtual => $nomeLimpo (JÁ RENOMEADO)" -ForegroundColor Green
    } else {
        Write-Host "    $nomeAtual => $nomeLimpo (NÃO ENCONTRADO)" -ForegroundColor Red
    }
}
