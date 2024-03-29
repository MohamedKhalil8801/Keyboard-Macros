﻿; run script as admin (reload if not as admin) 

if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#WinActivateForce
#Persistent
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ;setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE
Process, Priority,, High
SetKeyDelay, -1
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetControlDelay, -1
SetWinDelay, -1
SetBatchLines, -1
SetCapsLockState, AlwaysOff	 
;DetectHiddenWindows, On
; SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
DllCall("Sleep","UInt",1)
GroupAdd All

Menu Case, Add, &A: UPPERCASE, CCase
Menu Case, Add, &S: lowercase, CCase
Menu Case, Add, &D: Title Case, CCase
Menu Case, Add, &F: Sentence case, CCase
Menu Case, Add
Menu Case, Add, &G: Delete spaces, CCase
Menu Case, Add, &H: Replace spaces with underscores, CCase
Menu Case, Add, &J: Replace underscores with spaces, CCase
Menu Case, Add, &K: Add thousands separator, CCase
Menu Case, Add, &L: Delete thousands separator, CCase
Menu Case, Add, &Y: Replace spaces with dashes, CCase
Menu Case, Add, &U: Replace dashes with spaces, CCase

Active := 0
OneHanded := 0
active_monitor := 1 ; Control var for toggling between last active windows on each monitor
border_thickness := 2
border_duration := 1

Run, powershell.exe -Command "$Process = Get-Process AutoHotKey; $Process.ProcessorAffinity=62", , Hide
; Run, HideMouseAfterInactivity.ahk
Run, Hotstrings.ahk

OnExit("ExitFunc")

AppsKey::Send {Media_Play_Pause}
AppsKey & R::Reload
AppsKey & S::Suspend

; Translate highlighted text by pressing RCtrl
RCtrl:: 
	Send, ^c
	sleep, 50
	Send, !`;
	sleep, 100
	Send, Translate
	sleep, 100
	Send, {Tab}
	sleep, 100
	Send, ^v
	sleep, 50
	Send, {RCtrl Up}{Alt Up}{Tab Up}{`; Up}
return

; Delete line
+Backspace::
	Send {Home}{Shift downtemp}{End}{Del}
	Send ^{Del}
	
	loop
	{
	  sleep, 100
	  getkeystate, state, Backspace, p
	  if state = u
		break
	}
	
	send {Shift up}
	
return
	
^SPACE::  Winset, Alwaysontop, , A ; Set window to Always on top


SetDefaultKeyboard(LocaleID){
	Global
	SPI_SETDEFAULTINPUTLANG := 0x005A
	SPIF_SENDWININICHANGE := 2
	Lan := DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", LocaleID), "Int", 0)
	VarSetCapacity(Lan%LocaleID%, 4, 0)
	NumPut(LocaleID, Lan%LocaleID%)
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", &Lan%LocaleID%, "UInt", SPIF_SENDWININICHANGE)
	WinGet, windows, List
	Loop %windows% {
		PostMessage 0x50, 0, %Lan%, , % "ahk_id " windows%A_Index%
	}
}

; Change language
~LShift::
	OneHanded := 0
	if (DoubleTap("~LShift", 300)){
		Send {Alt downtemp}{Shift downtemp}{Alt up}{Shift up}
		
		loop
		{
		  sleep, 100
		  getkeystate, state, LShift, p
		  if state = u
			break
		}
		
		send {Shift up}{Alt up}
	}

return

~CapsLock::
	Active := 1
	OneHanded := 0
return

~Tab:: OneHanded := 0

