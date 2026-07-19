#define MyAppName "PharmaOne"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "PharmaOne"
#define MyAppExeName "pharma_one.exe"
#define MySourceDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{A6A7BD4F-0D67-4B78-A876-26EE5B0FB1E7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=dist
OutputBaseFilename=PharmaOne-Setup
Compression=lzma2
SolidCompression=yes
DisableProgramGroupPage=no
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
