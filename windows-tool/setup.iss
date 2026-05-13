; Inno Setup script for HEIC to JPG Converter

[Setup]
AppName=HEIC to JPG Converter
AppVersion=1.0
AppPublisher=HEICtoJPG
DefaultDirName={autopf}\HEICtoJPG
DefaultGroupName=HEIC to JPG Converter
OutputDir=Output
OutputBaseFilename=HEICtoJPG-Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
UninstallDisplayName=HEIC to JPG Converter
WizardStyle=modern

[Files]
Source: "dist\heic_to_jpg.exe"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
; Use SystemFileAssociations so we add to the context menu without
; overriding the user's default app for .heic / .heif files.

Root: HKCR; Subkey: "SystemFileAssociations\.heic\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.heic\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\heic_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.heic\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\heic_to_jpg.exe"" ""%1"""

Root: HKCR; Subkey: "SystemFileAssociations\.heif\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.heif\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\heic_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.heif\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\heic_to_jpg.exe"" ""%1"""

[Icons]
Name: "{group}\Uninstall HEIC to JPG Converter"; Filename: "{uninstallexe}"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.heic\shell\ConvertToJPG');
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.heif\shell\ConvertToJPG');
  end;
end;
