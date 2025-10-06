$input_folder = Join-Path $PSScriptRoot "Arquivos"
$output_file = Join-Path $PSScriptRoot "resultado.html"

$currentDate = Get-Date
$year = $currentDate.ToString("yyyy")
$month = $currentDate.ToString("MM")

Write-Host "Caminho da pasta de entrada: $input_folder"
Write-Host "Arquivo de saída: $output_file"
Write-Host "Ano atual: $year"
Write-Host "Mês atual: $month"

if (-Not (Test-Path $input_folder)) {
    Write-Host "ERRO: A pasta de entrada não foi encontrada!" -ForegroundColor Red
    Pause
    Exit
}

function Remove-Acentos {
    param([string]$string)

    if (-not $string) { return $string }

    $string = $string -replace '(?i)n[º°]\.?', 'no'

    $string = $string -replace '[º°]', 'o'
    $string = $string -replace 'ª', 'a'

    $string = $string.Normalize([System.Text.NormalizationForm]::FormD)
    $string = [System.Text.RegularExpressions.Regex]::Replace($string, '\p{M}', '')

    return $string
}

# Processamento dos PDFs
Get-ChildItem -Path $input_folder -Filter "*.pdf" | ForEach-Object {
    $file_name = $_.Name

    # centraliza limpeza na função
    $clean_file_name = Remove-Acentos -string $file_name

    # substituições finais para URL/slug
    $clean_file_name = $clean_file_name -replace '\s+', '-'
    $clean_file_name = $clean_file_name -replace '[^a-zA-Z0-9\.\-_]', ''
    $clean_file_name = $clean_file_name -replace '-+', '-'
    $clean_file_name = $clean_file_name.Trim('-')

    $html_line = "https://www.tjrs.jus.br/static/$year/$month/$clean_file_name"

    $html_line | Out-File -FilePath $output_file -Append -Encoding UTF8

    Write-Host "Processando arquivo: $file_name -> $clean_file_name"
}

Write-Host "Arquivo HTML gerado em: $output_file" -ForegroundColor Green
Pause
