#SingleInstance Force

Last_Move := A_TickCount
State := True
HideMouseAfterSeconds := 10

Loop
{
	MouseGetPos, Mouse_X, Mouse_Y
	If(Mouse_X != Last_X || Mouse_Y != Last_Y)
	{
		If(State == False)
			RestoreCursor()
		State := True
		Last_Move := A_TickCount
	}
	If(A_TickCount > Last_Move + (HideMouseAfterSeconds * 1000) && State == True) ;Change the 10000 to the desired time...
	{
		BlankCursor()
		State := False
	}
	Last_X := Mouse_X, Last_Y := Mouse_Y
}


RestoreCursor() {
	;Screen_X := (A_ScreenWidth / 2)
	;Screen_Y := (A_ScreenHeight / 2)
	;MsgBox, %Screen_X%x%Screen_Y%
	;MouseMove, %Screen_X%, %Screen_Y%
	
	SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0 )
}

BlankCursor(c="") {
	If c =
		c = 650,512,515,649,651,513,648,646,643,645,642,644,516,514
		Loop, parse, c, `,
	{
;=== next two lines create a blank cursor in memory without the need for a file:  ======
		VarSetCapacity(a,128,0xFF),VarSetCapacity(x,128,0)
		h := DllCall("CreateCursor",Uint,0,Int,0,Int,0,Int,32,Int,32,Uint,&a,Uint,&x)
;=======================================================================================
		DllCall("SetSystemCursor",Uint,h,Int,"32" . A_LoopField)
	}
	Return
}