# Script final para corrigir URLs com %20 e adaptar para novos nomes

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalAtualizacoes = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  CORRIGINDO URLs COM %20" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Mapa de substituições: URLs antigas -> novas
$substituicoes = @(
    @{ antigo = '/1-pagina%20inicial/'; novo = '/1-pagina-inicial/' }
    @{ antigo = '%20'; novo = '-' }  # Substituir todos os %20 restantes
    @{ antigo = '4-Outras%20atividades'; novo = '4-outras-atividades' }
    @{ antigo = '5-recortar%20e%20pintar'; novo = '5-recortar-e-pintar' }
    @{ antigo = 'Educacao%20Fisica'; novo = 'educacao-fisica' }
    @{ antigo = 'Lingua%20Portuguesa'; novo = 'lingua-portuguesa' }
)

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -Include @("*.html", "*.json", "*.js", "*.css") -ErrorAction SilentlyContinue)

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
