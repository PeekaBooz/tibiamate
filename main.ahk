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

SetWorkingDir %A_MyDocuments%\AutoHotKey\TibiaMate

elog := A_Now . " " . A_AhkVersion . " " . macroVersion "`n"
FileAppend, %elog% , error.txt, UTF-16

UrlDownloadToFile, %downloadURL%/version.html, version.html
	if ErrorLevel
			GuiControl,1:, guiErr, ED06

FileRead, newestVersion, version.html

if ( macroVersion < newestVersion ) {
	UrlDownloadToFile, %downloadURL%/changelog.txt, changelog.txt
			if ErrorLevel
					GuiControl,1:, guiErr, ED08
	Gui, 4:Add, Text,, Update Available.`nYoure running TibiaMate version %macroVersion%. The newest is version %newestVersion%`nProceed with update? It will only take a moment, and the script will automatically restart.
	FileRead, changelog, changelog.txt
	Gui, 4:Add, Edit, w600 h200 +ReadOnly, %changelog% 
	Gui, 4:Add, Button, section default grunUpdate, Update
	Gui, 4:Add, Button, ys x540 gdontUpdate, Skip Update
	Gui, 4:Show,, TibiaMate Patch Notes
}

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

RunWait, verify.ahk

readFromFile() ;first run

;timers
sleepTime := 500
updateTrackingTimer := 5000 ; 5 seconds
baseUpdateTrackingTimer := 300000 ; 5 minute
verifyLogoutTimer := 0
baseVerifyLogoutTimer := 60000 ; 1 minute
processWarningFound := 0
overlayTimer := 0
baseOverlayTimer := sleepTime
updateTrackingTimerActive := true
overlayTimerActive := true
preloadCportsTimer := 0
basePreloadCportsTimer := 60000 ; 1 minute
calcd = 0

;Ranking Overlay
Gui, 1:+ToolWindow
Gui, 1:Color, %colorBG%
Gui, 1:Font, %colorText% s14, Lucida Sans Unicode
Gui, 1:Add, Text, x20 y1 w200 vguiRank, TibiaMate

Gui, 1:Font, s8
Gui, 1:Add, Text, x5 y21, By Peeka | tibiamate.com
Gui, 1:Add, Text, x213 y1 vguiSettings, Settings: %hotkeyOptions%

Gui, 1:Font, s10
Gui, 1:Add, Text, x160 y17 vguiErr, Rashid: Liberty Bay
Gui, 1:Font, s14

Gui, 1:Show, x0 y0 w278 h11
Gui, 1:-Caption +AlwaysOnTop +Disabled +E0x20 +LastFound
Winset,TransColor, 0xFFFFFF
Winset,Transparent, 190

;Menu
Gui, 2:Add, Text,x5 h20, Rashid X Offset:
Gui, 2:Add, Text,x5 h20, Rashid Y Offset:
Gui, 2:Add, Text,x5 h20, Cooldown X Offset:
Gui, 2:Add, Text,x5 h20, Cooldown Y Offset:
Gui, 2:Add, Text,x5 h20, Rashid BG Color:
Gui, 2:Add, Text,x5 h20, Rashid Text Color:
Gui, 2:Add, Text,x5 h20,
Gui, 2:Add, Text,x5 h20, Toggle Rashid:
Gui, 2:Add, Text,x5 h20, Settings (This) :

Gui, 2:Add, Edit, ym vguiXOffset w150 h20, %xOffset%
Gui, 2:Add, Edit, vguiYOffset w150 h20, %yOffset%
Gui, 2:Add, Edit, vguiWAXOffset w150 h20, %waxOffset%
Gui, 2:Add, Edit, vguiWAYOffset w150 h20, %wayOffset%
Gui, 2:Add, Edit, w150 h20 vguicolorBG , %colorBG%
Gui, 2:Add, Edit, w150 h20 vguicolorText , %colorText%
Gui, 2:Add, Text, w150 h20, --- Setting Hotkeys ---
Gui, 2:Add, Hotkey, w150 h20 vguihotkeyToggleOverlay , %hotkeyToggleOverlay%
Gui, 2:Add, Hotkey, w150 h20 vguihotkeyOptions, %hotkeyOptions%

