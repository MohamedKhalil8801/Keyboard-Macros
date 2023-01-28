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
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
SetTitleMatchMode 2
DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ;setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE
Process, Priority,, High
SetKeyDelay, -1
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetControlDelay, -1
SetWinDelay, -1
SetBatchLines, -1
SetCapsLockState, AlwaysOff	 
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


#If (OneHanded == 1)
	Active := 1
	
	Space::Send {Down}

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
#If

#If (GetKeyState("CapsLock", "P"))
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
	
	 
	u::
		GetText(TempText)
		If NOT ERRORLEVEL
		   Menu Case, Show
	Return
#If

; Enter::MsgBox % GetKeyState("CapsLock", "P") . Active

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