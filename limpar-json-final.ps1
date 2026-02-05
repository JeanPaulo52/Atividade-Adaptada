# Script para limpar os JSONs de forma mais agressiva

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalCorrigidos = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  LIMPEZA FINAL DOS JSONs" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$arquivos = @(Get-ChildItem -Path "$raiz\js" -Include "*.json" -ErrorAction SilentlyContinue)

Write-Host "Processando $($arquivos.Count) arquivos JSON..." -ForegroundColor Yellow

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content $arquivo.FullName -Raw -Encoding UTF8
    $original = $conteudo
    
    # 1. Remover // duplicados
    while ($conteudo -match "//") {
        $conteudo = $conteudo -replace "//", "/"
    }
    
    # 2. Remover espaços seguidos de /
    $conteudo = $conteudo -replace " /", "/"
    
    # 3. Substituir espaços por hífens nos caminhos (dentro de aspas)
    $conteudo = $conteudo -replace '/([^"]*) ([^/"]*)/', '/$($1.Replace(" ", "-"))' 
    
    # Abordagem alternativa mais simples - substituir padrões específicos conhecidos
    $conteudo = $conteudo -replace 'A Minha Bolha de Dança', 'a-minha-bolha-de-danca'
    $conteudo = $conteudo -replace 'Criando com Danças do Brasil', 'criando-com-dancas-do-brasil'
    $conteudo = $conteudo -replace 'Descobrindo o Carimbó', 'descobrindo-o-carimbo'
    $conteudo = $conteudo -replace 'Descobrindo o Jongo', 'descobrindo-o-jongo'
    $conteudo = $conteudo -replace 'Descobrindo o Siriri', 'descobrindo-o-siriri'
    $conteudo = $conteudo -replace 'Da Imaginação à Sonoridade', 'da-imaginacao-a-sonoridade'
    $conteudo = $conteudo -replace 'O Universo do Frevo', 'o-universo-do-frevo'
    $conteudo = $conteudo -replace 'Os Sons das Histórias', 'os-sons-das-historias'
    $conteudo = $conteudo -replace 'O Ensaio Geral', 'o-ensaio-geral'
    $conteudo = $conteudo -replace 'Níveis da Dança', 'niveis-da-danca'
    $conteudo = $conteudo -replace 'Música Para Quê', 'musica-para-que'
    $conteudo = $conteudo -replace 'História com Som', 'historia-com-som'
    $conteudo = $conteudo -replace 'Expressividade na Dança', 'expressividade-na-danca'
    $conteudo = $conteudo -replace 'Explorando a Dança no Espaço', 'explorando-a-danca-no-espaco'
    $conteudo = $conteudo -replace 'Essa Música é o Bicho', 'essa-musica-e-o-bicho'
    $conteudo = $conteudo -replace 'Piá do Mutum', 'pia-do-mutum'
    $conteudo = $conteudo -replace 'Que Música é Essa', 'que-musica-e-essa'
    
    if ($conteudo -ne $original) {
        Set-Content $arquivo.FullName $conteudo -Encoding UTF8 -NoNewline
        Write-Host "  OK: $($arquivo.Name)" -ForegroundColor Green
        $totalCorrigidos++
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Total: $totalCorrigidos JSONs atualizados" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
