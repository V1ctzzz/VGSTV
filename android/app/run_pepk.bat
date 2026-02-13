@echo off
cd /d "%~dp0"
echo glenn123| java -jar pepk.jar --keystore=upload-keystore.jks --alias=upload --output=upload-key-encrypted.zip --signing-keystore=upload-keystore.jks --signing-key-alias=upload --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem
pause