; Open emoji panel when double clicking RShift
~RShift::
	OneHanded := 0
	if (DoubleTap("~RShift", 230))
	{
		SetDefaultKeyboard(0x0409)
		Sleep, 200
		Send, {LWin downtemp}{`;}{LWin up}
		
		loop
		{
		  sleep, 100
		  getkeystate, state, CapsLock, p
		  if state = u
			break
		}
		
		send {LWin up}
	}
return

~LCtrl::
	if (DoubleTap("~LCtrl", 230))
	{
		if(OneHanded == 0){
			OneHanded := 1
		} else {
			OneHanded := 0
		}
	} else {
		OneHanded := 0
	}
return

; focus on WebPage body, SC138 = RAlt
*$SC138::
	if (DoubleTap("*$SC138", 300))
	{
		if WinActive("ahk_exe vivaldi.exe")
			Send, {F8}
		else {
			Screen_X := (A_ScreenWidth / 2 - 400)
			;MsgBox, %Screen_X%x%Screen_Y%
			MouseMove, %Screen_X%, 50
			Click Left
			;SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
		}
	}
	else
	{
		;if WinActive("ahk_exe vivaldi.exe")
		;	Send, {F9}
		;else {
			Screen_X := (A_ScreenWidth - 15)
			Screen_Y := (A_ScreenHeight / 2)
			;MsgBox, %Screen_X%x%Screen_Y%
			MouseMove, %Screen_X%, %Screen_Y%
			Click Left
			;SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
		;}
	}	
return

DoubleTap(Key, MaxTime)
{
	return (A_PriorHotKey == Key AND A_TimeSincePriorHotkey < MaxTime  AND A_TimeSincePriorHotkey > 100) == 1
}

#If (GetKeyState("CapsLock", "P") or (OneHanded == 1))
	Active := 1
	
	; arrow keys
	i::up
	j::left
	k::down
	l::right
	

	; page up/page down & home/end
	o::
		if (DoubleTap("o", 300))
			Send, {home}
		else
			Send, {PgUp}
	return
	m::
		if (DoubleTap("m", 300))
			Send, {end}
		else
			Send, {PgDn}
	return
	
	; jump keys
	h::Send, ^{left}
	`;::Send, ^{Right}

	u::Send, {Home}
	p::Send, {End}
	
	; Browser controls
	a::Send ^+{Tab}
	d::Send ^{Tab}
	s::Send !{left}
	w::Send !{right}
	q::Send, ^w
	r::Send, ^{R}
	t::Send, ^t
	e::Send, ^+{t}
	
	
	/::
		Send, ^c
		Sleep 50
		Run, https://www.google.com/search?q=%clipboard%
	Return
	

	Backspace::Send, {delete}
	SPACE & Backspace::Send, +^{Right}{Backspace}

	
	; Select mode
	SPACE & w::
		WinGetTitle, Title, A
		WinSet, ExStyle, ^0x80, %Title%
		Send {LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}
		sleep, 50
		WinSet, ExStyle, ^0x80, %Title%
		WinActivate, %Title%
		ToolTip 1, A_ScreenWidth/2, A_ScreenHeight/6 ; Show initial tooltip
		SetTimer, HideToolTip, 1000 ; Hide after 0.5 second
	Return
	SPACE & s::
		WinGetTitle, Title, A
		WinSet, ExStyle, ^0x80, %Title%
		Send {LWin down}{Ctrl down}{Right}{Ctrl up}{LWin up}
		sleep, 50
		WinSet, ExStyle, ^0x80, %Title%
		WinActivate, %Title%
		ToolTip 2, A_ScreenWidth/2, A_ScreenHeight/6 ; Show initial tooltip
		SetTimer, HideToolTip, 1000 ; Hide after 0.5 second
	Return
	SPACE & t::#^d
	SPACE & a::^#Left
	SPACE & q::^#F4
	SPACE & d::^#Right
	SPACE & i::+up
	SPACE & j::+left
	SPACE & k::+down
	SPACE & l::+right
	SPACE & h::Send, +^{Left}
	SPACE & `;::Send, +^{Right}
	SPACE & o::Send, +{home}
	SPACE & m::Send, +{end}
	SPACE & u::Send, +{home}
	SPACE & p::Send, +{end}

	SPACE & 1::#1
	SPACE & 2::#2
	SPACE & 3::#3
	SPACE & 4::#4
	SPACE & 5::#5
	SPACE & 6::#6
	SPACE & 7::#7
	SPACE & 8::#8
	SPACE & 9::#9
	
	x::WinClose A
	
	
	y::
		GetText(TempText)
		If NOT ERRORLEVEL
		   Menu Case, Show
	Return
	
	; Switching apps
	1::
		wTitle = ahk_class Chrome_WidgetWin_1 ahk_exe msedge.exe
		If WinExist(wTitle)
			WinActivate
		else If WinExist("ahk_exe vivaldi.exe")
			WinActivate, ahk_exe vivaldi.exe
		else
			Run vivaldi.exe
			
		DrawBorder(border_duration)
	return
		
	2::	
		If WinExist("ahk_exe code.exe")
			WinActivate
		else if WinExist("ahk_exe pycharm64.exe")
			WinActivate, ahk_exe pycharm64.exe
		else 
			Run C:\Users\Mohammed Khalid\AppData\Local\Programs\Microsoft VS Code\Code.exe
			
		DrawBorder(border_duration)
	return
	
	3:: 
		If WinExist("ahk_exe notepad++.exe")
			WinActivate
		else
			Run notepad++.exe
			
		DrawBorder(border_duration)
	return
	
	4::
		If WinExist("WhatsApp")
			WinActivate
		else
			Run D:\Apps\WhatsApp.lnk
			
		DrawBorder(border_duration)
	return
	
	
	5::
		If WinExist("ahk_exe Discord.exe")
			WinActivate
		else
			Run D:\Apps\Discord.lnk
			
		DrawBorder(border_duration)
		
	return
	
	
	6::
		If WinExist("ahk_exe Spotify.exe")
			WinActivate
		else
			Run D:\Apps\Spotify.lnk
			
		DrawBorder(border_duration)
	return
	
	7:: 
		If WinExist("ahk_exe MultiCommander.exe")
			WinActivate
		else
			Run D:\Apps\MultiCommander (x64).lnk
			
		DrawBorder(border_duration)
	return
	
	8::
		If WinExist("Calculator")
			WinActivate
		else
			Run calc.exe
			
		DrawBorder(border_duration)
	return
	
	9::
		If WinExist("ahk_exe cmd.exe")
			WinActivate
		else
			Run cmd.exe
			
		DrawBorder(border_duration)
	return
	
	0::
		If WinExist("ahk_exe procexp64.exe")
			WinActivate
		else
			Run D:\Apps\ProcessExplorer\procexp64.exe
			
		DrawBorder(border_duration)
	return
	
	; Toggle between last active windows on each monitor
	RShift::
		
		if (active_monitor = 1)
			active_monitor := 2
		else if (active_monitor = 2)
			active_monitor := 1
		
		If GetMonitor() = 1
			active_monitor := 2
		else
			active_monitor := 1
			
		;MsgBox % active_monitor
		SysGet, Mon, Monitor, %active_monitor%
		;MsgBox, %active_monitor%: Left: %MonLeft% -- Top: %MonTop% -- Right: %MonRight% -- Bottom %MonBottom%
		list := ""
		WinGet, id, list
		Loop, %id%
		{
			this_ID := id%A_Index%
			WinGetClass, Class, ahk_id %this_ID%
				If (Class = "")
					continue
			WinGetTitle, title, ahk_id %this_ID%
				If (title = "")
					continue
			If !IsWindow(WinExist("ahk_id" . this_ID))
					continue
			WinGetPos, X,,,, ahk_id %this_ID%
			;MsgBox, % X
				if ((active_monitor = 1 and X >= (MonRight - 10)) or (active_monitor = 2 and X <= (MonLeft - 10)))
					continue
			WinActivate, ahk_id %this_ID%, ,2
					break
		}
		
		DrawBorder(border_duration)
	return

	; Switch active window to the other monitor
	Enter::
		DrawBorder(border_duration)
		
		MMPrimDPI := 0.9179 ;DPI Scale of the primary monitor (divided by 100).
		MMSecDPI := 0.8471  ;DPI Scale of the secondary monitor (divided by 100).
		SysGet, MMCount, MonitorCount
		SysGet, MMPrimary, MonitorPrimary
		SysGet, MMPrimLRTB, Monitor, MMPrimary
		WinGetPos, MMWinGetX, MMWinGetY, MMWinGetWidth, MMWinGetHeight, A
		MMDPISub := Abs(MMPrimDPI - MMSecDPI) + 1
		
		MMWinGetX := MMWinGetX + 2
		MMWinGetY := MMWinGetY + 2
		
		;Second mon is off, window is lost, bring to primary
		if ( (MMCount = 1) and !((MMWinGetX > MMPrimLRTBLeft + 20) and (MMWinGetX < MMPrimLRTBRight - 20) and (MMWinGetY > MMPrimLRTBTop + 20) and (MMWinGetY < MMPrimLRTBBottom - 20)) ){
			if ((MMPrimDPI - MMSecDPI) >= 0)
				MMWHRatio := 1 / MMDPISub
			Else
				MMWHRatio := MMDPISub
			MMWinMoveWidth := MMWinGetWidth * MMWHRatio
			MMWinMoveHeight := MMWinGetHeight * MMWHRatio
			WinMove, A,, 0, 0, MMWinMoveWidth, MMWinMoveHeight
			WinMove, A,, 0, 0, MMWinMoveWidth, MMWinMoveHeight ;Fail safe
			return
		}
		if (MMPrimary = 1)
			SysGet, MMSecLRTB, Monitor, 2
		Else
			SysGet, MMSecLRTB, Monitor, 1
		MMSecW := MMSecLRTBRight - MMSecLRTBLeft
		MMSecH := MMSecLRTBBottom - MMSecLRTBTop
		
		/*
		a := (MMWinGetX > MMPrimLRTBLeft - 20)
		b := (MMWinGetX < MMPrimLRTBRight + 20)
		c := (MMWinGetY > MMPrimLRTBTop - 20)
		d := (MMWinGetY < MMPrimLRTBBottom + 20)
		
		e := (MMWinGetX > MMSecLRTBLeft - 20)
		f := (MMWinGetX < MMSecLRTBRight + 20)
		g := (MMWinGetY > MMSecLRTBTop - 20)
		h := (MMWinGetY < (MMSecLRTBBottom + 20))
		
		MsgBox, Primary Conditions:`n (%MMWinGetX% %MMPrimLRTBLeft%): %a% `n (%MMWinGetX% %MMPrimLRTBRight%): %b% `n (%MMWinGetY% %MMPrimLRTBTop%): %c% `n (%MMWinGetY% %MMPrimLRTBBottom%): %d%
		MsgBox, Secondary Conditions:`n (%MMWinGetX% %MMSecLRTBLeft%): %e% `n (%MMWinGetX% %MMSecLRTBRight%): %f% `n (%MMWinGetY% %MMSecLRTBTop%): %g% `n (%MMWinGetY% %MMSecLRTBBottom%): %h%
		*/
		
		;Primary to secondary
		if ( (MMWinGetX > MMPrimLRTBLeft - 20) and (MMWinGetX < MMPrimLRTBRight - 8) and (MMWinGetY > MMPrimLRTBTop - 20) and (MMWinGetY < MMPrimLRTBBottom + 20) ){
			;MsgBox, Primary to secondary
			if ( (MMSecW) and (MMSecH) ){ ;Checks if sec mon exists. Could have used MMCount instead: if (MMCount >= 2){}
				if ((MMSecDPI - MMPrimDPI) >= 0){
					MMWidthRatio := (MMSecW / A_ScreenWidth) / MMDPISub
					MMHeightRatio := (MMSecH / A_ScreenHeight) / MMDPISub
				}
				Else {
					MMWidthRatio := (MMSecW / A_ScreenWidth) * MMDPISub
					MMHeightRatio := (MMSecH / A_ScreenHeight) * MMDPISub            
				}
				MMWinMoveX := (MMWinGetX * MMWidthRatio) + MMSecLRTBLeft
				MMWinMoveY := (MMWinGetY * MMHeightRatio) + MMSecLRTBTop
				if (MMSecLRTBBottom - MMWinMoveY < 80) ;Check if window is going under taskbar and fixes it.
					MMWinMoveY -= 80
				MMWinMoveWidth := MMWinGetWidth * MMWidthRatio
				MMWinMoveHeight := MMWinGetHeight * MMHeightRatio
				WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
				WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
			}
		} ;Secondary to primary
		Else if ( (MMWinGetX > MMSecLRTBLeft - 20) and (MMWinGetX < MMSecLRTBRight + 20) and (MMWinGetY > MMSecLRTBTop - 20) and (MMWinGetY < MMSecLRTBBottom + 20) ){
			;MsgBox, Secondary to primary
			if ( (MMSecW) and (MMSecH) ){
				if ((MMPrimDPI - MMSecDPI) >= 0){
					MMWidthRatio := (A_ScreenWidth / MMSecW) / MMDPISub
					MMHeightRatio := (A_ScreenHeight / MMSecH) / MMDPISub
				}
				Else{
					MMWidthRatio := (A_ScreenWidth / MMSecW) * MMDPISub
					MMHeightRatio := (A_ScreenHeight / MMSecH) * MMDPISub
				}
				MMWinMoveX := (MMWinGetX - MMSecLRTBLeft) * MMWidthRatio
				MMWinMoveY := (MMWinGetY - MMSecLRTBTop) * MMHeightRatio
				if (MMPrimLRTBBottom - MMWinMoveY < 80)
					MMWinMoveY -= 80
				MMWinMoveWidth := MMWinGetWidth * MMWidthRatio
				MMWinMoveHeight := MMWinGetHeight * MMHeightRatio
				WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
				WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
			}
		} ;If window is out of current monitors' boundaries or if script fails
		Else{
			MsgBox, 4, MM, % "Current window is in " MMWinGetX " " MMWinGetY "`nDo you want to move it to 0,0?"
			IfMsgBox Yes
			WinMove, A,, 0, 0
		}
	return
	
	
	; Toggle between Minimize/Maximize/Restore for active window
	\::
		WinGetActiveTitle, WinTitle
		WinGet,WinState,MinMax, %WinTitle%
		
		
		if GetKeyState("Space", "P")
		{
			;WinMinimize % ( Stored := WinTitle, i++ )
			WinMinimize % ( WinTitle, i++ )
			return
		}
		
		If (WinState = -1) or (WinState = 0)
		{
			WinMaximize % ( WinTitle, i++ )
		}
		else If WinState = 1
		{
			;WinActivateBottom % Stored	
			;WinRestore % ( Stored, i++ )
			WinActivateBottom % WinTitle	
			WinRestore % ( WinTitle, i++ )
		}
		
		DrawBorder(border_duration)
	Return
#If

CapsLock up::
	send {Shift up}{Ctrl up}{Alt up}{SPACE up}
	Active := 0
return

GetMonitor(hwnd := 0) {
; If no hwnd is provided, use the Active Window
	if (hwnd)
		WinGetPos, winX, winY, winW, winH, ahk_id %hwnd%
	else
		WinGetActiveStats, winTitle, winW, winH, winX, winY

	SysGet, numDisplays, MonitorCount
	SysGet, idxPrimary, MonitorPrimary

	Loop %numDisplays%
	{	SysGet, mon, MonitorWorkArea, %a_index%
	; Left may be skewed on Monitors past 1
		if (a_index > 1)
			monLeft -= 10
	; Right overlaps Left on Monitors past 1
		else if (numDisplays > 1)
			monRight -= 10
	; Tracked based on X. Cannot properly sense on Windows "between" monitors
		if (winX >= monLeft && winX < monRight)
			return %a_index%
	}
; Return Primary Monitor if can't sense
	return idxPrimary
}

AddThousandsSeparator(Number,Separator:=","){
	return RegExReplace(Number,"\G\d+?(?=(\d{3})+(?:\D|$))","$0" Separator)
}

CCase:
	If (A_ThisMenuItemPos = 1)
	   StringUpper, TempText, TempText
	Else If (A_ThisMenuItemPos = 2)
	   StringLower, TempText, TempText
	Else If (A_ThisMenuItemPos = 3)
	   StringLower, TempText, TempText, T
	Else If (A_ThisMenuItemPos = 4)
	{
	   StringLower, TempText, TempText
	   TempText := RegExReplace(TempText, "((?:^|[.!?]\s+)[a-z])", "$u1")
	} 
	;Seperator, no 5
	Else If (A_ThisMenuItemPos = 6)
	{
	   TempText := RegExReplace(TempText, "( )", "")
	}
	Else If (A_ThisMenuItemPos = 7)
	{
	   TempText := RegExReplace(TempText, "( )", "_")
	}
	Else If (A_ThisMenuItemPos = 8)
	{
	   TempText := RegExReplace(TempText, "(_)", " ")
	}
	Else If (A_ThisMenuItemPos = 9)
	{
	   TempText := AddThousandsSeparator(TempText, ",")
	}
	Else If (A_ThisMenuItemPos = 10)
	{
	   TempText := RegExReplace(TempText, ",", "")
	}
	Else If (A_ThisMenuItemPos = 11)
	{
	   TempText := RegExReplace(TempText, "( )", "-")
	}
	Else If (A_ThisMenuItemPos = 12)
	{
	   TempText := RegExReplace(TempText, "(-)", " ")
	}
	PutText(TempText)
Return

; Copies the selected text to a variable while preserving the clipboard.
GetText(ByRef MyText = "")
{
   SavedClip := ClipboardAll
   Clipboard =
   Send ^c
   ClipWait 0.5
   If ERRORLEVEL
   {
      Clipboard := SavedClip
      MyText =
      Return
   }
   MyText := Clipboard
   Clipboard := SavedClip
   Return MyText
}

; Pastes text from a variable while preserving the clipboard.
PutText(MyText)
{
   SavedClip := ClipboardAll 
   Clipboard =              ; For better compatability
   Sleep 20                 ; with Clipboard History
   Clipboard := MyText
   Send ^v
   Sleep 100
   Clipboard := SavedClip
   Return
}


;-----------------------------------------------------------------
; Check whether the target window is activation target
;-----------------------------------------------------------------
IsWindow(hWnd){
    WinGet, dwStyle, Style, ahk_id %hWnd%
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
        return false
    }
    WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
    if (dwExStyle & 0x00000080) {
        return false
    }
    WinGetClass, szClass, ahk_id %hWnd%
    if (szClass = "TApplication") {
        return false
    }
	;MsgBox % hWnd
    return true
}

