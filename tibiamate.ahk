#NoEnv
#SingleInstance force
#MaxHotkeysPerInterval 500

FileEncoding , UTF-8
SendMode Input
SetTitleMatchMode, 3
macroVersion := 1
downloadURL = https://tibiamate.herokuapp.com/app

If (A_AhkVersion <= "1.1.23")
{
	msgbox, You need AutoHotkey v1.1.23 or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.
	ExitApp
}

IfNotExist %A_MyDocuments%\AutoHotKey
{
	FileCreateDir, %A_MyDocuments%\AutoHotKey
}

IfNotExist %A_MyDocuments%\AutoHotKey\TibiaMate
{
	FileCreateDir, %A_MyDocuments%\AutoHotKey\TibiaMate
}

SetWorkingDir %A_MyDocuments%\AutoHotKey

SetWorkingDir %A_MyDocuments%\AutoHotKey\TibiaMate

IfNotExist, changelog.txt
{
	UrlDownloadToFile, %downloadURL%/changelog.txt, changelog.txt
}
IfNotExist, main.ahk
{
	UrlDownloadToFile, %downloadURL%/main.ahk, main.ahk
}
IfNotExist, verify.ahk
{
	UrlDownloadToFile, %downloadURL%/verify.ahk, verify.ahk
}

RunWait, verify.ahk

IniWrite, %A_ScriptFullPath%, settings.ini, variables, LauncherPath

Run main.ahk
ExitApp

msgbox Something went wrong.