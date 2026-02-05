# Script agressivo para remover TODOS os acentos restantes

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  LIMPEZA FINAL - REMOVER ACENTOS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$totalRenomeados = 0
$totalErros = 0

# PASSO 1: Renomear TODAS as PASTAS com acentos (ordem descendent)
Write-Host "`n[1/2] Renomeando PASTAS com acentos..." -ForegroundColor Yellow

$pastas = @(Get-ChildItem -Path $raiz -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô]" } | Sort-Object -Property FullName -Descending)

Write-Host "Encontradas $($pastas.Count) pastas para renomear" -ForegroundColor Cyan

foreach ($pasta in $pastas) {
    $nomeAtual = $pasta.Name
    
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
    
    if ($nomeLimpo -ne $nomeAtual) {
        $caminhoNovo = Join-Path (Split-Path $pasta.FullName) $nomeLimpo
        
        if (!(Test-Path $caminhoNovo)) {
            Rename-Item -Path $pasta.FullName -NewName $nomeLimpo -Force -ErrorAction SilentlyContinue
            if ($?) {
                Write-Host "  OK: '$nomeAtual' -> '$nomeLimpo'" -ForegroundColor Green
                $totalRenomeados++
            } else {
                Write-Host "  ERRO: '$nomeAtual'" -ForegroundColor Red
                $totalErros++
            }
        } else {
            Write-Host "  SKIP: '$nomeLimpo' ja existe" -ForegroundColor Yellow
        }
    }
}

# PASSO 2: Renomear TODOS os ARQUIVOS com acentos
Write-Host "`n[2/2] Renomeando ARQUIVOS com acentos..." -ForegroundColor Yellow

$arquivos = @(Get-ChildItem -Path $raiz -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô]" } | Sort-Object -Property FullName -Descending)

Write-Host "Encontrados $($arquivos.Count) arquivos para renomear" -ForegroundColor Cyan

foreach ($arquivo in $arquivos) {
    $nomeAtual = $arquivo.Name
    
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
    $nomeLimpo = $nomeLimpo + $extensao
    
    if ($nomeLimpo -ne $nomeAtual) {
        Rename-Item -Path $arquivo.FullName -NewName $nomeLimpo -Force -ErrorAction SilentlyContinue
        if ($?) {
            Write-Host "  OK: '$nomeAtual' -> '$nomeLimpo'" -ForegroundColor Green
            $totalRenomeados++
        } else {
            Write-Host "  ERRO: '$nomeAtual'" -ForegroundColor Red
            $totalErros++
        }
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "RESUMO:" -ForegroundColor Cyan
Write-Host "  Renomeados: $totalRenomeados" -ForegroundColor Green
Write-Host "  Erros: $totalErros" -ForegroundColor $(if ($totalErros -gt 0) { "Red" } else { "Green" })
Write-Host "=====================================" -ForegroundColor Cyan
