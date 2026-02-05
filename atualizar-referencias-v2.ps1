# Script para atualizar TODAS as referências nos arquivos após renomeação de pastas

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalModificados = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  ATUALIZANDO REFERENCIAS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Mapa de substituições baseado nas renomeações feitas
$substituicoes = @(
    # Pastas principais
    @{ antigo = '/nivel-2/'; novo = '/nivel-2/' }
    @{ antigo = '\nivel-2\'; novo = '\nivel-2\' }
    @{ antigo = 'nivel-2'; novo = 'nivel-2' }
    
    # Subpastas de artigos
    @{ antigo = '1-pagina-inicial'; novo = '1-pagina-inicial' }
    @{ antigo = '4-outras-atividades'; novo = '4-outras-atividades' }
    @{ antigo = '5-recortar-e-pintar'; novo = '5-recortar-e-pintar' }
    
    # Disciplinas
    @{ antigo = '/Educacao Fisica'; novo = '/educacao-fisica' }
    @{ antigo = '/Educação Fisica'; novo = '/educacao-fisica' }
    @{ antigo = '\Educacao Fisica'; novo = '\educacao-fisica' }
    @{ antigo = '\Educação Fisica'; novo = '\educacao-fisica' }
    @{ antigo = '/Lingua Portuguesa'; novo = '/lingua-portuguesa' }
    @{ antigo = '/Língua Portuguesa'; novo = '/lingua-portuguesa' }
    @{ antigo = '\Lingua Portuguesa'; novo = '\lingua-portuguesa' }
    @{ antigo = '\Língua Portuguesa'; novo = '\lingua-portuguesa' }
)

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -Include @("*.html", "*.json", "*.js", "*.css") -ErrorAction SilentlyContinue)

Write-Host "Processando $($arquivos.Count) arquivos de conteúdo..." -ForegroundColor Yellow
Write-Host ""

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content $arquivo.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    
    if ($null -eq $conteudo) { continue }
    
    $conteudoOriginal = $conteudo
    
    foreach ($sub in $substituicoes) {
        if ($conteudo -match [regex]::Escape($sub.antigo)) {
            $conteudo = $conteudo -replace [regex]::Escape($sub.antigo), $sub.novo
        }
    }
    
    # Se houver mudanças, salvar arquivo
    if ($conteudo -ne $conteudoOriginal) {
        try {
            Set-Content $arquivo.FullName $conteudo -Encoding UTF8 -NoNewline
            Write-Host "  OK: $($arquivo.Name)" -ForegroundColor Green
            $totalModificados++
        } catch {
            Write-Host "  ERRO: $_" -ForegroundColor Red
        }
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "RESUMO:" -ForegroundColor Cyan
Write-Host "  Arquivos atualizados: $totalModificados" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
