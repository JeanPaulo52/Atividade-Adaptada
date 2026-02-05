function Remove-Diacritics {
    param ([string]$inputString)
    $normalizedString = $inputString.Normalize([System.Text.NormalizationForm]::NFD)
    $stringBuilder = New-Object System.Text.StringBuilder
    $normalizedString.GetEnumerator() | ForEach-Object {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$stringBuilder.Append($_)
        }
    }
    return $stringBuilder.ToString()
}

$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  REMOVENDO ACENTOS E ESPACOS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$totalRenomeados = 0
$totalErros = 0

# Primeiro: Renomear PASTAS (precisam ser feitas primeiro)
Write-Host "`n[1/2] Renomeando PASTAS..." -ForegroundColor Yellow

$pastas = Get-ChildItem -Path $raiz -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô ]" } | Sort-Object -Property FullName -Descending

foreach ($pasta in $pastas) {
    $nomeAtual = $pasta.Name
    $nomeLimpo = Remove-Diacritics $nomeAtual
    $nomeLimpo = $nomeLimpo -replace " ", "-"
    
    if ($nomeLimpo -ne $nomeAtual) {
        $caminhoNovo = Join-Path (Split-Path $pasta.FullName) $nomeLimpo
        
        try {
            if (!(Test-Path $caminhoNovo)) {
                Rename-Item -Path $pasta.FullName -NewName $nomeLimpo -Force -ErrorAction Stop
                Write-Host "  OK: $nomeAtual => $nomeLimpo" -ForegroundColor Green
                $totalRenomeados++
            } else {
                Write-Host "  ERRO: Pasta de destino ja existe: $nomeLimpo" -ForegroundColor Red
                $totalErros++
            }
        } catch {
            Write-Host "  ERRO ao renomear $nomeAtual : $_" -ForegroundColor Red
            $totalErros++
        }
    }
}

Write-Host "`n[2/2] Renomeando ARQUIVOS..." -ForegroundColor Yellow

# Segundo: Renomear ARQUIVOS
$arquivos = Get-ChildItem -Path $raiz -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "[áéíóúãõçâêô ]" }

foreach ($arquivo in $arquivos) {
    $nomeAtual = $arquivo.Name
    $novoNome = Remove-Diacritics $nomeAtual
    $novoNome = $novoNome -replace " ", "-"
    
    if ($novoNome -ne $nomeAtual) {
        $caminhoNovo = Join-Path (Split-Path $arquivo.FullName) $novoNome
        
        try {
            if (!(Test-Path $caminhoNovo)) {
                Rename-Item -Path $arquivo.FullName -NewName $novoNome -Force -ErrorAction Stop
                Write-Host "  OK: $nomeAtual => $novoNome" -ForegroundColor Green
                $totalRenomeados++
            } else {
                Write-Host "  ERRO: Arquivo de destino ja existe: $novoNome" -ForegroundColor Red
                $totalErros++
            }
        } catch {
            Write-Host "  ERRO ao renomear $nomeAtual : $_" -ForegroundColor Red
            $totalErros++
        }
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "RESUMO:" -ForegroundColor Cyan
Write-Host "  Renomeados: $totalRenomeados" -ForegroundColor Green
Write-Host "  Erros: $totalErros" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

Write-Host "`nProxima etapa: Atualizar todas as referencias em HTML, JSON e scripts..." -ForegroundColor Yellow
