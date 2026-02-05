# Script para corrigir todos os links nos arquivos JSON

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$totalArquivos = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  CORRIGINDO LINKS NOS JSONs" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Mapa de substituições principais
$substituicoes = @(
    # Pastas principais
    @{ antigo = '\Nivel 2\'; novo = '/nivel-2/' }
    @{ antigo = '/Nivel 2/'; novo = '/nivel-2/' }
    @{ antigo = '\\Nivel 2\\'; novo = '/nivel-2/' }
    
    # Subpastas
    @{ antigo = '\1-pagina inicial\'; novo = '/1-pagina-inicial/' }
    @{ antigo = '/1-pagina inicial/'; novo = '/1-pagina-inicial/' }
    @{ antigo = '\4-Outras atividades\'; novo = '/4-outras-atividades/' }
    @{ antigo = '/4-Outras atividades/'; novo = '/4-outras-atividades/' }
    @{ antigo = '\5-recortar e pintar\'; novo = '/5-recortar-e-pintar/' }
    @{ antigo = '/5-recortar e pintar/'; novo = '/5-recortar-e-pintar/' }
    
    # Converter todas as barras invertidas para forward slashes
    @{ antigo = '\'; novo = '/' }
)

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -Include @("*.json") -ErrorAction SilentlyContinue)

Write-Host "Processando $($arquivos.Count) arquivos JSON..." -ForegroundColor Yellow
Write-Host ""

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content $arquivo.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    
    if ($null -eq $conteudo) { continue }
    
    $conteudoOriginal = $conteudo
    
    foreach ($sub in $substituicoes) {
        $conteudo = $conteudo -replace [regex]::Escape($sub.antigo), $sub.novo
    }
    
    if ($conteudo -ne $conteudoOriginal) {
        Set-Content $arquivo.FullName $conteudo -Encoding UTF8 -NoNewline -ErrorAction SilentlyContinue
        Write-Host "  OK: $($arquivo.Name)" -ForegroundColor Green
        $totalArquivos++
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Total de JSONs corrigidos: $totalArquivos" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
