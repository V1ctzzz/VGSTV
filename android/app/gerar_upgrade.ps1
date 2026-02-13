# Script para gerar o arquivo de upgrade da chave usando PEPK
# Execute este script manualmente no PowerShell

$ErrorActionPreference = "Stop"

Write-Host "=== Gerando arquivo de upgrade da chave ===" -ForegroundColor Green
Write-Host ""

$keystorePath = "upload-keystore.jks"
$alias = "upload"
$output = "upload-key-encrypted.zip"
$encryptionKey = "encryption_public_key.pem"
$signingKeystore = "upload-keystore.jks"
$signingAlias = "upload"

Write-Host "Verificando arquivos..." -ForegroundColor Yellow
if (-not (Test-Path $keystorePath)) { Write-Host "ERRO: $keystorePath não encontrado!" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $encryptionKey)) { Write-Host "ERRO: $encryptionKey não encontrado!" -ForegroundColor Red; exit 1 }
if (-not (Test-Path "pepk.jar")) { Write-Host "ERRO: pepk.jar não encontrado!" -ForegroundColor Red; exit 1 }

Write-Host "✓ Todos os arquivos encontrados" -ForegroundColor Green
Write-Host ""
Write-Host "Executando PEPK..." -ForegroundColor Yellow
Write-Host "Quando solicitado, digite: glenn123" -ForegroundColor Cyan
Write-Host ""

# Tentar executar o PEPK
# Nota: O PEPK requer entrada interativa, então você precisará digitar as senhas manualmente
java -jar pepk.jar `
    --keystore=$keystorePath `
    --alias=$alias `
    --output=$output `
    --signing-keystore=$signingKeystore `
    --signing-key-alias=$signingAlias `
    --rsa-aes-encryption `
    --encryption-key-path=$encryptionKey

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Arquivo gerado com sucesso: $output" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "✗ Erro ao gerar o arquivo" -ForegroundColor Red
    Write-Host "Execute o comando manualmente no terminal interativo" -ForegroundColor Yellow
}

