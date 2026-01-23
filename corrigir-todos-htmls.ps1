# Script para corrigir problemas de SEO em todos os arquivos HTML automaticamente

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$htmlFiles = @(Get-ChildItem -Path $RootPath -Recurse -Filter "*.html")

$totalFiles = $htmlFiles.Count
$filesFixed = 0
$filesFailed = 0

Write-Host "`n=== CORRIGINDO SEO EM TODOS OS ARQUIVOS ===" -ForegroundColor Cyan
Write-Host "Total de arquivos a processar: $totalFiles`n" -ForegroundColor Cyan

for ($i = 0; $i -lt $htmlFiles.Count; $i++) {
    $file = $htmlFiles[$i]
    $fileName = $file.FullName -replace [regex]::Escape($RootPath), ''
    
    $progress = [Math]::Round(($i / $htmlFiles.Count) * 100)
    Write-Host "[$progress%] " -NoNewline -ForegroundColor Gray
    Write-Host "$fileName" -NoNewline
    
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $modified = $false
        
        # 1. Adicionar meta description se não existir
        if ($content -notmatch '<meta\s+name="description"') {
            $titleMatch = [regex]::Match($content, '<title>([^<]+)</title>')
            if ($titleMatch.Success) {
                $title = $titleMatch.Groups[1].Value
                $description = "Atividade educativa: $($title.Substring(0, [Math]::Min(100, $title.Length)))"
                $metaDesc = "    <meta name=`"description`" content=`"$description`">"
                $content = $content -replace '(<meta name="viewport"[^>]*>)', "`$1`n$metaDesc"
                $modified = $true
            }
        }
        
        # 2. Remover H1 vazio
        if ($content -match '<h1[^>]*>\s*</h1>') {
            $content = $content -replace '<h1[^>]*>\s*</h1>\s*', ''
            $modified = $true
        }
        
        # 3. Adicionar Open Graph tags
        if ($content -notmatch '<meta\s+property="og:title"') {
            $titleMatch = [regex]::Match($content, '<title>([^<]+)</title>')
            if ($titleMatch.Success) {
                $title = $titleMatch.Groups[1].Value
                $ogTags = "    <meta property=`"og:title`" content=`"$title`">`n    <meta property=`"og:description`" content=`"Conteúdo educativo de qualidade`">`n    <meta name=`"twitter:card`" content=`"summary_large_image`">"
                $content = $content -replace '(</title>)', "`$1`n$ogTags"
                $modified = $true
            }
        }
        
        # 4. Adicionar Canonical URL
        if ($content -notmatch '<link\s+rel="canonical"') {
            $relPath = ($file.FullName -replace [regex]::Escape($RootPath), '').TrimStart('\').Replace('\', '/')
            $canonicalTag = "    <link rel=`"canonical`" href=`"https://www.atividadeadaptada.com/$relPath`">"
            $content = $content -replace '(</title>)', "`$1`n$canonicalTag"
            $modified = $true
        }
        
        # 5. Adicionar Schema.org JSON-LD se não existir
        if ($content -notmatch '<script\s+type="application/ld\+json"') {
            $titleMatch = [regex]::Match($content, '<title>([^<]+)</title>')
            if ($titleMatch.Success) {
                $title = $titleMatch.Groups[1].Value
                $jsonLd = @"

    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "EducationalActivity",
      "name": "$title",
      "description": "Conteúdo educativo de qualidade",
      "author": {
        "@type": "Organization",
        "@name": "Atividade Adaptada"
      },
      "inLanguage": "pt-BR"
    }
    </script>
"@
                $content = $content -replace '(</head>)', "$jsonLd`n</head>"
                $modified = $true
            }
        }
        
        # Salvar arquivo se foi modificado
        if ($modified) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $filesFixed++
            Write-Host " [CORRIGIDO]" -ForegroundColor Green
        } else {
            Write-Host " [OK]" -ForegroundColor Green
        }
    } catch {
        $filesFailed++
        Write-Host " [ERRO]" -ForegroundColor Red
        Write-Host "  Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== RESUMO ===" -ForegroundColor Cyan
Write-Host "Total processado: $totalFiles" -ForegroundColor Cyan
Write-Host "Corrigidos: $filesFixed" -ForegroundColor Green
Write-Host "Erros: $filesFailed" -ForegroundColor Red
Write-Host "`nProcesso concluído!" -ForegroundColor Green
