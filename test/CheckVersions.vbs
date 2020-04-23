
'*******************************************************************************
' Variables Declaration section
'*******************************************************************************

	Const ForReading = 1
	Const ForWriting = 2
	Const adOpenStatic = 3
	Const adLockOptimistic = 3
	Const adUseClient = 3
	Const adCmdText = 1
	Const adExecuteNoRecords = 128
		
	Dim sqlStr 
	Dim fso1, f1
	Dim fso2, f2
	Dim fso3, f3
	Dim fso4, f4
	Dim rc
	Dim ServerName
	Dim Filename
	Dim adConnectString

	Public Cnxn,CmdSql,SQL_Conn,nErr

	rc = 0

'****************************
' Create Log File
'****************************
	Set fso4 = CreateObject("Scripting.FileSystemObject")
	
	Set f4 = fso4.CreateTextFile("CheckVersions.log", TRUE)

'****************************
' Get input parameters
'****************************

	Filename = ""
	strSQL = ""
	Set objArgs = WScript.Arguments
	
	ServerName = UCase(objArgs(0))
	FileName = objArgs(1)
	
'***********************************************
' Read ini file to search for server properties
'***********************************************
	Set oShell = CreateObject( "WScript.Shell" )
	IniFile=oShell.ExpandEnvironmentStrings("%SYBASE%")
	IniFile = IniFile & "\ini\sql.ini"
	Set oShell = Nothing

	Set fso2 = CreateObject("Scripting.FileSystemObject")
	
	If (fso2.FileExists(IniFile)) then
		Set f2 = fso2.OpenTextFile(IniFile, ForReading)
		Do while Not f2.AtEndOfStream
			s = f2.ReadLine
			If Instr(s,"[" & ServerName & "]") > 0  Then
				s = f2.ReadLine
				pos = Instr(s,",")
				s = Mid(s,pos+1,Len(s)-pos)
				pos = Instr(s,",")
				hostname = Mid(s,1,pos-1)
				PortNumber = Mid(s,pos+1,Len(s)-pos)
				Exit Do
			End if
		Loop

		f2.Close
		Set f2 = Nothing
		Set fso2 = Nothing
	Else
		f4.writeline ("			Ini file " & IniFile & " not found")
		rc = 1	
		Set fso2 = Nothing  	
		Wscript.quit(rc)	
	End If	
	
	adConnectString = "Provider=Sybase.ASEOLEDBProvider.2;Initial Catalog=" & DatabaseName & ";User ID=sa;Persist Security Info=False;Server Name=" & HostName & ";Server Port Address=" & PortNumber
	
	On Error Resume Next
		
'***********************************************
' Create Connexion On sybase server
'***********************************************
	Set Cnxn = CreateObject("ADODB.Connection")
	Cnxn.Open adConnectString
 	If Err.Number <> 0 Then 
		smsg = CStr(Err.number) & " " & Err.Description 
		f4.writeline ("		" & smsg)

		rc = 1	  	
		Wscript.quit(rc)	
	End if	
						
'**********************************************
' Open the dependences file and check Versions
'**********************************************
	Set fso1 = CreateObject("Scripting.FileSystemObject")

	Switch_Dont_Read = 0	
	If (fso1.FileExists(Filename)) then
		Set f1 = fso1.OpenTextFile(Filename, ForReading)
		Do while Not f1.AtEndOfStream
			If Switch_Dont_Read = 0 Then
				s = f1.ReadLine
			Else
				Switch_Dont_Read = 0	
			End If
			
			If Mid(s,1,1) <> " " and Len(s) <> 0 Then
		   		If Instr(s,"[") = 1 Then
		   			EndOFContext = Instr(s,"]")
		   			s = Mid(s,2,EndOfContext-2)
		   			If InStr(s,"Scripts") > 0 Then
		   				Call Scripts()
		   			ElseIf s = "Stored Procedures" Then
		   				Call Stored_Procedures()
		   			Else
						f4.writeline ("		Invalid context [" & s & "]")
						rc = 1	
		   			End If
			   	End If  	
			End If
	   	Loop
	
		f1.Close
		Set fl = Nothing
	Else
		f4.writeline ("		Dependences file " & Filename & " does not exist")
		rc = 1	  	
	End If	
	
	If rc = 0 Then
		f4.writeline ("	Version checkup succeeded")
	Else
		f4.writeline ("	Error(s) occured during Version checkup, please check with software provider")
	End If
		
	f4.Close
	Set f4 = Nothing
	
	Set fso2 = Nothing
	Set Cnxn = Nothing
	Wscript.quit(rc)	
	
