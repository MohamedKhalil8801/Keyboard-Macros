#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Process, Priority,, High
SetKeyDelay, -1
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetControlDelay, -1
SetWinDelay, -1
SetBatchLines, -1
SetCapsLockState, AlwaysOff
; SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85

Active := 0


Run, powershell -Command "$Process = Get-Process AutoHotKey; $Process.ProcessorAffinity=62", , Hide


AppsKey::Send {Media_Play_Pause}
AppsKey & R::Reload
AppsKey & S::Suspend

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
; Open emoji panel when double clicking capslock
~CapsLock::
	if (DoubleTap("~CapsLock", 230))
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
	} else{
		Active := 1
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
		SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
	}
	else
	{
		Screen_X := (A_ScreenWidth - 15)
		Screen_Y := (A_ScreenHeight / 2)
		;MsgBox, %Screen_X%x%Screen_Y%
		MouseMove, %Screen_X%, %Screen_Y%
		Click Left
		SoundSet, 85, Master, VOLUME, 6 ; Setting Mic's volume to 85
	}	
return

DoubleTap(Key, MaxTime)
{
	return (A_PriorHotKey == Key AND A_TimeSincePriorHotkey < MaxTime  AND A_TimeSincePriorHotkey > 100) == 1
}

#If (GetKeyState("CapsLock", "P"))
	Active := 1
	
	MsgBox Active
	
	; arrow keys
	i::up
	j::left
	k::down
	l::right
	
	; jump keys
	h::Send, ^{left}
	`;::Send, ^{right}
	
	;h::Send, +^{Left}
	;`;::Send, +^{Right}

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
	
	; Browser controls
	a::Send ^+{Tab}
	d::Send ^{Tab}
	s::Send !{left}
	w::Send !{right}
	q::Send, ^w
	r::Send, ^{R}
	t::Send, ^t
	e::Send, ^+{t}
	
	/*
	/::
		SendInput, ^{a}^{c}^{t}
		Sleep 100
		SendInput, ^{v}{Enter}
	return
	*/
	
	/::
		Send, ^c
		Sleep 50
		Run, https://www.google.com/search?q=%clipboard%
	Return
	
	Backspace::^Backspace
	
	; Select mode
	SPACE::dummy=0
	SPACE & i::+up
	SPACE & j::+left
	SPACE & k::+down
	SPACE & l::+right
	SPACE & h::Send, +^{Left}
	SPACE & `;::Send, +^{Right}
	SPACE & o::Send, +{home}
	SPACE & m::Send, +{end}
#If

; Enter::MsgBox % GetKeyState("CapsLock", "P") . Active

CapsLock up::
	send {Shift up}{Ctrl up}{Alt up}{i up}{j up}{k up}{l up}{SPACE up}
	Active := 0
return