#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#WinActivateForce
#Persistent
ListLines Off
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
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
SetTitleMatchMode, 2


+WheelUp:: ; Shift + Wheel Up
    monitor := GetMonitor()

    If (monitor = 1) {
        SendInput {Shift Down}{Alt Down}{!} ; Send key combination
    } else if (monitor = 2) {
        SendInput {Shift Down}{Alt Down}{#} ; Send key combination
    }

    SendInput {Shift Up}{Alt Up}
Return

+WheelDown:: ; Shift + Wheel Down
    monitor := GetMonitor()

    If (monitor = 1) {
        SendInput {Shift Down}{Alt Down}{@} ; Send key combination
    } else if (monitor = 2) {
        SendInput {Shift Down}{Alt Down}{$} ; Send key combination
    }

    SendInput {Shift Up}{Alt Up}
Return

GetMonitor() ; we didn't actually need the "Monitor = 0"
{
	; get the mouse coordinates first
	Coordmode, Mouse, Screen	; use Screen, so we can compare the coords with the sysget information`
	MouseGetPos, Mx, My

	SysGet, MonitorCount, 80	; monitorcount, so we know how many monitors there are, and the number of loops we need to do
	Loop, %MonitorCount%
	{
		SysGet, mon%A_Index%, Monitor, %A_Index%	; "Monitor" will get the total desktop space of the monitor, including taskbars

		if ( Mx >= mon%A_Index%left ) && ( Mx < mon%A_Index%right ) && ( My >= mon%A_Index%top ) && ( My < mon%A_Index%bottom )
		{
			ActiveMon := A_Index
			break
		}
	}
	return ActiveMon
}