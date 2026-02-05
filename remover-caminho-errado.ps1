# Script para remover o caminho errado dos canonical links
$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"

$HtmlFiles = Get-ChildItem -Path $RootPath -Filter "*.html" -Recurse

Write-Host "Removendo caminho errado dos canonical links..."

$Updated = 0

foreach ($File in $HtmlFiles) {
    $Content = Get-Content -Path $File.FullName -Encoding UTF8 -Raw
    
    if ($Content -match 'href="https://www.atividadeadaptada.com/c/users/jean/desktop/atividade-adaptada.com/') {
        # Remover o caminho errado
        $NewContent = $Content -replace 'href="https://www.atividadeadaptada.com/c/users/jean/desktop/atividade-adaptada.com/', 'href="https://www.atividadeadaptada.com/'
        
        Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8 -NoNewline
        Write-Host "Corrigido: $($File.Name)"
        $Updated++
    }
}

Write-Host "Total corrigido: $Updated arquivos"