DrawRect:
	WinGetPos, x, y, w, h, A
	
	x := x + 10
	w := w - 20
	h := h - 10
	
	iw := w+border_thickness, ih := h+border_thickness
	w := w+border_thickness*2, h:= h+border_thickness*2, x := x-border_thickness, y := y-border_thickness
			
	Gui, +Lastfound +AlwaysOnTop +Toolwindow -Caption
	Gui, Color, ffae00
	
	WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0 %border_thickness%-%border_thickness% %iw%-%border_thickness% %iw%-%ih% %border_thickness%-%ih% %border_thickness%-%border_thickness%
	
	try
		Gui, Show, w%w% h%h% x%x% y%y% NoActivate, Table awaiting Action
return

DisableDrawRect:
	SetTimer, DrawRect, Off
	SetTimer, DisableDrawRect, Off
	Gui, Destroy
return

DrawBorder(duration) {
	SetTimer, DrawRect, 1
	duration := duration * 1000
	SetTimer, DisableDrawRect, %duration%
}

HideToolTip:
	ToolTip ; Hide tooltip
Return

ExitFunc(ExitReason, ExitCode)
{
	If (ExitReason != "Reload") {
		Run taskkill /f /im autohotkey.exe,, hide
		Run taskkill /f /im AutoHotkeyU64.exe,, hide
		Run taskkill /f /im AutoHotkeyA32.exe,, hide
		Run taskkill /f /im AutoHotkeyU32.exe,, hide
	}
}