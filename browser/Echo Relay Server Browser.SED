[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=C:\Users\jinda\Desktop\Echo Relay Server Browser Client\browser\Echo Relay Server Browser.exe
FriendlyName=Echo Relay Server Browser
AppLaunched=powershell -windowstyle hidden -nologo -noprofile -executionpolicy bypass .\serverBrowser.ps1
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="serverBrowser.ps1"
[SourceFiles]
SourceFiles0=C:\Users\jinda\Desktop\Echo Relay Server Browser Client\browser\
[SourceFiles0]
%FILE0%=
