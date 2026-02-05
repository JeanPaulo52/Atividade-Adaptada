$raiz = "c:\Users\jean\Desktop\Atividade Adaptada.com"
$renomeados = 0

Write-Host "Iniciando limpeza..." -ForegroundColor Cyan

$pastas = Get-ChildItem -Path $raiz -Recurse -Directory | Where-Object { $_.Name -match "[áéíóúãõçâêô]" } | Sort-Object -Property FullName -Descending

foreach ($pasta in $pastas) {
    $antigo = $pasta.Name
    $novo = $antigo
    $novo = $novo -replace "á", "a"
    $novo = $novo -replace "é", "e"
    $novo = $novo -replace "í", "i"
    $novo = $novo -replace "ó", "o"
    $novo = $novo -replace "ú", "u"
    $novo = $novo -replace "ã", "a"
    $novo = $novo -replace "õ", "o"
    $novo = $novo -replace "ç", "c"
    $novo = $novo -replace "â", "a"
    $novo = $novo -replace "ê", "e"
    $novo = $novo -replace "ô", "o"
    
    if ($novo -ne $antigo) {
        $cmd = "cd /d `"" + (Split-Path $pasta.FullName) + "`" && ren `"$antigo`" `"$novo`""
        cmd /c $cmd 2>$null
        Write-Host "OK: $antigo -> $novo" -ForegroundColor Green
        $renomeados++
    }
}

Write-Host "Total: $renomeados pastas renomeadas" -ForegroundColor Cyan
