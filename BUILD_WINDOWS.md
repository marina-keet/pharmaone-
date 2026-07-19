# Packaging Windows pour PharmaOne

## Prérequis sur une machine Windows

- Flutter SDK installé et ajouté à PATH
- Visual Studio 2022 avec charge de travail "Desktop development with C++"
- Inno Setup installé et ajouté à PATH

## Build

Depuis PowerShell, exécuter :

```powershell
Set-Location C:\chemin\vers\projet
powershell -ExecutionPolicy Bypass -File .\scripts\build_windows_installer.ps1
```

## Résultat

L’exécutable sera généré dans :
- build\windows\x64\runner\Release\

L’installateur sera généré dans :
- windows\installer\dist\

## Notes

- Le script produit un package Windows en mode Release.
- Pour une distribution professionnelle, il est recommandé de signer le binaire avec un certificat Code Signing.
