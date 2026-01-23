# Script para corrigir Schema JSON-LD genérico em todas as páginas do site

$RootPath = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$htmlFiles = @(Get-ChildItem -Path $RootPath -Recurse -Filter "*.html")

$totalFiles = $htmlFiles.Count
$filesFixed = 0
$filesFailed = 0

Write-Host "`n=== CORRIGINDO SCHEMA JSON-LD GENERICO ===" -ForegroundColor Cyan
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
        
        # Verificar se tem Schema JSON-LD genérico
        if ($content -match '<script\s+type="application/ld\+json">(.*?)</script>' -and 
            $content -match '"name":\s*"Atividade Adaptada\.com"' -and
            $content -match '"description":\s*"Conte[úu]do educativo de qualidade"') {
            
            # Extrair título real da página
            $h1Match = [regex]::Match($content, '<h1[^>]*id="activity-title"[^>]*>([^<]+)</h1>')
            if (-not $h1Match.Success) {
                $h1Match = [regex]::Match($content, '<h1[^>]*>([^<]+)</h1>')
            }
            
            $pageTitle = if ($h1Match.Success) { $h1Match.Groups[1].Value.Trim() } else { "Atividade Educativa" }
            
            # Extrair descrição da página
            $descMatch = [regex]::Match($content, '<p[^>]*class="text-lg text-gray-600[^>]*>([^<]+)</p>')
            if (-not $descMatch.Success) {
                $descMatch = [regex]::Match($content, '<p[^>]*>([^<]{50,250})</p>')
            }
            
            $pageDesc = if ($descMatch.Success) { 
                $desc = $descMatch.Groups[1].Value.Trim()
                $desc = $desc -replace '&quot;', '"' -replace '&mdash;', '—' -replace '&[a-z]+;', ''
                $desc.Substring(0, [Math]::Min(160, $desc.Length))
            } else { 
                "Atividade educativa de qualidade" 
            }
            
            # Extrair faixa etária se existir
            $ageMatch = [regex]::Match($content, 'Idade Recomendada[^:]*:\s*(\d+)\s*a\s*(\d+)')
            $minAge = if ($ageMatch.Success) { [int]$ageMatch.Groups[1].Value } else { 7 }
            $maxAge = if ($ageMatch.Success) { [int]$ageMatch.Groups[2].Value } else { 14 }
            
            # Encontrar o Schema JSON-LD antigo
            $oldJsonLd = [regex]::Match($content, '<script\s+type="application/ld\+json">(.*?)</script>', [System.Text.RegularExpressions.RegexOptions]::Singleline).Value
            
            # Criar novo Schema JSON-LD com dados específicos
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
