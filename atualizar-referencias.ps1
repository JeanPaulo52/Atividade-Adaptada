# Script para atualizar todas as referências aos arquivos renomeados

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalAtualizacoes = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  ATUALIZANDO REFERENCIAS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Mapa de substituições: caminho antigo -> novo
$substituicoes = @(
    @{ antigo = 'nivel-2'; novo = 'nivel-2' }
    @{ antigo = 'BNCC'; novo = 'bncc' }
    @{ antigo = 'Educação Fisica'; novo = 'educação-fisica' }
    @{ antigo = 'Educação_financeira'; novo = 'educação_financeira' }
    @{ antigo = 'Educação Física'; novo = 'educação-física' }
    @{ antigo = 'Lingua Portuguesa'; novo = 'lingua-portuguesa' }
    @{ antigo = 'Matemática'; novo = 'matemática' }
    @{ antigo = 'PagDow'; novo = 'pagdow' }
)

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -Include @("*.html", "*.json", "*.js") -ErrorAction SilentlyContinue)

Write-Host "Processando $($arquivos.Count) arquivos..." -ForegroundColor Yellow

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content $arquivo.FullName -Raw -Encoding UTF8
    $conteudoOriginal = $conteudo
    
    foreach ($sub in $substituicoes) {
        # Substituir path separado por /
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