'************************************
' Loop on Scripts
'************************************
Sub Scripts()	
	Do while Not f1.AtEndOfStream
		s = f1.ReadLine
		If InStr(s,"[") > 0 Then	' this is not a SQL Script anymore
			Switch_Dont_Read = 1
			Exit Do
		End If
		
		If Mid(s,1,1) <> " " and Len(s) <> 0 and s <> "	" Then   'third if is a tab
			s = Mid(s,2,Len(s)-1)
			pos = InStr(s,"	")	' (it's a tab) we are looking for the tab between Version and ObjectName
			Version = Mid(s,1,pos-1)
			ObjectName = Mid(s,pos+1,Len(s)-pos)
			Call Check_Script(Objectname,Version)
		End If
   	Loop
End Sub

'************************************
' Loop on Stored Procedures
'************************************
Sub Stored_Procedures()	
	Do while Not f1.AtEndOfStream
		s = f1.ReadLine
		If InStr(s,"[") > 0 Then	' this is not a Stored Procedure anymore
			Switch_Dont_Read = 1
			Exit Do
		End If
		
		If Mid(s,1,1) <> " " and Len(s) <> 0 and s <> "	" Then   'third if is a tab
			s = Mid(s,2,Len(s)-1)
			pos = InStr(s,"	")	' (it's a tab) we are looking for the tab between Version and ObjectName
			Version = Mid(s,1,pos-1)
			ObjectName = Mid(s,pos+1,Len(s)-pos)
			Call Check_Stored_Procedure(Objectname,Version)
		End If
   	Loop
End Sub

Sub Check_Script(lFilename,lVersion)
'************************************
' Check Script Version
'************************************
	f4.writeline ("		Processing '" & lFileName & "' '" & lVersion & "'")

	Set fso3 = CreateObject("Scripting.FileSystemObject")

	If (fso3.FileExists("..\" & lFilename)) then
		Set f3 = fso3.OpenTextFile("..\" & lFilename, ForReading)
		Do while Not f3.AtEndOfStream
			s = f3.ReadLine
			pos = InStr(s,"-- Version ")
			If pos = 0 Then
				f4.writeline ("			Invalid first line, '-- Version X.X' not mentioned")
				rc = 1
			Else
				s = Mid(s,pos+11,Len(s)-pos+11-1)
				pos = InStr(s," ")	' (it's a space) we are looking for the space between the keyword Version and the Version itself
				FileVersion = "V" & Mid(s,1,pos-1)
	
				If FileVersion <> lVersion Then
					f4.writeline ("			Expected version " & lVersion & " does not match the file version " & FileVersion)
					rc = 1
'				Else
'					f4.writeline ("			Versions " & FileVersion & " match ")
				End If
			End If
			Exit Do
	   	Loop
	
		f3.Close
		Set f3 = Nothing
	Else
		f4.writeline ("		File " & lFileName & " does not exist")
		rc = 1	  	
	End If	
	
End Sub
	
Sub Check_Stored_Procedure(lObjectname,lVersion)
'************************************
' Check Stored Procedure Version
'************************************
	f4.writeline ("		Processing '" & lObjectName & "' '" & lVersion & "'")

	strSQL = "set rowcount 1 "

	On Error Resume Next

	Cnxn.execute strSQL
 	If Err.Number <> 0 Then 
		f4.writeline ("				" & CStr(Err.number))
		f4.writeline ("				" & Err.Description)
		Err.Number = 0
		rc = 1
	Else
		
		strSQL = "select Version=substring(text,charindex('-- Version ',text)+11,250) from sybsystemprocs..syscomments where id = object_id('sybsystemprocs.." & lObjectname & "') order by colid"
		
		Set RecSet = CreateObject("ADODB.Recordset")
	
		on error resume next
		RecSet.Open strSQL , Cnxn, adOpenStatic, adLockOptimistic	
	 	If Err.Number <> 0 Then 
			smsg = CStr(Err.number) & " " & Err.Description 
			f4.writeline ("		" & smsg)
			Err.Number = 0
			rc = 1
		Else
					
			Switch_Proc_Not_Found = 1
		
			Do while Not RecSet.Eof	
		
				SrvVersion = RecSet("Version")

				SrvVersion = "V" & Mid(SrvVersion,1,InStr(SrvVersion," ")-1)

				Switch_Proc_Not_Found = 0
		
				If SrvVersion <> lVersion Then
					f4.writeline ("			Expected version " & lVersion & " does not match the database version " & SrvVersion)
					rc = 1
'				Else
'					f4.writeline ("			Versions " & FileVersion & " match ")
				End If
				Switch_First_Row = 0
		
				RecSet.Movenext
			Loop
		
			If Switch_Proc_Not_Found = 1 Then
				f4.writeline ("			Stored Procedure not found")
				rc = 1
			End If
			
			Set RecSet = Nothing	
		End if	
	End if	

End Sub
	

	
