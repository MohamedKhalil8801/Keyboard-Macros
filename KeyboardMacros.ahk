; run script as admin (reload if not as admin) 

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

Menu Case, Add, &UPPERCASE, CCase
Menu Case, Add, &lowercase, CCase
Menu Case, Add, &Title Case, CCase
Menu Case, Add, &Sentence case, CCase
Menu Case, Add
Menu Case, Add, &Delete Spaces, CCase
Menu Case, Add, &Fix Linebreaks, CCase
Menu Case, Add, &Reverse, CCase

Active := 0
OneHanded := 0
active_monitor := 2 ; Control var for toggling between last active windows on each monitor
i := 0 ; Control var for toggling between Minimize/Maximize/Restore for active window

Run, powershell.exe -Command "$Process = Get-Process AutoHotKey; $Process.ProcessorAffinity=62", , Hide

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

+Backspace::
	Send {Home}{Shift downtemp}{End}{Right}{ShiftUp}{Del} ; Delete line
	
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

GetKeyboardLayout(ByRef window)
{
    return DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "Int", WinExist(window), "Int", 0), "UShort")
}
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
		;Send, {F8}
		Screen_X := (A_ScreenWidth / 2 - 400)
		;MsgBox, %Screen_X%x%Screen_Y%
		MouseMove, %Screen_X%, 50
		Click Left
		;SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
	}
	else
	{
		Screen_X := (A_ScreenWidth - 15)
		Screen_Y := (A_ScreenHeight / 2)
		;MsgBox, %Screen_X%x%Screen_Y%
		MouseMove, %Screen_X%, %Screen_Y%
		Click Left
		;SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
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
	h::
		if (DoubleTap("h", 200))
			Send, {home}
		else
			Send, ^{left}
	return
	`;::
		if (DoubleTap("`;", 200))
			Send, {end}
		else
			Send, ^{Right}
	return
	
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
	SPACE & i::+up
	SPACE & j::+left
	SPACE & k::+down
	SPACE & l::+right
	SPACE & h::Send, +^{Left}
	SPACE & `;::Send, +^{Right}
	SPACE & o::Send, +{home}
	SPACE & m::Send, +{end}
	
	x::!F4
	
	 
	u::
		GetText(TempText)
		If NOT ERRORLEVEL
		   Menu Case, Show
	Return
	
	
	; Switching apps
	1::
		wTitle = ahk_class Chrome_WidgetWin_1 ahk_exe msedge.exe
		If WinExist(wTitle)
			WinActivate
		else
			WinActivate, ahk_exe vivaldi.exe
	return
		
	2::	
		If WinExist("ahk_exe code.exe")
			WinActivate
		else
			WinActivate, ahk_exe pycharm64.exe
	return
	
	3:: 
		If WinExist("ahk_exe notepad++.exe")
			WinActivate
		else
			Run notepad++.exe
	return
	
	4::
		If WinExist("ahk_exe cmd.exe")
			WinActivate
		else
			Run cmd.exe
	return
	
	5:: WinActivate, ahk_exe OneCommander.exe
	
	7::
		If WinExist("Calculator")
			WinActivate
		else
			Run calc.exe
	return
	
	; Toggle between last active windows on each monitor
	RShift::
		if (active_monitor = 1)
			active_monitor := 2
		else if (active_monitor = 2)
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
	return
	
	; Switch active window to the other monitor
	Enter::
		MMPrimDPI := 0.9179 ;DPI Scale of the primary monitor (divided by 100).
		MMSecDPI := 0.8471  ;DPI Scale of the secondary monitor (divided by 100).
		SysGet, MMCount, MonitorCount
		SysGet, MMPrimary, MonitorPrimary
		SysGet, MMPrimLRTB, Monitor, MMPrimary
		WinGetPos, MMWinGetX, MMWinGetY, MMWinGetWidth, MMWinGetHeight, A
		MMDPISub := Abs(MMPrimDPI - MMSecDPI) + 1
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
		;Primary to secondary
		if ( (MMWinGetX > MMPrimLRTBLeft - 20) and (MMWinGetX < MMPrimLRTBRight + 20) and (MMWinGetY > MMPrimLRTBTop - 20) and (MMWinGetY < MMPrimLRTBBottom + 20) ){
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
		if ( Mod( i, 3 ) = 0 )
		{
			WinMaximize % ( WinTitle, i++ )
		}
		else if ( Mod( i, 3 ) = 1 )
		{
			WinMinimize % ( Stored := WinTitle, i++ )
		}
		else if ( Mod( i, 3 ) = 2 )
		{
			WinActivateBottom % Stored	
			WinRestore % ( Stored, i++ )
		}
	Return
#If

CapsLock up::
	send {Shift up}{Ctrl up}{Alt up}{SPACE up}
	Active := 0
return

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
	   TempText := RegExReplace(TempText, "\R", "`r`n")
	}
	Else If (A_ThisMenuItemPos = 8)
	{
	   Temp2 =
	   StringReplace, TempText, TempText, `r`n, % Chr(29), All
	   Loop Parse, TempText
		  Temp2 := A_LoopField . Temp2
	   StringReplace, TempText, Temp2, % Chr(29), `r`n, All
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


; ; == HOT STRINGS ==

; ; Current date and time
FormatDateTime(format, datetime="") {
    if (datetime = "") {
        datetime := A_Now
    }
    FormatTime, CurrentDateTime, %datetime%, %format%
    SendInput, %CurrentDateTime%
    return
}

GetIP(URL){
	http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.Open("GET",URL,1)
	http.Send()
	http.WaitForResponse
	If (http.ResponseText="Error"){
		MsgBox 16, IP Address, Sorry, your public IP address could not be detected
		Return
	}
	send % http.ResponseText
}


; Hotstrings
:C*:/datetime1::
    FormatDateTime("dddd, MMMM dd, yyyy, HH:mm")
Return

:C*:/datetime::
    FormatDateTime("dddd, MMMM dd, yyyy hh:mm tt")
Return
:C*:/time1::
    FormatDateTime("HH:mm")
Return
:C*:/time::
    FormatDateTime("hh:mm tt")
Return
::/date:: January 30, 2023
    FormatDateTime("MMMM dd, yyyy")
Return
:C*:/date1::
    FormatDateTime("MM/dd/yyyy")
Return
::/day::
    FormatDateTime("dddd")
Return
:C*:/day1::
    FormatDateTime("dd")
Return
::/month::
    FormatDateTime("MMMM")
Return
:C*:/month1::
    FormatDateTime("MM")
Return
:C*:/year::
    FormatDateTime("yyyy")
Return

:C*:/j::jupyter notebook
::/router::192.168.1.1
:C*:/router1::192.168.0.1
::/mail::zchggf11@hotmail.com
:C*:/mail1::mohamedkhalil8801@gmail.com

::/ip:: 
	GetIP("http://www.netikus.net/show_ip.html")
Return

:C*:/ip1:: 
	send % A_IPAddress2
Return

:C*:/text::Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.