#include mpgc.ahk
#include DrawFunctions.ahk
#SingleInstance force
#KeyHistory 0
ListLines Off
SetDefaultMouseSpeed, 0
SetMouseDelay, -1
CoordMode mouse, screen

LineWidth := 60

ScriptName := "reading_line.ahk"

firstInit := True

monitorX := 0
monitorW := 0
monitorH := 0
monitorY := 0

LastMonitorPos := 0

LastMousePosX := 0
LastMousePosY := 0

counter := 0

LastColor := 0

LastMessage := 0

PixelSampleColumns := 6
PixelSampleRows := 6

SysGet, MonitorCount, 80	; monitorcount, so we know how many monitors there are, and the number of loops we need to do

Loop, %MonitorCount%
{
    SysGet, mon%A_Index%, Monitor, %A_Index%	; "Monitor" will get the total desktop space of the monitor, including taskbars
}

; Gui -Caption +ToolWindow +AlwaysOnTop +LastFound
; WinSet Transparent, 25
; WinSet ExStyle, +0x20 ; set click through style

InitDynamicColor()

return

UpdateActiveMonitorBoundaries() ; we didn't actually need the "Monitor = 0"
{
	; get the mouse coordinates first
	MouseGetPos, Mx, My

    global MonitorCount
    global monitorX, monitorW, monitorH, monitorY

	Loop, %MonitorCount%
	{
        if ( Mx >= mon%A_Index%left ) && ( Mx < mon%A_Index%right ) {
            monitorX := mon%A_Index%left
            monitorY := mon%A_Index%top
            monitorW := mon%A_Index%right - mon%A_Index%left
            monitorH := mon%A_Index%top + mon%A_Index%bottom
            Break
        }
	}
}

InitDynamicColor() {
    UpdateActiveMonitorBoundaries()

    SetTimer UpdateColorIfNeeded, 33
}

UpdateColorIfNeeded() {
    global monitorX, monitorW, monitorH
    global LastMousePosX, LastMousePosY

    MouseGetPos, mouseX, mouseY

    If ((Abs(mouseY - LastMousePosY) >= 15) || (Abs(mouseX - LastMousePosX) >= 100)) {
        LastMousePosX := mouseX
        LastMousePosY := mouseY
        UpdateColor()
    }
}

UpdateColor() {
    global monitorX, monitorW, monitorH, monitorY
    global LastColor, LastMessage, LastMonitorPos
    global counter
    global firstInit
    global PixelSampleColumns, PixelSampleRows
    global LineWidth

    mainColors := {}

    MouseGetPos, mouseX, mouseY

    x := Floor((mouseX) - (0.5*(monitorW/4)))

    most_common_color := 0
    highest_count := 0

    counter++  

    UpdateActiveMonitorBoundaries()

    If (firstInit) {
        init_mpgc("", monitorX, monitorY, monitorW, monitorH)
        update_mpgc()
        LastMonitorPos := monitorX + monitorY
        firstInit := False
    }

    If (LastMonitorPos != monitorX + monitorY) {
        init_mpgc("", monitorX, monitorY, monitorW, monitorH)
        update_mpgc()
        LastMonitorPos := monitorX + monitorY
        counter := 0
    }

    If (counter >= 15) {
        update_mpgc()
        counter := 0
    }

    points := []

    Loop
    {
        Loop, %PixelSampleRows%
        {
            y := Floor(mouseY - (0.5*LineWidth) + (A_Index * (LineWidth/PixelSampleRows)))

            y := Min(y, monitorY + monitorH - 5)
            y := Max(y, 0)

            x := Min(x, monitorX + monitorW)
            x := Max(x, 0)

            str := % x . " " . y
            points.Push(str)

            color := mpgc(x, y)
            
            If (mainColors.HasKey(color)) {
                mainColors[color]++
                If (highest_count < mainColors[color]) {
                    highest_count := mainColors[color]
                    most_common_color := color
                }
            }
            Else
                mainColors[color] := 1

            ; early_stopping := (PixelSampleColumns * PixelSampleRows * 0.5)
            
            ; FileAppend % A_NowUTC ": " . highest_count . " " . early_stopping . "`n", *
            
            If (highest_count >= (PixelSampleColumns * PixelSampleRows * 0.6))
                Break 2
        }

        If (x >= (mouseX + (0.5*(monitorW/4))))
            Break
        
        x += Floor(((monitorW/4))/(PixelSampleColumns-1))

        FileAppend % A_NowUTC ": " . x . " " . y . "`n", *
    }

    ; init_draw(16) 
    ; for index, element in points {
    ;     out := StrSplit(element, " ", "")
    ;     draw_dot(out[1], out[2], 2, 1)
    ; }

    If (LastColor != most_common_color) {
        LastColor := most_common_color

        most_common_color_str := "0x" . LTrim(Format("{:p}", most_common_color), "0")

        R := GetRed(most_common_color_str)
        G := GetGreen(most_common_color_str)
        B := GetBlue(most_common_color_str)

        luminance := 0.2126*R + 0.7152*G + 0.0722*B

        ; FileAppend % A_NowUTC ": " . luminance . "`n", *

        If (luminance < 128 && LastMessage != "FFFFFF") { ; Dark
            LastMessage := "FFFFFF"
            SendStr(LastMessage)
        } else If(luminance >= 128 && LastMessage != "000000") {
            LastMessage := "000000"
            SendStr(LastMessage)
        }
    }
}

; Helper functions to extract the red, green, and blue components of a color value
GetRed(color) {
    return color & 0xFF
}

GetGreen(color) {
    return (color >> 8) & 0xFF
}

GetBlue(color) {
    return (color >> 16) & 0xFF
}

SendStr(StringToSend) {
    global ScriptName

    TargetScriptTitle := % ScriptName . " ahk_class AutoHotkey"
    result := Send_WM_COPYDATA(StringToSend, TargetScriptTitle)
    ; if (result = "FAIL")
    ;     MsgBox SendMessage failed. Does the following WinTitle exist?:`n%TargetScriptTitle%
    ; else if (result = 0)
    ;     MsgBox Message sent but the target window responded with 0, which may mean it ignored it.
    return
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)  ; ByRef saves a little memory in this case.
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime := 4000  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    ; Must use SendMessage not PostMessage.
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%,,,, %TimeOutTime% ; 0x4a is WM_COPYDATA.
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
    return ErrorLevel  ; Return SendMessage's reply back to our caller.
}