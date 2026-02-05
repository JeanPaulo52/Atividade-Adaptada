# Script para corrigir referências finais após renomeação de pastas internas

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalAtualizacoes = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  CORRIGINDO PASTAS COM ESPACOS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Mapa de substituições exatas
$substituicoes = @(
    @{ antigo = '1-pagina-inicial'; novo = '1-pagina-inicial' }
    @{ antigo = '4-outras-atividades'; novo = '4-outras-atividades' }
    @{ antigo = '5-recortar-e-pintar'; novo = '5-recortar-e-pintar' }
)

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -Include @("*.html", "*.json", "*.js", "*.css", "*.ps1") -ErrorAction SilentlyContinue)

Write-Host "Processando $($arquivos.Count) arquivos..." -ForegroundColor Yellow
Write-Host ""

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content $arquivo.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    
    if ($null -eq $conteudo) { continue }
    
    $conteudoOriginal = $conteudo
    
    foreach ($sub in $substituicoes) {
        $conteudo = $conteudo -replace [regex]::Escape($sub.antigo), $sub.novo
    }
    
    # Se houver mudanças, salvar arquivo
    if ($conteudo -ne $conteudoOriginal) {
        try {
            Set-Content $arquivo.FullName $conteudo -Encoding UTF8 -NoNewline
            Write-Host "  OK: $($arquivo.Name)" -ForegroundColor Green
            $totalAtualizacoes++
        } catch {
            Write-Host "  ERRO: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Total de arquivos atualizados: $totalAtualizacoes" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
