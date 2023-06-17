#SingleInstance force
#KeyHistory 0
ListLines Off
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
CoordMode mouse, screen

LineWidth := 40
Transparency := 15

monitorX := 0
monitorW := 0
monitorH := 0

LastMousePosY := 0

firstInit := True

Mode := "full"

SysGet, MonitorCount, 80	; monitorcount, so we know how many monitors there are, and the number of loops we need to do

Loop, %MonitorCount%
{
    SysGet, mon%A_Index%, Monitor, %A_Index%	; "Monitor" will get the total desktop space of the monitor, including taskbars
}

Gui, +hwnd_hwnd
Gui -Caption +ToolWindow +AlwaysOnTop +LastFound
WinSet Transparent, %Transparency%
WinSet ExStyle, +0x20 ; set click through style

OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA

return

XButton1::Click,% GetKeyState("LButton")?"Up":"Down"

; Ctrl & XButton2:: ToggleMode()

XButton2::
  start:=A_TickCount
return

~Shift & WheelUp::LineWidth := Min(LineWidth+5, 80)
~Shift & WheelDown::LineWidth := Max(LineWidth-5, 17)

~Ctrl & WheelUp::
	Global Transparency
	Transparency := Min(Transparency+5, 35)
	WinSet Transparent, %Transparency%, % "ahk_id " _hwnd
Return
~Ctrl & WheelDown::
	Global Transparency
    Transparency := Max(Transparency-5, 5)
	WinSet Transparent, %Transparency%, % "ahk_id " _hwnd
Return

timer := 0

XButton2 up::
  end:=A_TickCount-start
  
  If (end >= 200 && timer > 0){
    ToggleColor()
  } else {
    SetTimer Draw, % (timer:= !timer) ? "4" : "-4"
  }
return

Receive_WM_COPYDATA(wParam, lParam)
{
    StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
    ; Show it with ToolTip vs. MsgBox so we can return in a timely fashion:
    ; MsgBox, , , %CopyOfData%, 0.5
    Gui Color, %CopyOfData%
    ; ToolTip %A_ScriptName%`nReceived the following string:`n%CopyOfData%
    return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

ToggleColor() {
    global color
    color := color = "000000" ? "FFFFFF" : "000000"
        Gui Color, %color%
    }

ToggleMode() {
    global Mode
Mode := Mode = "full" ? "always" : "full"
    Gui Cancel
}

Draw:
    If timer
    {
        ; Check if the active window is a web browser
        IfWinActive, ahk_exe vivaldi.exe ; adjust this to match the executable name of your web browser
        {
            Mode := "full" ; switch to full screen mode
        }
        else
        {
            Mode := "always" ; switch to always-on mode
        }
        
        If (Mode = "full")
        {
            ; Check if any windows are in full screen mode
            WinGet, Style, Style, A
            If (Style & 0x800000) { ; WS_EX_TOPMOST
                DrawReadingLine()
            } 
            else
                Gui Cancel
        }
        else {
            DrawReadingLine()
        }
    }
    else Gui Cancel
return

UpdateActiveMonitorBoundaries() ; we didn't actually need the "Monitor = 0"
{
	; get the mouse coordinates first
	MouseGetPos, Mx, My

    global MonitorCount
    global monitorX, monitorW, monitorH

	Loop, %MonitorCount%
	{
        if ( Mx >= mon%A_Index%left ) && ( Mx < mon%A_Index%right ) {
            monitorX := mon%A_Index%left
            monitorW := mon%A_Index%right - mon%A_Index%left
            monitorH := mon%A_Index%top + mon%A_Index%bottom
            Break
        }
	}
}

DrawReadingLine() {
    global LineWidth
    global monitorX, monitorW
    global firstInit

    UpdateActiveMonitorBoundaries()

    MouseGetPos, , mouseY

    mouseY -= Floor(0.5*LineWidth)

    Gui Show, x%monitorX% y%mouseY% w%monitorW% h%LineWidth% NA
}