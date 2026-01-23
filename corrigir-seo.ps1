# Script para corrigir problemas de SEO em todos os arquivos HTML
# Este script valida e corrige problemas identificados pelo Google Search Console

param(
    [string]$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com",
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

# Cores para output
$colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
}

function Write-ColorOutput($message, $color = "White") {
    Write-Host $message -ForegroundColor $color
}

function Test-HTMLFile($filePath) {
    $problems = @()
    $content = Get-Content $filePath -Raw -Encoding UTF8
    
    if ($content -notmatch '<meta\s+name="description"') {
        $problems += "Meta description ausente"
    }
    
    if (($content | Select-String '<meta\s+charset=' -AllMatches).Matches.Count -gt 1) {
        $problems += "Charset duplicado"
    }
    
    $h1Count = ($content | Select-String '<h1[^>]*>[^<]*</h1>' -AllMatches).Matches.Count
    if ($h1Count -gt 1) {
        $problems += "Multiplos H1 tags ($h1Count encontrados)"
    }
    
    if ($content -match '<h1[^>]*>\s*</h1>') {
        $problems += "H1 vazio encontrado"
    }
    
    if ($content -notmatch '<meta\s+property="og:title"') {
        $problems += "Open Graph tags ausentes"
    }
    
    if ($content -notmatch '<link\s+rel="canonical"') {
        $problems += "Canonical URL ausente"
    }
    
    if ($content -notmatch '<script\s+type="application/ld\+json"') {
        $problems += "Schema.org estruturado ausente"
    }
    
    return $problems
}

# Array para armazenar problemas encontrados
$issues = @()
$corrected = @()

# Função para detectar problemas
function Test-HTMLFile($filePath) {
    $problems = @()
    $content = Get-Content $filePath -Raw -Encoding UTF8
    
    # Verificar meta description
    if ($content -notmatch '<meta\s+name="description"') {
        $problems += "Meta description ausente"
    }
    
    # Verificar charset duplicado
    if (($content | Select-String '<meta\s+charset=' -AllMatches).Matches.Count -gt 1) {
        $problems += "Charset duplicado"
    }
    
    # Verificar múltiplas H1
    $h1Count = ($content | Select-String '<h1[^>]*>[^<]*</h1>' -AllMatches).Matches.Count
    if ($h1Count -gt 1) {
        $problems += "Múltiplos H1 tags ($h1Count encontrados)"
    }
    
    # Verificar H1 vazio
    if ($content -match '<h1[^>]*>\s*</h1>') {
        $problems += "H1 vazio encontrado"
    }
    
    # Verificar Open Graph tags
    if ($content -notmatch '<meta\s+property="og:title"') {
        $problems += "Open Graph tags ausentes"
    }
    
    # Verificar canonical URL
    if ($content -notmatch '<link\s+rel="canonical"') {
        $problems += "Canonical URL ausente"
    }
    
    # Verificar Schema.org JSON-LD
    if ($content -notmatch '<script\s+type="application/ld\+json"') {
        $problems += "Schema.org estruturado ausente"
    }
    
    # Verificar tags de imagem sem alt
    $imgMatches = [regex]::Matches($content, '<img[^>]*>')
    foreach ($match in $imgMatches) {
        if ($match.Value -notmatch 'alt="[^"]*"' -or $match.Value -match 'alt="\s*"') {
            $problems += "Imagem sem alt text adequado"
            break
        }
    }
    
    # Verificar Google AdSense duplicado
    $adSenseCount = ($content | Select-String 'pagead2.googlesyndication.com/pagead/js/adsbygoogle.js' -AllMatches).Matches.Count
    if ($adSenseCount -gt 1) {
        $problems += "Google AdSense duplicado ($adSenseCount vezes)"
    }
    
    return $problems
}

