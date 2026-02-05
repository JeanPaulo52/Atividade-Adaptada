# Script FINAL para corrigir todos os canonical links
# Remove espaços, maiúsculas, e caracteres especiais
# Versão corrigida que gera URLs corretas do site

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"

# Função para normalizar a URL baseado no caminho do arquivo
function Normalize-CanonicalURL {
    param(
        [string]$FilePath
    )
    
    # Obter apenas o caminho relativo a partir do nivel-2 ou da raiz
    $RelativePath = $FilePath.Replace($RootPath, "").Replace("\", "/").TrimStart("/")
    
    # Se for index.html na raiz
    if ($RelativePath -eq "index.html") {
        return "https://www.atividadeadaptada.com.br/"
    }
    
    # Se for login.html ou resultados.html na raiz
    if ($RelativePath -eq "login.html" -or $RelativePath -eq "resultados.html") {
        return "https://www.atividadeadaptada.com/$RelativePath"
    }
    
    # Dividir o caminho em partes e normalizar cada uma
    $Parts = $RelativePath -split "/"
    $NormalizedParts = @()
    
    foreach ($Part in $Parts) {
        if ($Part -and $Part -ne "") {
            # Converter para minúsculas
            $Part = $Part.ToLower()
            
            # Remover espaços e substituir por hífen
            $Part = $Part -replace " ", "-"
            
            # Remover caracteres especiais (manter apenas alfanuméricos, hífen, ponto e underline)
            $Part = $Part -replace "[^a-z0-9._-]", ""
            
            # Remover hífens múltiplos
            $Part = $Part -replace "-+", "-"
            
            # Remover hífens nas extremidades
            $Part = $Part.Trim("-").Trim(".")
            
            if ($Part) {
                $NormalizedParts += $Part
            }
        }
    }
    
    $NormalizedPath = $NormalizedParts -join "/"
    return "https://www.atividadeadaptada.com/$NormalizedPath"
}

# Encontrar todos os arquivos HTML
$HtmlFiles = Get-ChildItem -Path $RootPath -Filter "*.html" -Recurse

Write-Host "Iniciando correção dos canonical links..."
Write-Host "Total de arquivos HTML encontrados: $($HtmlFiles.Count)"
Write-Host ""

$Counter = 0
$Updated = 0
$Errors = 0

foreach ($File in $HtmlFiles) {
    $Counter++
    
    try {
        $Content = Get-Content -Path $File.FullName -Encoding UTF8 -Raw
        
        # Verificar se o arquivo tem um canonical link
        if ($Content -match '<link\s+rel="canonical"\s+href="([^"]+)"') {
            $OldCanonical = $matches[1]
            $NewCanonical = Normalize-CanonicalURL -FilePath $File.FullName
            
            if ($OldCanonical -ne $NewCanonical) {
                Write-Host "Atualizando: $($File.Name)"
                Write-Host "  Antigo: $OldCanonical"
                Write-Host "  Novo:   $NewCanonical"
                Write-Host ""
                
                # Substituir o canonical link
                $NewContent = $Content -replace [regex]::Escape('<link rel="canonical" href="' + $OldCanonical + '"'), ('<link rel="canonical" href="' + $NewCanonical + '"')
                
                # Salvar o arquivo
                Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8 -NoNewline
                $Updated++
            }
        }
    }
    catch {
        Write-Host "ERRO ao processar $($File.FullName): $_"
        $Errors++
    }
}

Write-Host "=========================================="
Write-Host "Processados: $Counter arquivos"
Write-Host "Atualizados: $Updated arquivos"
Write-Host "Erros: $Errors"
Write-Host "=========================================="
