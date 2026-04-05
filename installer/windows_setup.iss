[Setup]
AppName=Free Fast VPN
AppVersion=1.0.0
AppPublisher=Free Fast VPN
DefaultDirName={autopf}\FreeFastVPN
DefaultGroupName=Free Fast VPN
OutputDir=..\build\installer
OutputBaseFilename=FreeFastVPN_Setup
Compression=lzma2/ultra64
SolidCompression=yes
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\app.exe
PrivilegesRequired=admin
WizardStyle=modern
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Free Fast VPN"; Filename: "{app}\app.exe"
Name: "{autodesktop}\Free Fast VPN"; Filename: "{app}\app.exe"; Tasks: desktopicon
Name: "{autostartup}\Free Fast VPN"; Filename: "{app}\app.exe"; Tasks: autostart

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional options:"
Name: "autostart"; Description: "Start with Windows"; GroupDescription: "Additional options:"

[Run]
Filename: "{app}\app.exe"; Description: "Launch Free Fast VPN"; Flags: nowait postinstall skipifsilent
