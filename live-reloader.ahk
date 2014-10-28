

#Include %A_ScriptDir%\ahk_modules\JSON.ahk
uo := {} ;short for userObject

file := FileOpen(%A_ScriptDir%\userconfig.txt, r
if (file = 0) {
	InputBox, pathToLive, File path of LIve, Please enter the file path to the Live.exe file on your computer (you only have to do this once)
	file := FileOpen(%A_ScriptDir%\userconfig.txt, a
	uo.pathToLive := pathToLive
}

Gui, New, , Live-Reloader
Gui, Add, DropDownList, vColorChoice, Black|White|Red|Green|Blue

FileRead, userConfigJSON, %A_ScriptDir%\userconfig.txt

userConfigJSONParsed := Json2(userConfigJSON)

global pathToLive := ""


^!+9::
{
	
}