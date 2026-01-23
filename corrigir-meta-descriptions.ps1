# Script para corrigir meta descriptions truncadas e Schema JSON-LD genérico em todas as páginas

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$htmlFiles = @(Get-ChildItem -Path $RootPath -Recurse -Filter "*.html")

$totalFiles = $htmlFiles.Count
$filesFixed = 0
$filesFailed = 0

Write-Host "`n=== CORRIGINDO META DESCRIPTIONS E SCHEMA JSON-LD ===" -ForegroundColor Cyan
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
        
        $pageTitle = if ($h1Match.Success) { $h1Match.Groups[1].Value.Trim() } else { "Atividade Educativa" }
        
        # 2. Extrair descrição completa da página
        $descMatch = [regex]::Match($content, '<p[^>]*class="text-lg text-gray-600[^>]*>([^<]+)</p>')
        if (-not $descMatch.Success) {
            $descMatch = [regex]::Match($content, '<p[^>]*>([^<]{50,250})</p>')
        }
        
        $pageDesc = if ($descMatch.Success) { 
            $desc = $descMatch.Groups[1].Value.Trim()
            # Limpar a descrição
            $desc = $desc -replace '&quot;', '"' -replace '&mdash;', '—' -replace '&[a-z]+;', ''
            $desc.Substring(0, [Math]::Min(160, $desc.Length))
        } else { 
            "Conteúdo educativo de qualidade - Atividade Adaptada" 
        }
        
        # 3. Verificar e corrigir meta description truncada
        $metaDescMatch = [regex]::Match($content, '<meta\s+name="description"\s+content="([^"]+)"')
        if ($metaDescMatch.Success) {
            $currentDesc = $metaDescMatch.Groups[1].Value
            # Detectar se está truncada (termina com — ou com 3 pontos ou está muito curta)
            if ($currentDesc -match '—\s*$' -or $currentDesc -match '\.\.\.\s*$' -or $currentDesc.Length -lt 100) {
                $newDesc = "$pageTitle - $pageDesc"
                $content = $content -replace [regex]::Escape("<meta name=`"description`" content=`"$currentDesc`">"), "<meta name=`"description`" content=`"$newDesc`">"
                $modified = $true
            }
        }
        
        # 4. Verificar e corrigir Schema JSON-LD genérico
        if ($content -match '<script\s+type="application/ld\+json">(.*?)</script>' -and 
            $content -match '"name":\s*"Atividade Adaptada\.com"') {
            
            $oldJsonLd = $matches[0]
            
            # Extrair faixa etária se existir na página
            $ageMatch = [regex]::Match($content, 'Idade Recomendada[^:]*:\s*(\d+)\s*a\s*(\d+)')
            $minAge = if ($ageMatch.Success) { [int]$ageMatch.Groups[1].Value } else { 7 }
            $maxAge = if ($ageMatch.Success) { [int]$ageMatch.Groups[2].Value } else { 14 }
            
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
      "inLanguage": "pt-BR",
      "educationalLevel": "Elementary/Primary",
      "audience": {
        "@type": "EducationalAudience",
        "educationalRole": "student",
        "suggestedMinAge": $minAge,
        "suggestedMaxAge": $maxAge
      }
    }
    </script>
"@
            
            $content = $content -replace [regex]::Escape($oldJsonLd), $newJsonLd
            $modified = $true
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
    }
}

Write-Host "`n=== RESUMO ===" -ForegroundColor Cyan
Write-Host "Total processado: $totalFiles" -ForegroundColor Cyan
Write-Host "Corrigidos: $filesFixed" -ForegroundColor Green
Write-Host "Erros: $filesFailed" -ForegroundColor Red
Write-Host "`nProcesso concluído!" -ForegroundColor Green
