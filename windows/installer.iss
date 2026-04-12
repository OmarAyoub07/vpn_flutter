[Setup]
AppName=Free Fast VPN
AppVersion=1.0.0
AppPublisher=omar-ayoub
DefaultDirName={autopf}\Free Fast VPN
DefaultGroupName=Free Fast VPN
OutputDir=..\build\windows\installer
OutputBaseFilename=FreeFastVPN-Setup
Compression=lzma2
SolidCompression=yes
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\FreeFastVPN.exe
WizardStyle=modern
PrivilegesRequired=admin

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Free Fast VPN"; Filename: "{app}\FreeFastVPN.exe"
Name: "{group}\Uninstall Free Fast VPN"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Free Fast VPN"; Filename: "{app}\FreeFastVPN.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\FreeFastVPN.exe"; Description: "Launch Free Fast VPN"; Flags: nowait postinstall skipifsilent shellexec
