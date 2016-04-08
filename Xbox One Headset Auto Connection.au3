#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Written By: Amin Babaeipanah
;Modified By: BetaLeaf
$winTitle = "Xbox One Headset Auto Connection"
$WorkingDirectory = @TempDir & "\BetaLeaf Software\" & $winTitle
DirCreate(@TempDir & "\BetaLeaf Software\" & $winTitle)
FileInstall("nircmdc.exe", @TempDir & "\BetaLeaf Software\" & $winTitle & "\nircmdc.exe", 1)
Setup()
While 1
	If GetDevices("") = 1 Then
		For $i = 0 To 2
			ShellExecute($WorkingDirectory & "\NIRCMDC.exe", 'setdefaultsounddevice "Headphones" ' & $i & '"', @ScriptDir, "", @SW_HIDE) ;Set Default Playback Device to Slot $Slot.
		Next
		For $i = 0 To 2
			ShellExecute($WorkingDirectory & "\NIRCMDC.exe", 'setdefaultsounddevice "Headset Microphone" ' & $i & '"', @ScriptDir, "", @SW_HIDE) ;Set Default Recording Device to Slot $Slot.
		Next
		Do
			Sleep(5000)
		Until GetDevices("") = 2
	EndIf
	Sleep(1000)
WEnd
Func GetDevices($name)
	Local $objWMIService = ObjGet('winmgmts:\\localhost\root\CIMV2')
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_PnPEntity WHERE Name LIKE '%" & $name & "%'", "WQL", 48)
	If IsObj($colItems) Then
		For $objItem In $colItems
			Select
				Case StringInStr($objItem.PNPDeviceID, "USB\VID_045E&PID_02E4&IGA_00") <> 0
					Return 1
			EndSelect
		Next
	EndIf
	Return 2
EndFunc   ;==>GetDevices
Func Setup()
	Local $StartwithWindows = RegRead("HKCU\Software\BetaLeaf Software\Xbox One Headset Auto Connection", "StartwithWindows")
	If @error Then
		Local $ret = MsgBox(64 + 4, $winTitle, "Would you like this program to Start with Windows?")
		If $ret = 6 Then
			If RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", $winTitle, "REG_SZ", '"' & @ScriptFullPath & '"') = 0 Then MsgBox(0, $winTitle, "Could not write to registry. Error: " & @error)
			If RegWrite("HKCU\Software\BetaLeaf Software\Xbox One Headset Auto Connection", "StartwithWindows", "REG_DWORD", "1") = 0 Then MsgBox(16, $winTitle, "Could not write to registry. Error: " & @error)
		ElseIf $ret = 7 Then
			If RegDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", $winTitle) = 2 Then MsgBox(0, $winTitle, "Could not delete registry key. Error: " & @error)
			If RegWrite("HKCU\Software\BetaLeaf Software\Xbox One Headset Auto Connection", "StartwithWindows", "REG_DWORD", "0") = 0 Then MsgBox(16, $winTitle, "Could not write to registry. Error: " & @error)
		EndIf
	Else
		Local $Run = RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", $winTitle)
		Select
			Case @error = -1
				If RegDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", $winTitle) = 2 Then MsgBox(0, $winTitle, "Could not delete registry key. Error: " & @error)
				If RegWrite("HKCU\Software\BetaLeaf Software\Xbox One Headset Auto Connection", "StartwithWindows", "REG_DWORD", "0") = 0 Then MsgBox(16, $winTitle, "Could not write to registry. Error: " & @error)
			Case $Run <> ""
				If RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", $winTitle, "REG_SZ", '"' & @ScriptFullPath & '"') = 0 Then MsgBox(0, $winTitle, "Could not write to registry. Error: " & @error)
				If RegWrite("HKCU\Software\BetaLeaf Software\Xbox One Headset Auto Connection", "StartwithWindows", "REG_DWORD", "1") = 0 Then MsgBox(16, $winTitle, "Could not write to registry. Error: " & @error)
			Case Else
				MsgBox(16, $winTitle, "Could not read registry. Error: " & @error)
		EndSelect
	EndIf
EndFunc   ;==>Setup
