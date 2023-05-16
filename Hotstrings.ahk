; run script as admin (reload if not as admin) 

; if not A_IsAdmin
; {
; 	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
; 	ExitApp
; }

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
; #KeyHistory 0
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
Process, Priority,, High
SetKeyDelay, -1
SetControlDelay, -1
SetBatchLines, -1

navigation_master_char := ";"
navigation_language_code := "0x4090409" ; 0x4090409 is US English langauge code
log := True

last_hotstring := ""
last_substr := ""
substr_occurrence := 1
is_block := False


RegExHotstrings(k, a = "", Options:="") {
    static z, m = "~$", m_ = "*~$", s, t, w = 2000, sd, d = "Left,Right,Up,Down,Home,End,RButton,LButton", f = "!,+,^,#", f_="{,}"
    global $
	global navigation_master_char, last_hotstring, navigation_language_code

    If z = ; init
    {
        RegRead, sd, HKCU, Control Panel\International, sDecimal
        Loop, 94
        {
            c := Chr(A_Index + 32)
            If A_Index between 33 and 58
                Hotkey, %m_%%c%, __hs
            else If A_Index not between 65 and 90
                Hotkey, %m%%c%, __hs
        }
        e = 0,1,2,3,4,5,6,7,8,9,Dot,Div,Mult,Add,Sub,Enter
        Loop, Parse, e, `,
            Hotkey, %m%Numpad%A_LoopField%, __hs
        e = BS,Shift,Space,Enter,Return,Tab,%d%
        Loop, Parse, e, `,
            Hotkey, %m%%A_LoopField%, __hs
        z = 1
    }
    If (a == "" and k == "") ; poll
    {
        q:=RegExReplace(A_ThisHotkey, "\*\~\$(.*)", "$1")
        q:=RegExReplace(q, "\~\$(.*)", "$1")
        If q = BS
        {
            If (SubStr(s, 0) != "}")
                StringTrimRight, s, s, 1
        }
        Else If q in %d%
            s =
        Else
        {
			lang := GetKeyboardLayout()
            If (lang != navigation_language_code) ; language is not English
                Return
            Else If GetKeyState("CapsLock", "P")
                Return
            Else If q = Shift
            return
            Else If q = Space
                q := " "
            Else If q = Tab
                q := "`t"
            Else If q in Enter,Return,NumpadEnter
                q := "`n"
            Else If (RegExMatch(q, "Numpad(.+)", n))
            {
                q := n1 == "Div" ? "/" : n1 == "Mult" ? "*" : n1 == "Add" ? "+" : n1 == "Sub" ? "-" : n1 == "Dot" ? sd : ""
                If n1 is digit
                    q = %n1%
            }
            Else If (GetKeyState("Shift") ^ !GetKeyState("CapsLock", "T"))
                StringLower, q, q
            s .= q
        }
        Loop, Parse, t, `n ; check
        {
            StringSplit, x, A_LoopField, `r
            If (RegExMatch(s, x1 . "$", $)) ; match
            {
				; temp := RegExReplace(s, "^.*?(?=/)")

				Needle := "[^" . navigation_master_char . "]+$"       ;Match all characters that are not 'navigation_master_char' starting from the end of the haystack
				RegExMatch(s, Needle, temp)

                StringLen, l, $
                StringTrimRight, s, s, l
                if !(x3~="i)\bNB\b")        ; if No Backspce "NB"
                    SendInput, {BS %l%}
                If (IsLabel(x2)) {
					Log("__________" . lang)
					last_hotstring := temp
                    Gosub, %x2%
				}
                Else
                {
                    Transform, x0, Deref, %x2%
                    Loop, Parse, f_, `,
                        StringReplace, x0, x0, %A_LoopField%, ¥%A_LoopField%¥, All
                    Loop, Parse, f_, `,
                        StringReplace, x0, x0, ¥%A_LoopField%¥, {%A_LoopField%}, All
                    Loop, Parse, f, `,
                        StringReplace, x0, x0, %A_LoopField%, {%A_LoopField%}, All
                    SendInput, %x0%
                }
            }
        }
         If (StrLen(s) > w)
            StringTrimLeft, s, s, w ; 2
    }
    Else ; assert
    {
        StringReplace, k, k, `n, \n, All ; normalize
        StringReplace, k, k, `r, \r, All
        Loop, Parse, t, `n
        {
            l = %A_LoopField%
            If (SubStr(l, 1, InStr(l, "`r") - 1) == k)
                StringReplace, t, t, `n%l%
        }
        If a !=
            t = %t%`n%k%`r%a%`r%Options%
    }
    
    Return
    __hs: ; event
    RegExHotstrings("", "", Options)
    Return
}

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

CountOccurrences(sentence, word) {
	StringReplace, sentence, sentence, %word%, %word%, UseErrorLevel
	return ErrorLevel
}

GetLine() {
	SaveClipboard()

	Send,{Home}{ShiftDown}{End}{ShiftUp} ; Select Line

    ; Copy Line
    Clipboard=
    Send, ^c
    ClipWait, 5
    line := Clipboard

	Send, {Home} ; Go back to the beginning of the sentence

	RestoreClipboard()

	Return line
}

SelectBlock(start, end) {
	global substr_occurrence, is_block

	; MarkCursorPosition()

	line := GetLine()
	start_count := CountOccurrences(line, start)
	end_count := CountOccurrences(line, end)

	; Check if start and end are balanced
	If (start_count = end_count) {
		; Get the position of the area inside the block
		start_pos := GoToSubstring(start)
		end_pos := GoToSubstring(end) - start_pos - 1

		; Get to the beginning of the block
		GoToPosition(start_pos)

		; Get to the end of the block, while selecting everything in between 
		Loop, %end_pos% {
            Send, {ShiftDown}{Right}{ShiftUp}
        }

		is_block := True
	} Else {
		; ResetCursorPosition()
	}
}

GoToSubstring(substr) {
    global last_substr, substr_occurrence, is_block

    If (last_substr != substr){
        last_substr := substr
        substr_occurrence := 1
    }

	; MarkCursorPosition()

    line := GetLine()
	occurrences := CountOccurrences(line, substr)

	; if this is the first occurrence, go the last occurrence (circular navigation)
	If (substr_occurrence < 1) {
		If (GetKeyState("Space", "P")) {
			Send, {Home}{Up}
			line := GetLine()
			occurrences := CountOccurrences(line, substr)
		} 

		If is_block
			substr_occurrence := occurrences - 1
		Else
			substr_occurrence := occurrences
		
	}

	; if this is the last occurrence, go the first occurrence (circular navigation)
    If (substr_occurrence > occurrences) {
		If (GetKeyState("Space", "P")) {
			Send, {Home}{Down}
			line := GetLine()
			occurrences := CountOccurrences(line, substr)
		}

		substr_occurrence := 1
	}  

    start_pos := InStr(line, substr, False, 1, substr_occurrence)

    ; Check if the substring exists in the current line
    If (start_pos) {
        end_pos := start_pos + StrLen(substr) - 1
        
        ; Go to end position (end of substring)
        Loop, %end_pos% {
            Send, {Right}
        }

        substr_occurrence += 1
    } else {
        ; substring not found
        substr_occurrence := 1
		; ResetCursorPosition()
    }

	Return start_pos
}

clipSave := ""
SaveClipboard() {
    global clipSave
    clipSave := ClipboardAll
}

RestoreClipboard() {
    global clipSave
    Clipboard := clipSave	;restore clipboard contents
	clipSave=
}

; navigation_master_char . "([A-Za-z0-9,.=:#%""''\(\)<>\[\]\{\}])+( )", "FindInLine"
RegExHotstrings(navigation_master_char . "([^\s])+( )", "FindInLine") 

FindInLine:
	global from_start, reverse, log

	; keys := StrReplace(RTrim(last_hotstring, " "), "/", "")
	keys := Trim(last_hotstring)

	if (keys = "") {
		Return
	}
	
    If (log)
	    Log(keys)

	switch keys
	{
	case """""":
		SelectBlock("""", """")
	case "''":
		SelectBlock("'", "'")
	case "(", ")", "()":
		SelectBlock("(", ")")
	case "<", ">", "<>":
		SelectBlock("<", ">")
	case "[", "]", "[]":
		SelectBlock("[", "]")
	case "{", "}", "{}":
		SelectBlock("{", "}")
	case "%":
		SelectBlock("%", "%")
	case "=", ":", "#":
		is_block := False
		If (GoToSubstring(keys))
			Send, {ShiftDown}{End}{ShiftUp}
	default:
		is_block := False
		GoToSubstring(keys)
	}
Return

GetCursorPosition() {
	line := GetLine()
	CaretPosition := InStr(line, "‎")
	GoToPosition(CaretPosition)
	Send, {Backspace}

	Return CaretPosition - 1
}

MarkCursorPosition() {
	Send, {U+200E}
}

ResetCursorPosition() {
	global last_cursor_position
	GoToPosition(GetCursorPosition())
}

GoToPosition(pos, from_beginning := True) {
	If (from_beginning)
		Send, {Home}
	Loop, %pos% {
		Send, {Right}
	}
}

Log(message) {
	FileAppend, %message%`n, output.log
}

; Hotstrings
:C*:/datetime1::
    FormatDateTime("dddd, MMMM dd, yyyy, HH:mm")
Return
::/datetime::
    FormatDateTime("dddd, MMMM dd, yyyy hh:mm tt")
Return
:C*:/time1::
    FormatDateTime("HH:mm")
Return
::/time::
    FormatDateTime("hh:mm tt")
Return
::/date::
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
::/r::192.168.1.1
:C*:/r1::192.168.0.1
::/m::zchggf11@hotmail.com
:C*:/m1::mohamedkhalil8801@gmail.com

::/ip:: 
	GetIP("http://www.netikus.net/show_ip.html")
Return

:C*:/ip1:: 
	send % A_IPAddress2
Return

:C*:---::
	Send,----------
return
:C*:___::__________
:C*:***::**********


:C*:/text::Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

; Example test case:
; xvar = "hello World", ((hello again), 'fw' <HTML> %var% #123456 [squar] { scurly } 1, 2, 3 xayz
; "test text 
; is 
; very long"

#If GetKeyState("CapsLock", "P")
	.::
		Goto, FindInLine
	return

	,::
		If (is_block)
			substr_occurrence -= 4
		Else
			substr_occurrence -= 2

		Goto, FindInLine
	return
#If

GetKeyboardLayout() {
	ControlGetFocus Focused, A
	ControlGet CtrlID, Hwnd,, % Focused, A
	ThreadID := DllCall("GetWindowThreadProcessId", "Ptr", CtrlID, "Ptr", 0)
	InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "Ptr")
	Return % Format("0x{:X}",InputLocaleID)
}