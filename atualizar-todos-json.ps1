$jsonDir = "c:\Users\jean\Desktop\Atividade Adaptada.com\js"
$counter = 0
$files = @()

Get-ChildItem -Path $jsonDir -Filter "*.json" | ForEach-Object {
    $files += $_.FullName
}

foreach ($file in $files) {
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    $original = $content
    
    # Substituições
    $content = $content.Replace("/2-BNCC/", "/2-bncc/")
    $content = $content.Replace("/Artes/", "/artes/")
    $content = $content.Replace("/Biologia/", "/biologia/")
    $content = $content.Replace("/Ciencias/", "/ciencias/")
    $content = $content.Replace("/Educacao Fisica/", "/educacao-fisica/")
    $content = $content.Replace("/Educacao_financeira/", "/educacao-financeira/")
    $content = $content.Replace("/Filosofia/", "/filosofia/")
    $content = $content.Replace("/Fisica/", "/fisica/")
    $content = $content.Replace("/Geografia/", "/geografia/")
    $content = $content.Replace("/Historia/", "/historia/")
    $content = $content.Replace("/Ingles/", "/ingles/")
    $content = $content.Replace("/Lingua Portuguesa/", "/lingua-portuguesa/")
    $content = $content.Replace("/Matematica/", "/matematica/")
    $content = $content.Replace("/Quimica/", "/quimica/")
    $content = $content.Replace("/Sociologia/", "/sociologia/")
    $content = $content.Replace("/PagDow/", "/pagdow/")
    $content = $content.Replace("/1-pagina inicial/", "/1-pagina-inicial/")
    $content = $content.Replace("/4-Outras atividades/", "/4-outras-atividades/")
    $content = $content.Replace("/5-recortar e pintar/", "/5-recortar-e-pintar/")
    
    if ($content -ne $original) {
        Set-Content -Path $file -Value $content -Encoding UTF8
        $counter++
        Write-Host "OK: $(Split-Path $file -Leaf)"
    }
}

Write-Host "Total de JSONs atualizados: $counter"
