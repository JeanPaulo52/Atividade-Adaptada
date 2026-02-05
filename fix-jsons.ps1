$jsonDir = "c:\Users\jean\Desktop\Atividade Adaptada.com\js"
$updated = 0

$files = Get-ChildItem -Path $jsonDir -Filter "*.json"
foreach ($file in $files) {
    $path = $file.FullName
    [string]$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $original = $content
    
    $content = $content.Replace("/2-BNCC/", "/2-bncc/")
    $content = $content.Replace("/Artes/", "/artes/")
    $content = $content.Replace("/Biologia/", "/biologia/")
    $content = $content.Replace("/Ciencias/", "/ciencias/")
    $content = $content.Replace("/Filosofia/", "/filosofia/")
    $content = $content.Replace("/Fisica/", "/fisica/")
    $content = $content.Replace("/Geografia/", "/geografia/")
    $content = $content.Replace("/Historia/", "/historia/")
    $content = $content.Replace("/Ingles/", "/ingles/")
    $content = $content.Replace("/Matematica/", "/matematica/")
    $content = $content.Replace("/Quimica/", "/quimica/")
    $content = $content.Replace("/Sociologia/", "/sociologia/")
    $content = $content.Replace("/PagDow/", "/pagdow/")
    
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Atualizado: $($file.Name)"
        $updated++
    }
}

Write-Host "`nTotal: $updated arquivos atualizados"
