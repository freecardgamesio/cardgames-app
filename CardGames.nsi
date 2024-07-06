!include "MUI2.nsh"

; CardGames.nsi
;
;--------------------------------


!define MUI_ICON ".\src\branding_cardgames\cardgames.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\src\branding_cardgames\header.bmp"
#!define MUI_HEADERIMAGE_RIGHT

; The name of the installer
Name "CardGames"

; The file to write
OutFile "CardGamesInstaller.exe"

; The default installation directory
InstallDir $PROGRAMFILES\CardGames

; Registry key to check for directory (so if you install again, it will overwrite the old one automatically)
InstallDirRegKey HKLM "Software\CardGames" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Functions

Function RunCardGames
SetOutPath $INSTDIR
Exec "$INSTDIR\cardgames.exe"
FunctionEnd

; Pages

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_CHECKED
!define MUI_FINISHPAGE_RUN_FUNCTION RunCardGames
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

;--------------------------------

; The stuff to install

Section "CardGames (required)"

  SetShellVarContext all

  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "build\RelWithDebInfo_Out\cardgames.exe"
  File "build\RelWithDebInfo_Out\cardgames_service.exe"
  File "build\RelWithDebInfo_Out\cardgames_Uninstaller.exe"
  File "build\RelWithDebInfo_Out\dumpgen.exe"
  File "build\RelWithDebInfo_Out\java_launcher.exe"
  File "build\RelWithDebInfo_Out\mcf_util.exe"
  File "build\RelWithDebInfo_Out\toolhelper.exe"
  File "build\RelWithDebInfo_Out\utility.exe"
  File /r "build\RelWithDebInfo_Out\bin"
  File /r "build\RelWithDebInfo_Out\data"
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\CardGames "Install_Dir" "$INSTDIR"
  
  ; Registry key to force proxy off (helpful for some users)
  WriteRegDWORD HKLM "Software\CardGames\CardGamesApp" "PrivateProxyOff" 1

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CardGames" "DisplayName" "CardGames"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CardGames" "UninstallString" '"$INSTDIR\CardGames_Uninstaller.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CardGames" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CardGames" "NoRepair" 1
  WriteUninstaller "CardGames_Uninstaller.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  SetShellVarContext all

  CreateDirectory "$SMPROGRAMS\CardGames"
  CreateShortcut "$SMPROGRAMS\CardGames\Uninstall.lnk" "$INSTDIR\CardGames_Uninstaller.exe" "" "$INSTDIR\CardGames_Uninstaller.exe" 0
  CreateShortcut "$SMPROGRAMS\CardGames\CardGames.lnk" "$INSTDIR\CardGames.exe" "" "$INSTDIR\CardGames.exe" 0
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  SetShellVarContext all
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CardGames"
  DeleteRegKey HKLM SOFTWARE\CardGames

  ; Remove files and uninstaller
  Delete $INSTDIR\*.*

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\CardGames\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\CardGames"
  RMDir "$INSTDIR"

SectionEnd
