$jsonDir = "c:\Users\jean\Desktop\Atividade Adaptada.com\js"
$updatedCount = 0

# Array com os nomes dos arquivos que precisam atualizar
$files = @(
    "artes.json",
    "Artigos.json",
    "BNCC.json",
    "biologia.json",
    "ciencias.json",
    "educacaofisica.json",
    "educacao_financeira.json",
    "filosofia.json",
    "fisica.json",
    "geografia.json",
    "historia.json",
    "ingles.json",
    "inicio.json",
    "infantil.json",
    "livros.json",
    "matematica.json",
    "portugues.json",
    "quimica.json",
    "raciocinio.json",
    "simulado.json",
    "sociologia.json",
    "pintura.json"
)

foreach ($fileName in $files) {
    $filePath = Join-Path $jsonDir $fileName
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw -Encoding UTF8
        $original = $content
        
        # Substituições de pastas em maiúsculas para minúsculas
        $content = $content -replace '"/2-BNCC/', '"/2-bncc/'
        $content = $content -replace '"/Artes/', '"/artes/'
        $content = $content -replace '"/Biologia/', '"/biologia/'
        $content = $content -replace '"/Ciencias/', '"/ciencias/'
        $content = $content -replace '"/Educacao Fisica/', '"/educacao-fisica/'
        $content = $content -replace '"/Educacao_financeira/', '"/educacao-financeira/'
        $content = $content -replace '"/Filosofia/', '"/filosofia/'
        $content = $content -replace '"/Fisica/', '"/fisica/'
        $content = $content -replace '"/Geografia/', '"/geografia/'
        $content = $content -replace '"/Historia/', '"/historia/'
        $content = $content -replace '"/Ingles/', '"/ingles/'
        $content = $content -replace '"/Lingua Portuguesa/', '"/lingua-portuguesa/'
        $content = $content -replace '"/Matematica/', '"/matematica/'
        $content = $content -replace '"/Quimica/', '"/quimica/'
        $content = $content -replace '"/Sociologia/', '"/sociologia/'
        $content = $content -replace '"/PagDow/', '"/pagdow/'
        $content = $content -replace '"/Raciocinio/', '"/raciocinio/'
        $content = $content -replace '"/Infantil/', '"/infantil/'
        $content = $content -replace '"/Pintura/', '"/pintura/'
        
        if ($content -ne $original) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8
            Write-Host "Atualizado: $fileName"
            $updatedCount++
        }
    }
}

Write-Host "`nTotal de arquivos atualizados: $updatedCount"