# Função para corrigir problemas
function Repair-HTMLFile($filePath, $content) {
    $modified = $content
    $fixes = @()
    
    # 1. Adicionar meta description (se não existir)
    if ($modified -notmatch '<meta\s+name="description"') {
        $titleMatch = [regex]::Match($modified, '<title>([^<]+)</title>')
        if ($titleMatch.Success) {
            $title = $titleMatch.Groups[1].Value
            $description = "Atividade educativa: " + $title.Substring(0, [Math]::Min(120, $title.Length))
            $metaDesc = "<meta name=`"description`" content=`"$description`">`n"
            $modified = $modified -replace '(<meta name="viewport"[^>]*>)', "`$1`n    $metaDesc"
            $fixes += "Meta description adicionada"
        }
    }
    
    # 2. Remover H1 vazio
    if ($modified -match '<h1[^>]*>\s*</h1>') {
        $modified = $modified -replace '<h1[^>]*>\s*</h1>\s*', ''
        $fixes += "H1 vazio removido"
    }
    
    # 3. Adicionar Open Graph tags
    if ($modified -notmatch '<meta\s+property="og:title"') {
        $titleMatch = [regex]::Match($modified, '<title>([^<]+)</title>')
        if ($titleMatch.Success) {
            $title = $titleMatch.Groups[1].Value
            $ogTags = @"
    <meta property="og:title" content="$title">
    <meta property="og:description" content="Conteúdo educativo de qualidade">
    <meta name="twitter:card" content="summary_large_image">

"@
            $modified = $modified -replace '(</title>)', "`$1`n$ogTags"
            $fixes += "Open Graph e Twitter tags adicionados"
        }
    }
    
    # 4. Adicionar Canonical URL
    if ($modified -notmatch '<link\s+rel="canonical"') {
        $relPath = ($filePath -replace [regex]::Escape($RootPath), '').TrimStart('\')
        $canonicalTag = "    <link rel=`"canonical`" href=`"https://www.atividadeadaptada.com/$relPath`">`n"
        $modified = $modified -replace '(</title>)', "`$1`n$canonicalTag"
        $fixes += "Canonical URL adicionada"
    }
    
    # 5. Remover Google AdSense duplicado
    $adSensePattern = 'pagead2\.googlesyndication\.com/pagead/js/adsbygoogle\.js[^<]*<[^>]*>'
    $adSenseMatches = [regex]::Matches($modified, '<script[^>]*src="[^"]*' + $adSensePattern)
    if ($adSenseMatches.Count -gt 1) {
        for ($i = 1; $i -lt $adSenseMatches.Count; $i++) {
            $modified = $modified -replace [regex]::Escape($adSenseMatches[$i].Value), ''
        }
        $fixes += "Google AdSense duplicado removido"
    }
    
    # 6. Corrigir alt text de imagens genéricos
    $modified = $modified -replace 'alt="Ilustação da atividade"', 'alt="Atividade educativa"'
    if ($modified -ne $content) {
        $fixes += "Alt text de imagens corrigido"
    }
    
    return @{
        Content = $modified
        Fixes = $fixes
    }
}

# Função principal
function Process-AllHTMLFiles {
    Write-ColorOutput "`n=== Analisando arquivos HTML para problemas de SEO ===" -color $colors.Info
    
    $htmlFiles = @(Get-ChildItem -Path $RootPath -Recurse -Filter "*.html")
    $totalFiles = $htmlFiles.Count
    $filesWithIssues = 0
    
    Write-ColorOutput "Total de arquivos encontrados: $totalFiles`n" -color $colors.Info
    
    for ($i = 0; $i -lt $htmlFiles.Count; $i++) {
        $file = $htmlFiles[$i]
        $fileName = $file.FullName -replace [regex]::Escape($RootPath), ''
        
        $progress = [Math]::Round(($i / $htmlFiles.Count) * 100)
        Write-Host "[$progress`%] Processando: $fileName" -NoNewline -ForegroundColor Gray
        
        $problems = Test-HTMLFile $file.FullName
        
        if ($problems.Count -gt 0) {
            Write-Host " [PROBLEMAS]" -ForegroundColor $colors.Warning
            $filesWithIssues++
            
            if ($Verbose) {
                foreach ($problem in $problems) {
                    Write-ColorOutput "  AVISO: $problem" -color $colors.Warning
                }
            }
            
            if (-not $DryRun) {
                $content = Get-Content $file.FullName -Raw -Encoding UTF8
                $repairResult = Repair-HTMLFile $file.FullName $content
                
                if ($repairResult.Fixes.Count -gt 0) {
                    Set-Content -Path $file.FullName -Value $repairResult.Content -Encoding UTF8
                    $corrected += @{
                        File = $fileName
                        Fixes = $repairResult.Fixes
                    }
                    Write-ColorOutput "  OK: $($repairResult.Fixes -join ', ')" -color $colors.Success
                }
            }
        } else {
            Write-Host " [OK]" -ForegroundColor $colors.Success
        }
    }
    
    Write-ColorOutput "`n=== RELATORIO FINAL ===" -color $colors.Info
    Write-ColorOutput "Total de arquivos processados: $totalFiles" -color $colors.Info
    Write-ColorOutput "Arquivos com problemas: $filesWithIssues" -color $colors.Warning
    Write-ColorOutput "Arquivos corrigidos: $($corrected.Count)" -color $colors.Success
    
    if ($DryRun) {
        Write-ColorOutput "`nModo DRY RUN: Nenhuma alteracao foi realizada!" -color $colors.Warning
        Write-ColorOutput "Execute sem -DryRun para aplicar as correcoes." -color $colors.Info
    }
}

# Executar
Process-AllHTMLFiles
