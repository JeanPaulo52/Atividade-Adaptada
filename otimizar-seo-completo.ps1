# Script avançado para corrigir SEO de todas as páginas HTML com dados específicos
# Extrai informações reais de cada página e aplica correções personalizadas

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$htmlFiles = @(Get-ChildItem -Path $RootPath -Recurse -Filter "*.html")

$totalFiles = $htmlFiles.Count
$filesFixed = 0
$filesFailed = 0

Write-Host "`n=== CORRIGINDO SEO ESPECIFICO DE CADA PAGINA ===" -ForegroundColor Cyan
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
        
        # 1. Extrair título real da página
        $h1Match = [regex]::Match($content, '<h1[^>]*id="activity-title"[^>]*>([^<]+)</h1>')
        if (-not $h1Match.Success) {
            $h1Match = [regex]::Match($content, '<h1[^>]*>([^<]+)</h1>')
        }
        if (-not $h1Match.Success) {
            $h1Match = [regex]::Match($content, '<h2[^>]*>([^<]*(?:Atividades?|Categories|Artigos)[^<]*)</h2>')
        }
        
        $pageTitle = if ($h1Match.Success) { $h1Match.Groups[1].Value.Trim() } else { "Atividade Educativa" }
        
        # 2. Extrair descrição real da página
        $descMatch = [regex]::Match($content, '<p[^>]*class="text-lg text-gray-600[^>]*>([^<]+)</p>')
        if (-not $descMatch.Success) {
            $descMatch = [regex]::Match($content, '<p[^>]*>([^<]{50,200})</p>')
        }
        
        $pageDesc = if ($descMatch.Success) { 
            $desc = $descMatch.Groups[1].Value.Trim()
            $desc.Substring(0, [Math]::Min(150, $desc.Length))
        } else { 
            "Conteúdo educativo de qualidade - Atividade Adaptada" 
        }
        
        # 3. Corrigir meta description com título e descrição específicos
        if ($content -match '<meta\s+name="description"\s+content="([^"]*)"') {
            $oldDesc = $matches[1]
            if ($oldDesc -match "Atividade educativa:|Conteúdo educativo" -or $oldDesc.Length -lt 50) {
                $newDesc = "$pageTitle - $pageDesc"
                $content = $content -replace [regex]::Escape("<meta name=`"description`" content=`"$oldDesc`">"), "<meta name=`"description`" content=`"$newDesc`">"
                $modified = $true
            }
        }
        
        # 4. Corrigir title tag com informação específica
        $titleMatch = [regex]::Match($content, '<title>([^<]*)</title>')
        if ($titleMatch.Success) {
            $oldTitle = $titleMatch.Groups[1].Value
            if ($oldTitle -eq "Atividade Adaptada.com" -or $oldTitle.Length -lt 30) {
                $newTitle = "$pageTitle - Atividade Adaptada"
                $content = $content -replace [regex]::Escape("<title>$oldTitle</title>"), "<title>$newTitle</title>"
                
                # Também corrigir og:title
                $content = $content -replace 'property="og:title"\s+content="[^"]*"', "property=`"og:title`" content=`"$newTitle`""
                
                # Corrigir og:description
                $content = $content -replace 'property="og:description"\s+content="[^"]*"', "property=`"og:description`" content=`"$pageDesc`""
                
                $modified = $true
            }
        }
        
        # 5. Corrigir Schema JSON-LD com dados específicos
        if ($content -match '<script\s+type="application/ld\+json">(.*?)</script>') {
            $oldJsonLd = $matches[0]
            
            # Verificar se é genérico
            if ($oldJsonLd -match '"name":\s*"Atividade Adaptada\.com"' -or $oldJsonLd -match '"description":\s*"Conteúdo educativo') {
                $newJsonLd = @"
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "EducationalActivity",
      "name": "$pageTitle",
      "description": "$pageDesc",
      "author": {
        "@type": "Organization",
        "name": "Atividade Adaptada"
      },
      "inLanguage": "pt-BR"
    }
    </script>
"@
                $content = $content -replace [regex]::Escape($oldJsonLd), $newJsonLd
                $modified = $true
            }
        }
        
        # 6. Corrigir alt text genérico em imagens
        $content = $content -replace 'alt="Planta baixa de um imóvel para cálculo de área"', "alt=`"$pageTitle - Atividade Educativa`""
        if ($content -ne $content) {
            $modified = $true
        }
        
        # 7. Remover Google AdSense duplicado no sidebar
        $adSenseCount = ([regex]::Matches($content, 'pagead2\.googlesyndication\.com/pagead/js/adsbygoogle\.js')).Count
        if ($adSenseCount -gt 1) {
            # Remover script duplicado no sidebar mantendo apenas no head
            $content = $content -replace '(?<=<div[^>]*class="bg-gray-100[^>]*>)\s*<script[^>]*src="[^"]*pagead2\.googlesyndication\.com[^>]*>\s*</script>\s*', ''
            $modified = $true
        }
        
        # Salvar arquivo se foi modificado
        if ($modified) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $filesFixed++
            Write-Host " [OTIMIZADO]" -ForegroundColor Green
        } else {
            Write-Host " [OK]" -ForegroundColor Green
        }
    } catch {
        $filesFailed++
        Write-Host " [ERRO]" -ForegroundColor Red
    }
}

Write-Host "`n=== RESUMO ===" -ForegroundColor Cyan
Write-Host "Total processado: $totalFiles" -ForegroundColor Cyan
Write-Host "Otimizados: $filesFixed" -ForegroundColor Green
Write-Host "Erros: $filesFailed" -ForegroundColor Red
Write-Host "`nProcesso concluído!" -ForegroundColor Green
