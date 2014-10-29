

#Include %A_ScriptDir%\ahk_modules\Json2.ahk
global uo := {} ;short for userObject

; check that userconfig file exists
file := FileOpen("userconfig.txt", "r")
if (file = 0) {
	file.Close()
	; InputBox, pathToLive, File path of LIve, Please enter the file path to the Live.exe file on your computer (you only have to do this once)
	file := FileOpen("userconfig.txt", "w")
	if !IsObject(file)
		{
			MsgBox Can't open "%FileName%" for writing.
			return
		}
	file.Close()
}

; read userconfig and initialize if empty
FileRead, userConfigText, %A_ScriptDir%\userconfig.txt
if (userConfigText = ""){
	uo.scriptPaths := {}
	uo.scriptPaths1 := {none: "--none--", path1: "C:\ProgramData\Ableton\Live 9 Suite\Resources\MIDI Remote Scripts", path2: " ", path3: " ", path4: " ", path5: " "}
	uo.scriptPaths2 := {none: "--none--", path1: "--none--", path2: "C:\ProgramData\Ableton\Live 9 Suite\Resources\MIDI Remote Scripts", path3: " ", path4: " ", path5: " "}
	uo.livePath := "C:\ProgramData\Ableton\Live 9 Suite\Program\Ableton Live 9 Suite.exe"
	uo.loadLiveHotkey := "^!9"
	uo.closeLiveHotkey := "^!;"
	uo.reloadGuiHotkey := "^!8"
	
	file := FileOpen("userconfig.txt", "w")
	if !IsObject(file)
	{
		MsgBox Can't open "%FileName%" for writing.
		return
	}
	uoSerialized := _Json2(uo)
	file.WriteLine(uoSerialized)
	file.Close()
	FileRead, userConfigText, %A_ScriptDir%\userconfig.txt
}

uo := Json2(userConfigText)
path1 := uo.scriptPaths1.path1
path2 := uo.scriptPaths1.path2
path3 := uo.scriptPaths1.path3
path4 := uo.scriptPaths1.path4
path5 := uo.scriptPaths1.path5
path1_2 := uo.scriptPaths2.path1
path2_2 := uo.scriptPaths2.path2
path3_2 := uo.scriptPaths2.path3
path4_2 := uo.scriptPaths2.path4
path5_2 := uo.scriptPaths2.path5
none := uo.scriptPaths1.none
none_2 := uo.scriptPaths2.none
livePath := uo.livePath
loadLiveHotkey := uo.loadLiveHotkey
closeLiveHotkey := uo.closeLiveHotkey
reloadGuiHotkey := uo.reloadGuiHotkey



guiStart:
Gui, New, , Live-Reloader
Gui, Add, Text,, Path of control script directory to clean:
Gui, Add, ComboBox, w400 vscriptPath, %path1%||%path2%|%path3%|%path4%|%path5%|%none%,
Gui, Add, Text,, Path of second control script directory to clean (optional):
Gui, Add, ComboBox, w400 vscriptPath2, %path1_2%||%path2_2%|%path3_2%|%path4_2%|%path5_2%|%none_2%
Gui, Add, Text,, Path to live.exe:
Gui, Add, Edit, vlivePath, %livePath%
Gui, Add, Button, default section w75 xp+160 yp+35, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.

Gui, Show,, Live-Reloader
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
ExitApp
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.
; update uo object and write it to userconfig, and update variable hotkeys

Hotkey,%loadLiveHotkey%,loadLive
Hotkey,%closeLiveHotkey%,closeLive
Hotkey,%reloadGuiHotkey%,guiStart

uo.livePath := livePath
if (uo.scriptPaths1.path1 != scriptPath){
	uo.scriptPaths1.path2 := path1
	uo.scriptPaths1.path3 := path2
	uo.scriptPaths1.path4 := path3
	uo.scriptPaths1.path5 := path4
	uo.scriptPaths1.path1 := scriptPath
}
if (uo.scriptPaths2.path1 != scriptPath2){
	uo.scriptPaths2.path2 := path1_2
	uo.scriptPaths2.path3 := path2_2
	uo.scriptPaths2.path4 := path3_2
	uo.scriptPaths2.path5 := path4_2
	uo.scriptPaths2.path1 := scriptPath2
}
file := FileOpen("userconfig.txt", "w")
if !IsObject(file)
{
	MsgBox Can't open "%FileName%" for writing.
	return
}
uoSerialized := _Json2(uo)
file.WriteLine(uoSerialized)
file.Close()
return


; HOTKEYS
loadLive:
{
SetTitleMatchMode, 2
IfWinNotExist, Ableton Live 9 Suite
{
	Run, %livePath%
}
else
{
	WinClose, Ableton Live 9 Suite
	closedCounter := 0
	SetTimer, checkIsClosed, 250
	checkIsClosed:
		IfWinNotExist, Ableton Live 9 Suite
		{	
			setTimer, checkIsClosed, Off
			Run, %livePath%
			return
		}
		closedCounter++
		if (closedCounter = 100)
		{
			MsgBox Could not close Live before timeout`n`nAborting reload
			return
		}
}
return
}

closeLive:
{
	SetTitleMatchMode, 2
	WinClose, Ableton Live 9 Suite
	return
}
