$pastaRaiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$arquivosCorrigidos = @()

Write-Host "Iniciando correcao de URLs com espacos nao codificados..." -ForegroundColor Cyan

$arquivos = Get-ChildItem -Path $pastaRaiz -Filter "*.html" -Recurse

Write-Host "Encontrados $($arquivos.Count) arquivos HTML`n" -ForegroundColor Yellow

foreach ($arquivo in $arquivos) {
    $caminho = $arquivo.FullName
    $conteudo = Get-Content -Path $caminho -Encoding UTF8 -Raw
    $conteudoOriginal = $conteudo
    
    # Corrigir href="/nivel-2/
    $conteudo = $conteudo -replace 'href="/nivel-2/', 'href="/nivel-2/'
    
    # Corrigir /nivel-2/1-pagina-inicial/
    $conteudo = $conteudo -replace '/nivel-2/1-pagina-inicial/', '/nivel-2/1-pagina%20inicial/'
    
    # Corrigir /nivel-2/5-recortar-e-pintar/
    $conteudo = $conteudo -replace '/nivel-2/5-recortar-e-pintar/', '/nivel-2/5-recortar%20e%20pintar/'
    
    # Corrigir /nivel-2/6-Quem Somos
    $conteudo = $conteudo -replace '/nivel-2/6-Quem Somos', '/nivel-2/6-Quem%20Somos'
    
    # Corrigir /nivel-2/4-outras-atividades/
    $conteudo = $conteudo -replace '/nivel-2/4-outras-atividades/', '/nivel-2/4-Outras%20atividades/'
    
    # Corrigir canonical URLs com nivel-2
    $conteudo = $conteudo -replace 'https://www.atividadeadaptada.com/nivel-2/', 'https://www.atividadeadaptada.com/nivel-2/'
    
    # Corrigir espacos em caminhos em canonical URLs
    $conteudo = $conteudo -replace 'nivel-2/1-pagina-inicial/', 'nivel-2/1-pagina%20inicial/'
    $conteudo = $conteudo -replace 'nivel-2/5-recortar-e-pintar/', 'nivel-2/5-recortar%20e%20pintar/'
    $conteudo = $conteudo -replace 'nivel-2/6-Quem Somos', 'nivel-2/6-Quem%20Somos'
    $conteudo = $conteudo -replace 'nivel-2/4-outras-atividades/', 'nivel-2/4-Outras%20atividades/'
    
    if ($conteudo -ne $conteudoOriginal) {
        Set-Content -Path $caminho -Value $conteudo -Encoding UTF8
        $arquivosCorrigidos += $caminho
        Write-Host "Corrigido: $($arquivo.Name)" -ForegroundColor Green
    }
}

Write-Host "`nResumo:" -ForegroundColor Cyan
Write-Host "Total de arquivos corrigidos: $($arquivosCorrigidos.Count)" -ForegroundColor Green
Write-Host "Processo concluido!" -ForegroundColor Cyan
