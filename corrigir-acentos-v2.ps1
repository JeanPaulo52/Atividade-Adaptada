# Script simples para remover acentos usando -replace

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  REMOVENDO ACENTOS E ESPACOS v2" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$totalRenomeados = 0
$totalErros = 0

# Primeiro: Renomear PASTAS
Write-Host "`n[1/2] Renomeando PASTAS..." -ForegroundColor Yellow

$pastas = @(Get-ChildItem -Path $raiz -Recurse -Directory -ErrorAction SilentlyContinue | Sort-Object -Property FullName -Descending)

foreach ($pasta in $pastas) {
    $nomeAtual = $pasta.Name
    
    # Se tem acento ou espaco, limpar
    if ($nomeAtual -match "[áéíóúãõçâêô ]") {
        $nomeLimpo = $nomeAtual
        $nomeLimpo = $nomeLimpo -replace "á", "a"
        $nomeLimpo = $nomeLimpo -replace "é", "e"
        $nomeLimpo = $nomeLimpo -replace "í", "i"
        $nomeLimpo = $nomeLimpo -replace "ó", "o"
        $nomeLimpo = $nomeLimpo -replace "ú", "u"
        $nomeLimpo = $nomeLimpo -replace "ã", "a"
        $nomeLimpo = $nomeLimpo -replace "õ", "o"
        $nomeLimpo = $nomeLimpo -replace "ç", "c"
        $nomeLimpo = $nomeLimpo -replace "â", "a"
        $nomeLimpo = $nomeLimpo -replace "ê", "e"
        $nomeLimpo = $nomeLimpo -replace "ô", "o"
        $nomeLimpo = $nomeLimpo -replace " ", "-"
        $nomeLimpo = $nomeLimpo.ToLower()
        
        $caminhoNovo = Join-Path (Split-Path $pasta.FullName) $nomeLimpo
        
        if ($nomeLimpo -ne $nomeAtual) {
            try {
                if (!(Test-Path $caminhoNovo)) {
                    Rename-Item -Path $pasta.FullName -NewName $nomeLimpo -Force
                    Write-Host "  OK: '$nomeAtual' -> '$nomeLimpo'" -ForegroundColor Green
                    $totalRenomeados++
                }
            } catch {
                Write-Host "  ERRO: $_" -ForegroundColor Red
                $totalErros++
            }
        }
    }
}

# Segundo: Renomear ARQUIVOS
Write-Host "`n[2/2] Renomeando ARQUIVOS..." -ForegroundColor Yellow

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -File -ErrorAction SilentlyContinue | Sort-Object -Property FullName -Descending)

foreach ($arquivo in $arquivos) {
    $nomeAtual = $arquivo.Name
    
    if ($nomeAtual -match "[áéíóúãõçâêô ]") {
        $extensao = [System.IO.Path]::GetExtension($arquivo.Name)
        $nomeSemExt = [System.IO.Path]::GetFileNameWithoutExtension($arquivo.Name)
        
        $nomeLimpo = $nomeSemExt
        $nomeLimpo = $nomeLimpo -replace "á", "a"
        $nomeLimpo = $nomeLimpo -replace "é", "e"
        $nomeLimpo = $nomeLimpo -replace "í", "i"
        $nomeLimpo = $nomeLimpo -replace "ó", "o"
        $nomeLimpo = $nomeLimpo -replace "ú", "u"
        $nomeLimpo = $nomeLimpo -replace "ã", "a"
        $nomeLimpo = $nomeLimpo -replace "õ", "o"
        $nomeLimpo = $nomeLimpo -replace "ç", "c"
        $nomeLimpo = $nomeLimpo -replace "â", "a"
        $nomeLimpo = $nomeLimpo -replace "ê", "e"
        $nomeLimpo = $nomeLimpo -replace "ô", "o"
        $nomeLimpo = $nomeLimpo -replace " ", "-"
        $nomeLimpo = $nomeLimpo.ToLower() + $extensao
        
        if ($nomeLimpo -ne $nomeAtual) {
            try {
                Rename-Item -Path $arquivo.FullName -NewName $nomeLimpo -Force
                Write-Host "  OK: '$nomeAtual' -> '$nomeLimpo'" -ForegroundColor Green
                $totalRenomeados++
            } catch {
                Write-Host "  ERRO: $_" -ForegroundColor Red
                $totalErros++
            }
        }
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "RESUMO: $totalRenomeados renomeados, $totalErros erros" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
