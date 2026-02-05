$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"

# Padroes a serem substituidos
$substituicoes = @(
    @{
        old = "Matemática Reta Numérica/Matemática Reta Numérica.html"
        new = "matematica-reta-numerica/matematica-reta-numerica.html"
        tipo = "Caminho HTML"
    },
    @{
        old = "Matemática Reta Numérica"
        new = "matematica-reta-numerica"
        tipo = "Nome pasta"
    },
    @{
        old = "Atividade_ Reta Numérica e Sistema Decimal_page-0001.webp"
        new = "matematica-reta-numerica.webp"
        tipo = "Arquivo webp antigo"
    },
    @{
        old = "Matem%C3%A1tica%20Reta%20Num%C3%A9rica/Matem%C3%A1tica%20Reta%20Num%C3%A9rica.html"
        new = "matematica-reta-numerica/matematica-reta-numerica.html"
        tipo = "Canonical URL encoded"
    },
    @{
        old = "Matem%C3%A1tica%20Reta%20Num%C3%A9rica"
        new = "matematica-reta-numerica"
        tipo = "Nome pasta URL encoded"
    }
)

Write-Host "Iniciando atualizacao de referencias..." -ForegroundColor Cyan

$arquivosAtualizados = 0
$totalSubstituicoes = 0

$arquivos = Get-ChildItem -Path $raiz -Filter "*.html" -Recurse -ErrorAction SilentlyContinue
Write-Host "Verificando $($arquivos.Count) arquivos HTML`n" -ForegroundColor Yellow

foreach ($arquivo in $arquivos) {
    # Pular o arquivo que foi renomeado
    if ($arquivo.FullName -match "\\matematica-reta-numerica\\") {
        continue
    }

    $conteudo = Get-Content -Path $arquivo.FullName -Encoding UTF8 -Raw -ErrorAction SilentlyContinue
    $conteudoOriginal = $conteudo

    foreach ($sub in $substituicoes) {
        if ($conteudo -match [regex]::Escape($sub.old)) {
            $conteudo = $conteudo -replace [regex]::Escape($sub.old), $sub.new
            Write-Host "  - $($sub.tipo): '$($sub.old)' -> '$($sub.new)'"
            $totalSubstituicoes++
        }
    }

    if ($conteudo -ne $conteudoOriginal) {
        Set-Content -Path $arquivo.FullName -Value $conteudo -Encoding UTF8
        $arquivosAtualizados++
        Write-Host "Atualizado: $($arquivo.Name)`n" -ForegroundColor Green
    }
}

# Tambem atualizar arquivos JSON
$arquivosJson = Get-ChildItem -Path $raiz -Filter "*.json" -Recurse -ErrorAction SilentlyContinue
Write-Host "Verificando $($arquivosJson.Count) arquivos JSON`n" -ForegroundColor Yellow

foreach ($arquivo in $arquivosJson) {
    $conteudo = Get-Content -Path $arquivo.FullName -Encoding UTF8 -Raw -ErrorAction SilentlyContinue
    $conteudoOriginal = $conteudo

    foreach ($sub in $substituicoes) {
        if ($conteudo -match [regex]::Escape($sub.old)) {
            $conteudo = $conteudo -replace [regex]::Escape($sub.old), $sub.new
            Write-Host "  - $($sub.tipo): '$($sub.old)' -> '$($sub.new)'"
            $totalSubstituicoes++
        }
    }

    if ($conteudo -ne $conteudoOriginal) {
        Set-Content -Path $arquivo.FullName -Value $conteudo -Encoding UTF8
        $arquivosAtualizados++
        Write-Host "Atualizado: $($arquivo.Name)`n" -ForegroundColor Green
    }
}

Write-Host "`n========== RESUMO ==========" -ForegroundColor Cyan
Write-Host "Arquivos atualizados: $arquivosAtualizados" -ForegroundColor Green
Write-Host "Total de substituicoes: $totalSubstituicoes" -ForegroundColor Green
Write-Host "Processo concluido!" -ForegroundColor Cyan
