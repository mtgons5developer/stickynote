
TraySetIcon("tray.ico")

#include <File.au3>
#include<WindowsConstants.au3>
#include<GUIConstantsEx.au3>
#include<TrayConstants.au3>

Opt("MouseCoordMode",0)

Global $S_TITLE, $S_NOTE, $lastline, $title

Local $ZZ

If Not _FileReadToArray('Title.ini', $ZZ) Then
	MsgBox(0,'Title.ini',"File Not Found", 1)
EndIf

Local $list

For $x = 2 To $ZZ[0]
	$list = $list & $ZZ[$x] & @CRLF
Next

$lastline = $x - 1
;MsgBox(0,'',$lastline)
;Exit
$title = 'S-Note'

;GUICreate($ititle,200,200,-1,-1,BitOr($WS_POPUP,$WS_BORDER),$WS_EX_TOOLWINDOW)
GUICreate($title,200,165,0,0,BitOr($WS_POPUP,$WS_BORDER),$WS_EX_TOOLWINDOW)
GUICtrlCreatePic("bkg.bmp",0,0,200,200)
GUICtrlSetState(-1, $GUI_DISABLE)
$title_label = GUICtrlCreateLabel('',0,5,150,15,0x01)
GUICtrlSetFont(-1,-1,-1,-1,"Fixedsys")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetState(-1,$GUI_HIDE)
$memo_label = GUICtrlCreateLabel('',3,30,180,160)
GUICtrlSetFont(-1,-1,-1,-1,"Verdana")
GUICtrlSetBkColor(-1,0xEFE4B0)
GUICtrlSetState(-1,$GUI_HIDE)
GUISetState(@SW_SHOW)

$i = 300
If $lastline > 1 Then
	If StringLen($list) > 254 Then $i = 400
	If StringLen($list) > 300 Then $i = 500

	$input = InputBox("Load Stick-E-Notes: " & $lastline,"Choose which S-Note you want to load by typing the number:" & _
	@CRLF & @CRLF & $list & @CRLF & "Cancel or leave it empty for a new S-Note." & @CRLF & @CRLF & "To move your S-Note across the desktop use your mouse 'right click' then drag.","", "", -1, $i)

	If $input = "" Then
		$title = IniRead("Title.ini", "TITLE", $input, "")
		$memo = ""
		$memo = IniRead("Note.ini", "TITLE", $title, "")
	Else
		$title = IniRead("Title.ini", "TITLE", $input, "")
		$memo = ""
		$memo = IniRead("Note.ini", "TITLE", $title, "")

		GUICtrlSetData($title_label, $title)
		GUICtrlSetState($title_label, $GUI_SHOW)
		If StringInStr($memo, " /n ") Then $memo = StringReplace($memo, " /n ", @lf)
		GUICtrlSetData($memo_label, $memo)
		GUICtrlSetState($memo_label, $GUI_SHOW)
		WinSetTitle("S-Note", "", $title)
	EndIf

EndIf

$1 = IniRead("Pos.ini", "POSITION", $title, "0,0")
$pos = StringSplit($1, ",")
WinMove($title, "", $pos[1], $pos[2])
;MsgBox(0,$title, $pos[1] & " " & $pos[2])
Sleep(100)
Local $hWnd = WinGetHandle($title)
WinSetOnTop($hWnd, "", $WINDOWS_ONTOP)



While 1
   $msg = GUIGetMsg()
   Select
   Case $msg = $GUI_EVENT_PRIMARYUP
	  $loc = MouseGetPos(1)
	  $loc2 = MouseGetPos(0)

	  If $loc < 24 then
		 If $loc2 > 173 then
			$a = 6
			Local $aPos = WinGetPos($title)
			IniWrite("Pos.ini","POSITION", $title, $aPos[0] & "," & $aPos[1])
			Exit
		 EndIf

		If $loc2 < 26 Then
			Run("S-Note.exe")
			ContinueLoop
		EndIf

		If $title <> "" And $loc2 > 14 And $loc2 < 173 Then
			If StringLen($title) > 18 then $title = StringTrimRight($title,StringLen($title)-18)
			GUICtrlSetData($title_label,$title)
			GUICtrlSetState($title_label,$GUI_SHOW)
			$S_TITLE = GUICtrlRead($title_label)
			_INIWRITE_T()
		Else
			If $loc2 > 14 And $loc2 < 173 Then $title=InputBox("S-Note","Add S-Note Title:","") ;New Title
			If $loc2 > 14 And $loc2 < 173 Then
				If StringLen($title) > 18 then $title = StringTrimRight($title,StringLen($title)-18)
				GUICtrlSetData($title_label,$title)
				GUICtrlSetState($title_label, $GUI_SHOW)
				$S_TITLE = GUICtrlRead($title_label)
				If $title <> "" Then _INIWRITE_T()
			EndIf
		EndIf

	EndIf

	If $loc > 24 Then
		 $memo = InputBox("S-Note","Add S-Note comment:" & @CRLF & @CRLF & "'/n' for Line Break/Next line." & _
		 @CRLF & "Ex. Name: Ernesto Jr. /n Last Name: Almeda" & _
		 @CRLF & @CRLF & "Name: Ernesto Jr." & @CRLF & "Last name: Almeda", StringReplace(GUICtrlRead($memo_label),@lf, " /n "), '', -1, 220)
		 If not @error Then
			If StringInStr($memo, " /n ") Then $memo = StringReplace($memo, " /n ", @lf)

			GUICtrlSetData($memo_label, $memo)
			$S_NOTE = GUICtrlRead($memo_label)
			GUICtrlSetState($memo_label, $GUI_SHOW)
			$S_NOTE = StringReplace($S_NOTE, @lf, " /n ")
			_INIWRITE_N()
		 EndIf
	EndIf

	  Case $msg = $GUI_EVENT_SECONDARYDOWN
		 $mprimcords = mousegetpos()
		 Opt("MouseCoordMode",1)

		 Do
			$msg = guigetmsg()
			$cords = MouseGetPos()
			WinMove('',"",$cords[0]-$mprimcords[0],$cords[1]-$mprimcords[1])
		Until $msg = $GUI_EVENT_SECONDARYUP
		Opt("MouseCoordMode",2)
	EndSelect

   $tmsg = TrayGetMsg()
   If $tmsg = $TRAY_EVENT_PRIMARYDOWN then
	  WinActivate($title)
   Endif
WEnd


Func _INIWRITE_T()

Local $ZZ

If Not _FileReadToArray('Title.ini', $ZZ) Then
	MsgBox(0,'Title.ini',"File Not Found", 1)
EndIf

$i = 0

For $x = 2 To $ZZ[0]
	$1 = StringInStr($ZZ[$x], "=")
	$2 = StringTrimLeft($ZZ[$x], $1)
	If $2 = $S_TITLE Then
		TrayTip("Hint", "To create/add a new S-Note. Click on the upper left corner. Leave it empty and Click OK/Cancel.", 5)
		$i = 1
		ExitLoop
	Else
		$i = 0
	EndIf

Next

If $i = 0 Then
	IniWrite("Title.ini", "TITLE", $lastline, $S_TITLE)
EndIf

EndFunc

Func _INIWRITE_N()


If $title = "" Then
	TrayTip("Error", "You must add a S-Note title first before you can add a comment.", 5)
Else
	IniWrite("Note.ini", "TITLE", $title, $S_NOTE)
EndIf

EndFunc