;Hotkeys
Gui, 2:Add, Text, ym w90, Spells Hotkeys
Gui, 2:Add, Hotkey, vguihotkeyCooldown1 w100 h20 , %hotkeyCooldown1%
Gui, 2:Add, Hotkey, vguihotkeyCooldown2 w100 h20 , %hotkeyCooldown2%
Gui, 2:Add, Hotkey, vguihotkeyCooldown3 w100 h20 , %hotkeyCooldown3%
Gui, 2:Add, Hotkey, vguihotkeyCooldown4 w100 h20 , %hotkeyCooldown4%
Gui, 2:Add, Hotkey, vguihotkeyCooldown5 w100 h20 , %hotkeyCooldown5%
Gui, 2:Add, Hotkey, vguihotkeyCooldown6 w100 h20 , %hotkeyCooldown6%
Gui, 2:Add, Hotkey, vguihotkeyCooldown7 w100 h20 , %hotkeyCooldown7%
Gui, 2:Add, Button, gshowDiscord, Join our Discord

;Commands

Gui, 2:Add, Text, ym w90, Duration (ms):
Gui, 2:Add, Edit, vguiduration1 w90 h20, %duration1%
Gui, 2:Add, Edit, vguiduration2 w90 h20, %duration2%
Gui, 2:Add, Edit, vguiduration3 w90 h20, %duration3%
Gui, 2:Add, Edit, vguiduration4 w90 h20, %duration4%
Gui, 2:Add, Edit, vguiduration5 w90 h20, %duration5%
Gui, 2:Add, Edit, vguiduration6 w90 h20, %duration6%
Gui, 2:Add, Edit, vguiduration7 w90 h20, %duration7%
Gui, 2:Add, Button, gchangelogGui, View Changelog

Gui, 2:Add, Text, ym w90, Color:
Gui, 2:Add, Edit, vguicooldownColor1 w90 h20, %cooldownColor1%
Gui, 2:Add, Edit, vguicooldownColor2 w90 h20, %cooldownColor2%
Gui, 2:Add, Edit, vguicooldownColor3 w90 h20, %cooldownColor3%
Gui, 2:Add, Edit, vguicooldownColor4 w90 h20, %cooldownColor4%
Gui, 2:Add, Edit, vguicooldownColor5 w90 h20, %cooldownColor5%
Gui, 2:Add, Edit, vguicooldownColor6 w90 h20, %cooldownColor6%
Gui, 2:Add, Edit, vguicooldownColor7 w90 h20, %cooldownColor7%
Gui, 2:Add, Button, default gupdateHotkeys, Save Settings


;Cooldown Overlay
Gui, 8:+ToolWindow
Gui, 8:Color, %colorBG%
Gui, 8:Show, x0 y0 w219 h41 NA
Gui, 8:Add, Progress, x0 y0 w225 h10 c%cooldownColor1% BackGround%colorBG% vProg1
Gui, 8:Add, Progress, x0 y10 w225 h10 c%cooldownColor2% BackGround%colorBG% vProg2
Gui, 8:Add, Progress, x0 y20 w225 h10 c%cooldownColor3% BackGround%colorBG% vProg3
Gui, 8:Add, Progress, x0 y30 w225 h10 c%cooldownColor4% BackGround%colorBG% vProg4
Gui, 8:Add, Progress, x0 y40 w225 h10 c%cooldownColor5% BackGround%colorBG% vProg5
Gui, 8:Add, Progress, x0 y50 w225 h10 c%cooldownColor6% BackGround%colorBG% vProg6
Gui, 8:Add, Progress, x0 y60 w225 h10 c%cooldownColor7% BackGround%colorBG% vProg7
Gui, 8:-Caption +AlwaysOnTop +Disabled +E0x20 +LastFound
WinSet, TransColor, 0x%colorBG% 225

