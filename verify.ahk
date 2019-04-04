#NoTrayIcon
#NoEnv
#SingleInstance force
FileEncoding , UTF-8
SetWorkingDir %A_ScriptDir%

IfNotExist, settings.ini
{
	defaultIni := "[variables]`n"
	defaultIni .= "XOffset=0`n"
	defaultIni .= "YOffset=0`n"
	defaultIni .= "WAXoffset=0`n"
	defaultIni .= "WAYoffset=0`n"
	defaultIni .= "ColorBG=11213a`n"
	defaultIni .= "ColorText=fcff00`n"
	defaultIni .= "OverlayToggle=0`n"
	defaultIni .= "Duration1=1000`n"
	defaultIni .= "Duration2=2000`n"
	defaultIni .= "Duration3=3000`n"
	defaultIni .= "Duration4=4000`n"
	defaultIni .= "Duration5=5000`n"
	defaultIni .= "Duration6=6000`n"
	defaultIni .= "Duration7=7000`n"
	defaultIni .= "CooldownColor1=ffff00`n"
	defaultIni .= "CooldownColor2=ff0000`n"
	defaultIni .= "CooldownColor3=00ffff`n"
	defaultIni .= "CooldownColor4=ffffff`n"
	defaultIni .= "CooldownColor5=00ff00`n"
	defaultIni .= "CooldownColor6=0000ff`n"
	defaultIni .= "CooldownColor7=ff00ff`n"
	defaultIni .= "[hotkeys]`n"
	defaultIni .= "toggleOverlay=F9`n"
	defaultIni .= "options=F10`n"
	defaultIni .= "cooldown1=1`n"
	defaultIni .= "cooldown2=2`n"
	defaultIni .= "cooldown3=3`n"
	defaultIni .= "cooldown4=4`n"
	defaultIni .= "cooldown5=5`n"
	defaultIni .= "cooldown6=6`n"
	defaultIni .= "cooldown7=7`n"

	FileAppend, %defaultIni%, settings.ini, UTF-16
}

ExitApp