# Script para corrigir todos os canonical links
# Remove espaços, maiúsculas, e caracteres especiais

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"

# Função para normalizar a URL
function Normalize-CanonicalURL {
    param(
        [string]$FilePath
    )
    
    # Obter o caminho relativo a partir da raiz do site
    $RelativePath = $FilePath.Replace($RootPath, "").Replace("\", "/").TrimStart("/")
    
    # Se for index.html na raiz, retorna apenas /
    if ($RelativePath -eq "index.html") {
        return "https://www.atividadeadaptada.com.br/"
    }
    
    # Se o arquivo for login ou resultados na raiz
    if ($RelativePath -eq "login.html" -or $RelativePath -eq "resultados.html") {
        return "https://www.atividadeadaptada.com/$RelativePath"
    }
    
    # Dividir o caminho em partes
    $Parts = $RelativePath -split "/"
    
    # Normalizar cada parte: lowercase, remover espaços, remover caracteres especiais
    $NormalizedParts = @()
    foreach ($Part in $Parts) {
        if ($Part -ne "") {
            # Converter para minúsculas
            $Part = $Part.ToLower()
            
            # Remover espaços e substituir por hífen
            $Part = $Part -replace " ", "-"
            
            # Remover caracteres especiais (manter apenas alfanuméricos, hífen, ponto e underline)
            $Part = $Part -replace "[^a-z0-9._-]", ""
            
            # Remover hífens duplicados
            $Part = $Part -replace "-+", "-"
            
            # Remover hífens no início e fim
            $Part = $Part.Trim("-")
            
            if ($Part -ne "") {
                $NormalizedParts += $Part
            }
        }
    }
    
    $NormalizedPath = $NormalizedParts -join "/"
    return "https://www.atividadeadaptada.com/$NormalizedPath"
}

# Encontrar todos os arquivos HTML
$HtmlFiles = Get-ChildItem -Path $RootPath -Filter "*.html" -Recurse

$Counter = 0
$Updated = 0

foreach ($File in $HtmlFiles) {
    $Counter++
    $Content = Get-Content -Path $File.FullName -Encoding UTF8 -Raw
    
    # Verificar se o arquivo tem canonical
    if ($Content -match '<link\s+rel="canonical"\s+href="([^"]+)"') {
        $OldCanonical = $matches[1]
        $NewCanonical = Normalize-CanonicalURL -FilePath $File.FullName
        
        if ($OldCanonical -ne $NewCanonical) {
            Write-Host "Corrigindo: $($File.Name)"
            Write-Host "  De: $OldCanonical"
            Write-Host "  Para: $NewCanonical"
            Write-Host ""
            
            # Substituir o canonical
            $NewContent = $Content -replace [regex]::Escape('<link rel="canonical" href="' + $OldCanonical + '"'), ('<link rel="canonical" href="' + $NewCanonical + '"')
            
            # Salvar o arquivo
            Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8 -NoNewline
            $Updated++
        }
    }
}

Write-Host "=========================================="
Write-Host "Processados: $Counter arquivos"
Write-Host "Atualizados: $Updated arquivos"
Write-Host "=========================================="