Menu, Tray, Tip, TibiaMate v%macroVersion%
Menu, Tray, NoStandard
Menu, Tray, Add, TibiaMate Settings, optionsCommand
Menu, Tray, Add, Join Discord, showDiscord
Menu, Tray, Add, View Changelog, changelogGui

Menu, Tray, Default, TibiaMate Settings
Menu, Tray, Add ; Separator
Menu, Tray, Standard

; some initializers. Put these together later.
toggle := 0
toggleOverlay()
readFromFile()

;start the main loop. Gotta be last
loopTimers()


//functions

error(var,var2:="",var3:="",var4:="",var5:="",var6:="",var7:="") {
	GuiControl,1:, guiErr, %var%
	print := A_Now . "," . var . "," . var2 . "," . var3 . "," . var4 . "," . var5 . "," . var6 . "," . var7 . "`n"
	FileAppend, %print%, error.txt, UTF-16
	return
}

	
cooldownCommand1:
	control(1)
	return
cooldownCommand2:
	control(2)
	return
cooldownCommand3:
	control(3)
	return
cooldownCommand4:
	control(4)
	return
cooldownCommand5:
	control(5)
	return
cooldownCommand6:
	control(6)
	return
cooldownCommand7:
	control(7)
	return

control(i){
	global prog1, prog2, prog3, prog4, prog5, prog6, prog7
	prog%i% := A_TickCount
	return
}

changelogGui(){
changelogGui:
	FileRead, changelog, changelog.txt
	Gui, 3:Add, Edit, w600 h200 +ReadOnly, %changelog% 
	Gui, 3:Show,, TibiaMate Patch Notes
	return
}

toggleOverlay(){
toggleOverlayCommand:
	global toggle
	; 0 1
	if ( toggle = 0 ) {
		toggle := 1
	}
	else {
		toggle := 0
	}
	
	if toggle = 0
	{
		;Gui, 1:Show, NA
		;Gui, 8:Show, NA
		Gui, 1:Hide
	}
	if toggle = 1
	{
		Gui, 1:Show, NA
	}
	return
}

checkOverlay(){
	global overlayTimer, baseOverlayTimer, toggle, xOffset, yOffset, processWarningFound, calcd, waxOffset, wayOffset, onex, oney, eightx, eighty
	
	IfWinActive ahk_class Qt5QWindowOwnDCIcon
	{
		if toggle != 0
		{
			if ( toggle = 1 )
			{
				hh := 0 ; y
				hh += yOffset
				ww := 0 ; width - 231
				ww += xOffset
				onex := ww
				oney := hh
				Gui, 1:Show, y%oney% x%onex% NA
			} else {
				Gui, 1:Hide
			}
		}
		WinGetActiveStats,name,width,height,x,y
		if ( calcd = 0 ) 
		{
			width += x
			width *= 0.3215
			width += waxOffset
			height *= 0.91
			height += wayOffset
			eighty := height
			eightx := width
			calcd = 1
		}
		Gui, 8:Show, y%eighty% x%eightx% NA

	} else {
		Gui, 8:Hide
		Gui, 1:Hide
	}
	
	overlayTimer := baseOverlayTimer
	return
}

runUpdate(){
global
runUpdate:
	if launcherPath != ERROR
		UrlDownloadToFile, %downloadURL%/tibiamate.ahk, %launcherPath%
		UrlDownloadToFile, %downloadURL%/verify.ahk, verify.ahk
		UrlDownloadToFile, %downloadURL%/main.ahk, main.ahk
		if ErrorLevel {
			error("update","fail",A_ScriptFullPath, macroVersion, A_AhkVersion)
			error("ED07")
		}
		else {
			error("update","pass",A_ScriptFullPath, macroVersion, A_AhkVersion)
			Run "%A_ScriptFullPath%"
		}
	Sleep 5000 ;This shouldn't ever hit.
	error("update","uhoh", A_ScriptFullPath, macroVersion, A_AhkVersion)
dontUpdate:
	Gui, 4:Destroy
	return	
showDiscord:
	Run https://discord.gg/W6u6n3t
	return
}

