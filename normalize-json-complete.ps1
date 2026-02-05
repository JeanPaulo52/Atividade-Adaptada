# Script para normalizar completamente os caminhos nos JSONs
$jsonDir = "c:\Users\jean\Desktop\Atividade Adaptada.com\js"
$counter = 0

# Mapa de substituições de pastas com espaços e maiúsculas
$replacements = @(
    # Converter para minúsculas primeiro - pastas com maiúsculas
    @{old = "/2-BNCC/"; new = "/2-bncc/"},
    @{old = "/Artes/"; new = "/artes/"},
    @{old = "/Biologia/"; new = "/biologia/"},
    @{old = "/Ciencias/"; new = "/ciencias/"},
    @{old = "/Educacao Fisica/"; new = "/educacao-fisica/"},
    @{old = "/Educacao_financeira/"; new = "/educacao-financeira/"},
    @{old = "/Filosofia/"; new = "/filosofia/"},
    @{old = "/Fisica/"; new = "/fisica/"},
    @{old = "/Geografia/"; new = "/geografia/"},
    @{old = "/Historia/"; new = "/historia/"},
    @{old = "/Ingles/"; new = "/ingles/"},
    @{old = "/Lingua Portuguesa/"; new = "/lingua-portuguesa/"},
    @{old = "/Matematica/"; new = "/matematica/"},
    @{old = "/Quimica/"; new = "/quimica/"},
    @{old = "/Sociologia/"; new = "/sociologia/"},
    @{old = "/PagDow/"; new = "/pagdow/"},
    @{old = "/Raciocinio/"; new = "/raciocinio/"},
    @{old = "/Infantil/"; new = "/infantil/"},
    @{old = "/Pintura/"; new = "/pintura/"},
    
    # Pastas com espaços - exemplos que encontramos
    @{old = "/A Minha Bolha de Danca/"; new = "/a-minha-bolha-de-danca/"},
    @{old = "/Criando com Dancas do Brasil/"; new = "/criando-com-dancas-do-brasil/"},
    @{old = "/Descobrindo o Carimbó/"; new = "/descobrindo-o-carimbó/"},
    @{old = "/Descobrindo o Jongo/"; new = "/descobrindo-o-jongo/"},
    @{old = "/Descobrindo o Siriri/"; new = "/descobrindo-o-siriri/"},
    
    # Arquivos com espaços
    @{old = "Atividade_ A Minha Bolha de Danca"; new = "atividade-a-minha-bolha-de-danca"},
    @{old = "A Minha Bolha de Danca.html"; new = "a-minha-bolha-de-danca.html"},
    @{old = "A Minha Bolha de Danca.webp"; new = "a-minha-bolha-de-danca.webp"},
)

Get-ChildItem -Path $jsonDir -Filter "*.json" | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    $original = $content
    
    # Aplicar todas as substituições
    foreach ($replacement in $replacements) {
        $content = $content.Replace($replacement.old, $replacement.new)
    }
    
    # Se houve mudanças, salvar
    if ($content -ne $original) {
        Set-Content -Path $file -Value $content -Encoding UTF8
        Write-Host "OK: $($_.Name)"
        $counter++
    }
}

Write-Host "Total de JSONs normalizados: $counter"
