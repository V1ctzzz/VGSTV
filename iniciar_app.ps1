# Atualiza PATH e executa o app
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
cd "C:\Users\victo\Desktop\app radio\vgs"
flutter run

