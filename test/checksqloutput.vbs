'-- Version 1.0 First release, Check isql output for Sybase error

Const ForReading = 1
Const ForWriting = 2

Dim fso, f1,sFilename,rc

rc = 0

'****************************
' Get first input parameters
'****************************

sFilename = ""
Set objArgs = WScript.Arguments
For I = 0 to objArgs.Count - 1
   sFilename = objArgs(I)
Next

'************************************
' Open the file and check for string
'************************************
Set fso = CreateObject("Scripting.FileSystemObject")

If (fso.FileExists(sFilename)) then
	Set f1 = fso.OpenTextFile(sFilename, ForReading)
	Do while Not f1.AtEndOfStream
		s = f1.ReadLine
   	If Instr(s,"Msg ") > 0 and Instr(s," Level ") > 0 and Instr(s," State ") > 0 Then
   		rc = 1	
   		Exit Do
   	End If  	
'   	If Instr(s,"(return status") > 0  Then
'			f1.Writeline ""
'  	End If  	
   	
   	
	Loop
	f1.Close
	Set fl = Nothing
  Else
	rc = 1	  	
End If	

Set fso = Nothing
Wscript.quit(rc)	

