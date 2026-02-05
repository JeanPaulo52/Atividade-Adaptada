$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com\js"
$corretos = 0

Write-Host "Corrigindo JSONs..." -ForegroundColor Cyan

$jsons = Get-ChildItem -Path $raiz -Filter "*.json"

foreach ($json in $jsons) {
    $conteudo = Get-Content $json.FullName -Raw -Encoding UTF8
    $original = $conteudo
    
    $conteudo = $conteudo -replace '//+', '/'
    $conteudo = $conteudo -replace '\\', '/'
    
    if ($conteudo -ne $original) {
        Set-Content $json.FullName $conteudo -Encoding UTF8 -NoNewline
        Write-Host "OK: $($json.Name)" -ForegroundColor Green
        $corretos++
    }
}

Write-Host "Total: $corretos" -ForegroundColor Green
