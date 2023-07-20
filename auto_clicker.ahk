#NoEnv     
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#WinActivateForce
#Persistent
#SingleInstance Force
CoordMode, Mouse, Screen
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, -1
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetControlDelay, -1
SetWinDelay, -1
SetBatchLines, -1 
DllCall("Sleep","UInt",1)
GroupAdd All

curr := 0

cycle_first := 0
cycle_second := 0

status := [0,0,0,0]

point_width := 10
active_point_color := "Red"
inactive_point_color := "Gray"
double_click := False

Media_Play_Pause::
    curr := Mod(curr++, 2) + 1

    If (curr == 1) {
        TurnOn(cycle_first)
    } Else{
        TurnOn(cycle_second)
    }
    
    ToolTip,,,,
return

Media_Next::
    Loop, 4 {
        If (cycle_first == 4){
            cycle_first := 1
            Break
        }
        If (A_Index <= cycle_first){
            Continue
        } Else if (A_Index > cycle_first and r%A_Index% != null){
            cycle_first := A_Index
            Break
        }

        cycle_first := 1
    }

    ; cycle_first := Mod(cycle_first++, 4) + 1
    ToolTip, first: %cycle_first% second: %cycle_second% , 500, 500,

    RedrawAll()
return

Media_Prev::
    Loop, 4 {
        If (cycle_second == 4){
            cycle_second := 1
            Break
        }
        If (A_Index <= cycle_second){
            Continue
        } Else if (A_Index > cycle_second and r%A_Index% != null){
            cycle_second := A_Index
            Break
        }

        cycle_second := 1
    }

    ; cycle_second := Mod(cycle_second++, 4) + 1
    ToolTip, first: %cycle_first% second: %cycle_second% , 500, 500,

    RedrawAll()
return

^1::
^2::
^3::
^4::
    n := SubStr(A_ThisHotkey, 2)
    MouseGetPos, p%n%_x, p%n%_y ; Store mouse position

    If (r%n% != null){
        DestroyRect(r%n%)
    }
    r%n% := DrawRect(p%n%_x+1, p%n%_y, point_width+(n*4), point_width+(n*4), (cycle_first == n or cycle_second == n) ? active_point_color : inactive_point_color)
Return

Esc::
    Loop, 4 {
        If (r%A_Index% != null){
            DestroyRect(r%A_Index%)
        }
    }
Return

TurnOn(n){
    global status, double_click
    for i, element in status
    {
        If ((i != n And element == 1) or (i == n)){
            x := % p%i%_x
            y := % p%i%_y

            Click %x% %y%

            If (double_click){
                Sleep, 100
                Click %x% %y%
            }
            
            If !(i == n and element == 1)
                status[i] := Mod(++status[i], 2)
        }
    }
}

DrawRect(x, y, w, h, c) {
	static n := 0
    
	n++
    if (n > 4) {
        n := 1
    }

	Gui, %n%:-Caption +AlwaysOnTop +ToolWindow +E0x20
	Gui, %n%:Color, %c%
	Gui, %n%:Show, x%x% y%y% w%w% h%h%

	return n
}

DestroyRect(n) {
	Gui, %n%:Destroy
}

RedrawAll(){
    global cycle_first, cycle_second, point_width, active_point_color, inactive_point_color, r1, r2, r3, r4

    Loop, 4 {
        If (r%A_Index% != null){
            DestroyRect(r%A_Index%)
            r%A_Index% := DrawRect(p%A_Index%_x+1, p%A_Index%_y, point_width+(A_Index*4), point_width+(A_Index*4), (cycle_first == A_Index or cycle_second == A_Index) ? active_point_color : inactive_point_color)
        }
    }
}