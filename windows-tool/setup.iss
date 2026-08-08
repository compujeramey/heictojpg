; Inno Setup script for Image to JPG Converter

[Setup]
AppName=Image to JPG Converter
AppVersion=2.0
AppPublisher=ImageToJPG
DefaultDirName={autopf}\ImageToJPG
DefaultGroupName=Image to JPG Converter
OutputDir=Output
OutputBaseFilename=ImageToJPG-Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
UninstallDisplayName=Image to JPG Converter
WizardStyle=modern

[Files]
Source: "dist\image_to_jpg.exe"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
; Use SystemFileAssociations so we add to the context menu without
; overriding the user's default app for these file types.

Root: HKCR; Subkey: "SystemFileAssociations\.heic\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.heic\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\image_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.heic\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\image_to_jpg.exe"" ""%1"""

Root: HKCR; Subkey: "SystemFileAssociations\.heif\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.heif\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\image_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.heif\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\image_to_jpg.exe"" ""%1"""

Root: HKCR; Subkey: "SystemFileAssociations\.webp\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.webp\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\image_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.webp\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\image_to_jpg.exe"" ""%1"""

Root: HKCR; Subkey: "SystemFileAssociations\.png\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.png\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\image_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.png\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\image_to_jpg.exe"" ""%1"""

Root: HKCR; Subkey: "SystemFileAssociations\.pdf\shell\ConvertToJPG"; \
  ValueType: string; ValueName: ""; ValueData: "Convert to JPG"; \
  Flags: uninsdeletekey

Root: HKCR; Subkey: "SystemFileAssociations\.pdf\shell\ConvertToJPG"; \
  ValueType: string; ValueName: "Icon"; ValueData: "{app}\image_to_jpg.exe,0"

Root: HKCR; Subkey: "SystemFileAssociations\.pdf\shell\ConvertToJPG\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\image_to_jpg.exe"" ""%1"""

[Icons]
Name: "{group}\Uninstall Image to JPG Converter"; Filename: "{uninstallexe}"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.heic\shell\ConvertToJPG');
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.heif\shell\ConvertToJPG');
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.webp\shell\ConvertToJPG');
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.png\shell\ConvertToJPG');
    RegDeleteKeyIncludingSubkeys(HKCR, 'SystemFileAssociations\.pdf\shell\ConvertToJPG');
  end;
end;