loopTimers(){
	global
	Loop {
		cooldowns = 7
		do = 0
		if ( toggle = 1 ) || ( toggle = 0 )
		{
			Loop % cooldowns
			{
				i := A_Index
				ppp := prog%i% + duration%i% + 501
				IfLess, A_TickCount , %ppp%
				{
					do = 1
					p := prog%i%
					d := duration%i%
					s = %d%
					s /= 100
					pp := p - A_TickCount
					pp /= s
					pp := 100 + pp
					GuiControl,8:,Prog%i%,%pp%
				}
			}
		}
		if ( do = 1 ) {
			ss := 100
		} else {
			ss := sleepTime
		}

		if ( overlayTimerActive = true ) 
			overlayTimer -= ss    
		if ( updateTrackingTimerActive = true )
			updateTrackingTimer -= ss

		if ( overlayTimer <= 0 ) && ( overlayTimerActive = true )
		{
			checkOverlay()
		}


		Sleep ss  
	}
	return
}

updateTracking(){
	global accName, league, updateTrackingTimer, baseUpdateTrackingTimer, toggle, charName
	return
}

optionsCommand:
	hotkeys()
return

hotkeys(){
	global processWarningFound, macroVersion
	Gui, 2:Show,, TibiaMate | Version %macroVersion% | AHK Version %A_AhkVersion%
	processWarningFound := 0
	Gui, 6:Hide
	return
}

updateHotkeys:
	submit()
return

submit(){  
	global
	Gui, 2:Submit 
	IniWrite, %guiXOffset%, settings.ini, variables, XOffset
	IniWrite, %guiYOffset%, settings.ini, variables, YOffset
	IniWrite, %guiWAXOffset%, settings.ini, variables, WAXOffset
	IniWrite, %guiWAYOffset%, settings.ini, variables, WAYOffset
	IniWrite, %guicolorBG%, settings.ini, variables, ColorBG
	IniWrite, %guicolorText%, settings.ini, variables, ColorText
	IniWrite, %toggle%, settings.ini, variables, OverlayToggle
	IniWrite, %guiduration1%, settings.ini, variables, duration1
	IniWrite, %guiduration2%, settings.ini, variables, duration2
	IniWrite, %guiduration3%, settings.ini, variables, duration3
	IniWrite, %guiduration4%, settings.ini, variables, duration4
	IniWrite, %guiduration5%, settings.ini, variables, duration5
	IniWrite, %guiduration6%, settings.ini, variables, duration6
	IniWrite, %guiduration7%, settings.ini, variables, duration7
	IniWrite, %guicooldownColor1%, settings.ini, variables, cooldownColor1
	IniWrite, %guicooldownColor2%, settings.ini, variables, cooldownColor2
	IniWrite, %guicooldownColor3%, settings.ini, variables, cooldownColor3
	IniWrite, %guicooldownColor4%, settings.ini, variables, cooldownColor4
	IniWrite, %guicooldownColor5%, settings.ini, variables, cooldownColor5
	IniWrite, %guicooldownColor6%, settings.ini, variables, cooldownColor6
	IniWrite, %guicooldownColor7%, settings.ini, variables, cooldownColor7
	IniWrite, %guihotkeyToggleOverlay%, settings.ini, hotkeys, toggleOverlay
	IniWrite, %guihotkeyOptions%, settings.ini, hotkeys, options
	IniWrite, %guihotkeyCooldown1%, settings.ini, hotkeys, cooldown1
	IniWrite, %guihotkeyCooldown2%, settings.ini, hotkeys, cooldown2
	IniWrite, %guihotkeyCooldown3%, settings.ini, hotkeys, cooldown3
	IniWrite, %guihotkeyCooldown4%, settings.ini, hotkeys, cooldown4
	IniWrite, %guihotkeyCooldown5%, settings.ini, hotkeys, cooldown5
	IniWrite, %guihotkeyCooldown6%, settings.ini, hotkeys, cooldown6
	IniWrite, %guihotkeyCooldown7%, settings.ini, hotkeys, cooldown7

	readFromFile()

	return    
}

