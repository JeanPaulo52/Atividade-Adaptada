$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ANALISE DE ARQUIVOS COM ACENTOS/ESPACOS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Encontrar pastas com problemas - essas PRECISAM ser renomeadas (afetam muitos arquivos)
$pastasProblematicas = Get-ChildItem -Path $raiz -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô ]" }

Write-Host "PASTAS COM ACENTOS/ESPACOS (CRITICAS):" -ForegroundColor Red
Write-Host "Total: $($pastasProblematicas.Count) pastas`n" -ForegroundColor Yellow

$pastasProblematicas | Select-Object -First 20 | ForEach-Object {
    $novoNome = $_.Name -creplace '[áàâãäèéêëìíîïòóôõöùúûüñç ]', {
        switch ($_) {
            'á' { 'a' } 'à' { 'a' } 'â' { 'a' } 'ã' { 'a' } 'ä' { 'a' }
            'é' { 'e' } 'è' { 'e' } 'ê' { 'e' } 'ë' { 'e' }
            'í' { 'i' } 'ì' { 'i' } 'î' { 'i' } 'ï' { 'i' }
            'ó' { 'o' } 'ò' { 'o' } 'ô' { 'o' } 'õ' { 'o' } 'ö' { 'o' }
            'ú' { 'u' } 'ù' { 'u' } 'û' { 'u' } 'ü' { 'u' }
            'ñ' { 'n' } 'ç' { 'c' }
            ' ' { '-' }
            default { $_ }
        }
    }
    Write-Host "  $($_.Name) => $novoNome" -ForegroundColor Gray
}

if ($pastasProblematicas.Count -gt 20) {
    Write-Host "  ... e $($pastasProblematicas.Count - 20) pastas adicionais" -ForegroundColor Gray
}

# Encontrar arquivos com problemas
$arquivosProblematicos = Get-ChildItem -Path $raiz -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô ]" }

Write-Host "`nARQUIVOS COM ACENTOS/ESPACOS (SECUNDARIOS):" -ForegroundColor Red
Write-Host "Total: $($arquivosProblematicos.Count) arquivos`n" -ForegroundColor Yellow

$arquivosProblematicos | Select-Object -First 15 | ForEach-Object {
    $novoNome = $_.BaseName -creplace '[áàâãäèéêëìíîïòóôõöùúûüñç ]', {
        switch ($_) {
            'á' { 'a' } 'à' { 'a' } 'â' { 'a' } 'ã' { 'a' } 'ä' { 'a' }
            'é' { 'e' } 'è' { 'e' } 'ê' { 'e' } 'ë' { 'e' }
            'í' { 'i' } 'ì' { 'i' } 'î' { 'i' } 'ï' { 'i' }
            'ó' { 'o' } 'ò' { 'o' } 'ô' { 'o' } 'õ' { 'o' } 'ö' { 'o' }
            'ú' { 'u' } 'ù' { 'u' } 'û' { 'u' } 'ü' { 'u' }
            'ñ' { 'n' } 'ç' { 'c' }
            ' ' { '-' }
            default { $_ }
        }
    } + $_.Extension
    Write-Host "  $($_.Name) => $novoNome" -ForegroundColor Gray
}

if ($arquivosProblematicos.Count -gt 15) {
    Write-Host "  ... e $($arquivosProblematicos.Count - 15) arquivos adicionais" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUMO:" -ForegroundColor Cyan
Write-Host "  Pastas problemáticas: $($pastasProblematicas.Count)" -ForegroundColor Yellow
Write-Host "  Arquivos problemáticos: $($arquivosProblematicos.Count)" -ForegroundColor Yellow
Write-Host "  TOTAL: $($pastasProblematicas.Count + $arquivosProblematicos.Count) itens" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Recomendacao: Execute corrigir-tudo.ps1 para renomear todos automaticamente" -ForegroundColor Green