readFromFile(){
	global
	;reset hotkeys ughh.
	Hotkey, IfWinActive, ahk_class Qt5QWindowOwnDCIcon
	If hotkeyToggleOverlay
		Hotkey,% hotkeyToggleOverlay, toggleOverlayCommand, Off
	If hotkeyCooldown1
		Hotkey,% hotkeyCooldown1, cooldownCommand1, Off
	If hotkeyCooldown2
		Hotkey,% hotkeyCooldown2, cooldownCommand2, Off
	If hotkeyCooldown3
		Hotkey,% hotkeyCooldown3, cooldownCommand3, Off
	If hotkeyCooldown4
		Hotkey,% hotkeyCooldown4, cooldownCommand4, Off
	If hotkeyCooldown5
		Hotkey,% hotkeyCooldown5, cooldownCommand5, Off
	If hotkeyCooldown6
		Hotkey,% hotkeyCooldown6, cooldownCommand6, Off
	If hotkeyCooldown7
		Hotkey,% hotkeyCooldown7, cooldownCommand7, Off

	; Hotkey, IfWinActive
	If hotkeyOptions
		Hotkey,% hotkeyOptions, optionsCommand, Off
	
	Hotkey, IfWinActive, ahk_class Qt5QWindowOwnDCIcon

	; variables
	IniRead, xOffset, settings.ini, variables, XOffset
	IniRead, yOffset, settings.ini, variables, YOffset
	IniRead, waxOffset, settings.ini, variables, WAXOffset
	IniRead, wayOffset, settings.ini, variables, WAYOffset
	IniRead, colorBG, settings.ini, variables, ColorBG
	IniRead, colorText, settings.ini, variables, ColorText
	IniRead, toggle, settings.ini, variables, OverlayToggle
	IniRead, duration1, settings.ini, variables, Duration1
	IniRead, duration2, settings.ini, variables, Duration2
	IniRead, duration3, settings.ini, variables, Duration3
	IniRead, duration4, settings.ini, variables, Duration4
	IniRead, duration5, settings.ini, variables, Duration5
	IniRead, duration6, settings.ini, variables, Duration6
	IniRead, duration7, settings.ini, variables, Duration7
	IniRead, cooldownColor1, settings.ini, variables, CooldownColor1
	IniRead, cooldownColor2, settings.ini, variables, CooldownColor2
	IniRead, cooldownColor3, settings.ini, variables, CooldownColor3
	IniRead, cooldownColor4, settings.ini, variables, CooldownColor4
	IniRead, cooldownColor5, settings.ini, variables, CooldownColor5
	IniRead, cooldownColor6, settings.ini, variables, CooldownColor6
	IniRead, cooldownColor7, settings.ini, variables, CooldownColor7
	;hotkeys
	IniRead, hotkeyToggleOverlay, settings.ini, hotkeys, toggleOverlay, %A_Space%
	IniRead, hotkeyOptions, settings.ini, hotkeys, options, %A_Space%
	IniRead, hotkeyCooldown1, settings.ini, hotkeys, cooldown1, %A_Space%
	IniRead, hotkeyCooldown2, settings.ini, hotkeys, cooldown2, %A_Space%
	IniRead, hotkeyCooldown3, settings.ini, hotkeys, cooldown3, %A_Space%
	IniRead, hotkeyCooldown4, settings.ini, hotkeys, cooldown4, %A_Space%
	IniRead, hotkeyCooldown5, settings.ini, hotkeys, cooldown5, %A_Space%
	IniRead, hotkeyCooldown6, settings.ini, hotkeys, cooldown6, %A_Space%
	IniRead, hotkeyCooldown7, settings.ini, hotkeys, cooldown7, %A_Space%

	IniRead, launcherPath, settings.ini, variables, LauncherPath

	Hotkey, IfWinActive, ahk_class Qt5QWindowOwnDCIcon
	If hotkeyToggleOverlay
		Hotkey,% hotkeyToggleOverlay, toggleOverlayCommand, On
	If hotkeyCooldown1
	{
		hkCD1 = ~
		hkCD1 .= hotkeyCooldown1
		Hotkey,% hkCD1, cooldownCommand1, On
	}
	If hotkeyCooldown2
	{
		hkCD2 = ~
		hkCD2 .= hotkeyCooldown2
		Hotkey,% hkCD2, cooldownCommand2, On
	}
	If hotkeyCooldown3
	{
		hkCD3 = ~
		hkCD3 .= hotkeyCooldown3
		Hotkey,% hkCD3, cooldownCommand3, On
	}
	If hotkeyCooldown4
	{
		hkCD4 = ~
		hkCD4 .= hotkeyCooldown4
		Hotkey,% hkCD4, cooldownCommand4, On
	}
	If hotkeyCooldown5
	{
		hkCD5 = ~
		hkCD5 .= hotkeyCooldown5
		Hotkey,% hkCD5, cooldownCommand5, On
	}
	If hotkeyCooldown6
	{
		hkCD6 = ~
		hkCD6 .= hotkeyCooldown6
		Hotkey,% hkCD6, cooldownCommand6, On
	}
	If hotkeyCooldown7
	{
		hkCD7 = ~
		hkCD7 .= hotkeyCooldown7
		Hotkey,% hkCD7, cooldownCommand7, On
	}

	Hotkey, IfWinActive, ahk_class Qt5QWindowOwnDCIcon
	If hotkeyOptions {
		Hotkey,% hotkeyOptions, optionsCommand, On
		GuiControl,1:, guiSettings, Settings:%hotkeyOptions%
	}
	else {
		Hotkey,F10, optionsCommand, On
		msgbox You dont have some hotkeys set!`nPlease hit F10 to open up your config prompt and please configure your hotkeys (Path of Exile has to be in focus).`nThe way you configure hotkeys is now in the GUI (default F10). Otherwise, you didn't put a hotkey for the options menu. You need that silly.
		GuiControl,1:, guiSettings, Settings:%hotkeyOptions%
	}
	
	Hotkey, IfWinActive, ahk_class Qt5QWindowOwnDCIcon

	if waxOffset = ERROR
		waxOffset = 0
	if wayOffset = ERROR
		wayOffset = 0

	if duration1 = ERROR
		duration1 = 4000
	if duration2 = ERROR
		duration2 = 4000
	if duration3 = ERROR
		duration3 = 4000
	if duration4 = ERROR
		duration4 = 4000
	if duration5 = ERROR
		duration5 = 4000
	if duration6 = ERROR
		duration6 = 4000
	if duration7 = ERROR
		duration7 = 4000

	if cooldownColor1 = ERROR
		cooldownColor1 = ffff00
	if cooldownColor2 = ERROR
		cooldownColor2 = ff0000
	if cooldownColor3= ERROR
		cooldownColor3 = 00ffff
	if cooldownColor4= ERROR
		cooldownColor4 = ffffff
	if cooldownColor5= ERROR
		cooldownColor5 = 00ff00
	if cooldownColor6= ERROR
		cooldownColor6 = 0000ff
	if cooldownColor7= ERROR
		cooldownColor7 = ff00ff

	if (colorBG = "ERROR") || (colorBG = "")
		colorBG = 11213a
	if (colorText = "ERROR") || (colorText = "")
		colorText = fcff00

	calcd = 0

	Gui, 1:Color, %colorBG%
	Gui, 1:Font, %colorText% s14, Lucida Sans Unicode
	prog1 := A_TickCount - 10000
	prog2 := A_TickCount - 10000
	prog3 := A_TickCount - 10000
	prog4 := A_TickCount - 10000
	prog5 := A_TickCount - 10000
	prog6 := A_TickCount - 10000
	prog7 := A_TickCount - 10000
	GuiControl, 8:+c%cooldownColor1%, Prog1
	GuiControl, 8:+c%cooldownColor2%, Prog2
	GuiControl, 8:+c%cooldownColor3%, Prog3
	GuiControl, 8:+c%cooldownColor4%, Prog4
	GuiControl, 8:+c%cooldownColor5%, Prog5
	GuiControl, 8:+c%cooldownColor6%, Prog6
	GuiControl, 8:+c%cooldownColor7%, Prog7

	updateTrackingTimer := 5000
}