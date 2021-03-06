@@ECHO OFF


IF %1X == X GOTO ERREURPARAM
IF %2X == X GOTO ERREURPARAM
IF %3X == X GOTO ERREURPARAM
IF %4X == X GOTO ERREURPARAM
IF %5X == X GOTO ERREURPARAM
IF %6X == X GOTO ERREURPARAM
IF %7X == X GOTO ERREURPARAM

CLS

REM Check for the working folder
IF NOT EXIST  .\%3\.  MD .\%3
CD .\%3

IF EXIST %3_CONVERT_SUCCEED.LOG DEL %3_CONVERT_SUCCEED.LOG
IF EXIST %3_CONVERT_ERROR.LOG DEL %3_CONVERT_ERROR.LOG
IF EXIST *.TXT DEL *.TXT

ECHO *********************************************************************** >> %3_CONVERT_SUCCEED.LOG
time/t									     >> %3_CONVERT_SUCCEED.LOG
date/t									     >> %3_CONVERT_SUCCEED.LOG
ECHO CONVERT_2_SQLSERVER			    			     >> %3_CONVERT_SUCCEED.LOG
ECHO --------------------					     	     >> %3_CONVERT_SUCCEED.LOG
ECHO 	Description : Export BRIO datamodel and RLA Data 		     >> %3_CONVERT_SUCCEED.LOG
ECHO 	-----------   in order to load them in MSSQL 	 		     >> %3_CONVERT_SUCCEED.LOG
ECHO 		      (This program is based on EXPORT_BRIOPLUS)     	     >> %3_CONVERT_SUCCEED.LOG
ECHO 						 		     	     >> %3_CONVERT_SUCCEED.LOG
ECHO 	Versions    : 				 		     	     >> %3_CONVERT_SUCCEED.LOG
ECHO 	-----------				 		     	     >> %3_CONVERT_SUCCEED.LOG
ECHO 			28 Feb 2008 - V1.0 First Release	      	     >> %3_CONVERT_SUCCEED.LOG
ECHO                    16 Jul 2008 - V2.0 Remove CLUSTERED in CONSTRAINT    >> %3_CONVERT_SUCCEED.LOG
ECHO                                       Limit text size to 1 if NO_TEXT   >> %3_CONVERT_SUCCEED.LOG
ECHO                    10 Sep 2008 - V2.1 Print datamodel Version           >> %3_CONVERT_SUCCEED.LOG
ECHO                                       in LOG and SQL files              >> %3_CONVERT_SUCCEED.LOG
ECHO 			17 Sep 2008 - V2.2 Don't execute RemoveCRLF	     >> %3_CONVERT_SUCCEED.LOG
ECHO 			                   Check Optimized_Numbers status    >> %3_CONVERT_SUCCEED.LOG
ECHO 			12 Feb 2009 - V2.3 new EOF : \r\n instead of \n	     >> %3_CONVERT_SUCCEED.LOG
ECHO 			18 Feb 2009 - V2.4 On zip et supprime les *.TXT	     >> %3_CONVERT_SUCCEED.LOG
ECHO 			05 Mar 2009 - V2.5 Accepter 6iem param�tre BETA	     >> %3_CONVERT_SUCCEED.LOG
ECHO 			                   pour ne pas gerer account   	     >> %3_CONVERT_SUCCEED.LOG
ECHO Server Name [%1]                                                        >> %3_CONVERT_SUCCEED.LOG
ECHO RLA Database [%2]                                                       >> %3_CONVERT_SUCCEED.LOG
ECHO OfficeId [%3]                                                           >> %3_CONVERT_SUCCEED.LOG
ECHO With Text columns [%4]                                                  >> %3_CONVERT_SUCCEED.LOG
ECHO With Image columns [%5]                                                 >> %3_CONVERT_SUCCEED.LOG
ECHO Destination Server name [%6]                                            >> %3_CONVERT_SUCCEED.LOG
ECHO Destination database [%7]                                               >> %3_CONVERT_SUCCEED.LOG
ECHO Environment (optional) [%8]                                             >> %3_CONVERT_SUCCEED.LOG
ECHO *********************************************************************** >> %3_CONVERT_SUCCEED.LOG

ECHO ������������������������������������������������������������������������ͻ 
ECHO � CONVERT_2_SQLSERVER                                                    �
ECHO � ��������������������                                                   �
ECHO �     Description : Export BRIO datamodel and optionaly RLA Data         �
ECHO �     ������������� in order to load them in MSSQL                       �
ECHO �     Versions    :                                                      �
ECHO �     �������������                                                      �
ECHO �                  28 Feb 2008 - V1.0 First Release                      �
ECHO �                  16 Jul 2008 - V2.0 Remove CLUSTERED in CONSTRAINT     �
ECHO �                                     Limit text size to 1 if NO_TEXT    �
ECHO �                  10 Sep 2008 - V2.1 Print datamodel Version            �
ECHO �                                     in LOG and SQL files               �
ECHO �                  17 Sep 2008 - V2.2 Don't execute RemoveCRLF           �
ECHO �                                     Check Optimized_Numbers status     �
ECHO �                  18 Dec 2008 - V2.3 Mettre #EndOfLine# dans les IMAGES �
ECHO �                  18 Feb 2009 - V2.4 On zip et supprime les *.TXT       �
ECHO �                  05 Mar 2009 - V2.5 Accepter 6iem param�tre BETA       �
ECHO �                                     pour ne pas gerer account          �
ECHO �                  12 May 2009 - V2.6 Add Destination server/database    �
ECHO �                                     in order to generate BCPIN cmds    �
ECHO �     Dependences :                                                      �
ECHO �     �������������                                                      �
ECHO �                  VB Scripts                                            �
ECHO �                         CheckSqlOutput.vbs                             �
ECHO �                         RemoveCrLf.vbs                                 �
ECHO �                  Stored Procedures                                     �
ECHO �                         sp_po_CreateTables2External.sql                �
ECHO �                         sp_po_DropTables2External.sql                  �
ECHO ������������������������������������������������������������������������ͼ
ECHO. 
ECHO Program started at %time%
ECHO. 
ECHO Parameters :
ECHO ������������
ECHO 	Server Name [%1]
ECHO 	RLA Database [%2]
ECHO 	OfficeId [%3]
ECHO 	With Text columns [%4]
ECHO 	With Image columns [%5]
ECHO 	Destination Server Name [%6]
ECHO 	Destination Database [%7]
ECHO 	Environment (optional) [%8]
ECHO.
ECHO Execution :
ECHO �����������

ECHO 	Converting %2 to SQLServer, please wait ...
IF %3X == NONEX GOTO SUITE
ECHO 	Including the export of %3.

:SUITE
ECHO.
REM =====================================
ECHO 	Checking dependences versions
REM =====================================
..\checkversions.vbs %1 ..\CONVERT_2_SQLSERVER.DEP
IF ERRORLEVEL == 1 GOTO ERREURVERSIONS
TYPE CheckVersions.log
DEL CheckVersions.log

IF %8X == BETAX GOTO BETA
IF %3X == NONEX GOTO BETA

CALL ..\PREREQUIS %1 %2 %3 SUB
if ERRORLEVEL == 2 GOTO FIN
TYPE %3_CLEANUP_SUCCEED.LOG >> %3_CONVERT_SUCCEED.LOG
DEL %3_CLEANUP_SUCCEED.LOG 

:BETA
REM CALL ..\VIEWSCORRECTION %1 %2 SUB
if ERRORLEVEL == 2 GOTO FIN

ECHO.
REM =====================================
ECHO 	Checking Datamodel Version 
ECHO Checking Datamodel Version >> %3_CONVERT_SUCCEED.LOG
REM =====================================
ECHO SET NOCOUNT ON 											> %3_VERSION_TABLES.sql
ECHO USE %2 												>> %3_VERSION_TABLES.sql
ECHO GO 												>> %3_VERSION_TABLES.sql

ECHO declare @a	varchar(255)										>> %3_VERSION_TABLES.sql
ECHO select @a = convert(varchar,version)+"-"+comments+"-"+c_type_broker from db_vers			>> %3_VERSION_TABLES.sql
ECHO print "	Datamodel Version : %%1!",@a								>> %3_VERSION_TABLES.sql
ECHO print " "												>> %3_VERSION_TABLES.sql
ECHO GO  												>> %3_VERSION_TABLES.sql

ECHO if exists (select * from sysobjects where type = "U" and name = "Optimized_Numbers")		>> %3_VERSION_TABLES.sql
ECHO BEGIN												>> %3_VERSION_TABLES.sql
ECHO 	print "Droping Table Optimized_Numbers"								>> %3_VERSION_TABLES.sql
ECHO 	declare @cmd varchar(5000)									>> %3_VERSION_TABLES.sql
ECHO 	select @cmd = "Drop table Optimized_Numbers"							>> %3_VERSION_TABLES.sql
ECHO 	exec (@cmd)											>> %3_VERSION_TABLES.sql
ECHO END												>> %3_VERSION_TABLES.sql
ECHO GO													>> %3_VERSION_TABLES.sql

ECHO if not exists (select * from sysobjects where type = "U" and name = "Optimized_Numbers_pt")	>> %3_VERSION_TABLES.sql
ECHO BEGIN												>> %3_VERSION_TABLES.sql
ECHO 	print "Creating Table Optimized_Numbers_pt"							>> %3_VERSION_TABLES.sql
ECHO 	declare @cmd varchar(5000)									>> %3_VERSION_TABLES.sql
ECHO 	select @cmd = 'create table Optimized_Numbers_pt						>> %3_VERSION_TABLES.sql
ECHO 		(											>> %3_VERSION_TABLES.sql
ECHO 		courtier_id 		courtier_ident,							>> %3_VERSION_TABLES.sql
ECHO 		p_contract		int,								>> %3_VERSION_TABLES.sql
ECHO 		p_vcontract		int,								>> %3_VERSION_TABLES.sql
ECHO 		bvvo			int,								>> %3_VERSION_TABLES.sql
ECHO 		contract_no		char(12),							>> %3_VERSION_TABLES.sql
ECHO 		opt_contract_no		char(12)	null,						>> %3_VERSION_TABLES.sql
ECHO 		c_type_version		char(1),							>> %3_VERSION_TABLES.sql
ECHO 		ExecutionDateTime	char(17)							>> %3_VERSION_TABLES.sql
ECHO 		)'											>> %3_VERSION_TABLES.sql
ECHO 	exec (@cmd)											>> %3_VERSION_TABLES.sql
ECHO END												>> %3_VERSION_TABLES.sql
ECHO GO													>> %3_VERSION_TABLES.sql

ECHO declare @cmd varchar(5000)										>> %3_VERSION_TABLES.sql
ECHO select @cmd = "Delete SRVADMIN..nonrlatables where name = 'Optimized_Numbers'"			>> %3_VERSION_TABLES.sql
ECHO exec (@cmd)											>> %3_VERSION_TABLES.sql
ECHO GO													>> %3_VERSION_TABLES.sql

ECHO if not exists (select * from sysobjects where type = "V" and name = "Optimized_Numbers")		>> %3_VERSION_TABLES.sql
ECHO BEGIN												>> %3_VERSION_TABLES.sql
ECHO 	print "Creating View Optimized_Numbers"								>> %3_VERSION_TABLES.sql
ECHO 	declare @cmd varchar(5000)									>> %3_VERSION_TABLES.sql
ECHO 	select @cmd = 'Create view Optimized_Numbers							>> %3_VERSION_TABLES.sql
ECHO 			As										>> %3_VERSION_TABLES.sql
ECHO 			Select  p_contract		,						>> %3_VERSION_TABLES.sql
ECHO 				p_vcontract		,						>> %3_VERSION_TABLES.sql
ECHO 				bvvo			,						>> %3_VERSION_TABLES.sql
ECHO 				contract_no		,						>> %3_VERSION_TABLES.sql
ECHO 				opt_contract_no		,						>> %3_VERSION_TABLES.sql
ECHO 				c_type_version		,						>> %3_VERSION_TABLES.sql
ECHO 				ExecutionDateTime							>> %3_VERSION_TABLES.sql
ECHO 			from Optimized_Numbers_pt							>> %3_VERSION_TABLES.sql
ECHO 			Where courtier_id = user_name()'						>> %3_VERSION_TABLES.sql
ECHO 	exec (@cmd)											>> %3_VERSION_TABLES.sql

ECHO 	select @cmd = "Grant all on Optimized_Numbers to GroupOffice"					>> %3_VERSION_TABLES.sql
ECHO 	exec (@cmd)											>> %3_VERSION_TABLES.sql
ECHO END												>> %3_VERSION_TABLES.sql
ECHO GO  												>> %3_VERSION_TABLES.sql

isql -HCONVERT_2_SQLSERVER -Usa -S%1 -P -i%3_VERSION_TABLES.sql -o%3_VERSION_TABLES.LOG -w400
REM Check bat generation errors
..\checksqloutput.vbs %3_VERSION_TABLES.LOG
IF ERRORLEVEL == 1 GOTO ERREUR_DATAMODEL_VERSION

type %3_VERSION_TABLES.LOG
type %3_VERSION_TABLES.LOG >> %3_CONVERT_SUCCEED.LOG
DEL %3_VERSION_TABLES.sql
DEL %3_VERSION_TABLES.LOG

IF %3X == NONEX GOTO NO_DATA

REM =====================================
ECHO 	Generate bcp commands 
ECHO Generate bcp commands >> %3_CONVERT_SUCCEED.LOG
REM =====================================
ECHO SET NOCOUNT ON 											> %3_BCP_TABLES.sql
ECHO USE %2 												>> %3_BCP_TABLES.sql
ECHO GO 												>> %3_BCP_TABLES.sql

IF %5X == YESX GOTO IMAGES
GOTO NO_IMAGES

:IMAGES
REM les tables du type _PT
REM Les champs type image
ECHO select tab=' echo .'+char(13)+char(10)+' echo .'+char(13)+char(10)+				>> %3_BCP_TABLES.sql
ECHO ' echo exporting %2..'+substring(name,1,patindex("%%_PT",name)-1)+char(13)+char(10)+		>> %3_BCP_TABLES.sql
ECHO 'bcp "%2..'+substring(name,1,patindex("%%_PT",name)-1)+ '" out '+substring(name,1,patindex("%%_PT",name)-1)+'.txt -c -U%3 -P%3 -J -t\t;, -r#EndOfLine#\r\n -S%1 -T100000000' 	>> %3_BCP_TABLES.sql
ECHO from sysobjects 											>> %3_BCP_TABLES.sql
ECHO where type = "U" 											>> %3_BCP_TABLES.sql
ECHO and name like "%%[_]PT"										>> %3_BCP_TABLES.sql
ECHO and name in (select object_name(id) from syscolumns where type = 34)				>> %3_BCP_TABLES.sql						
ECHO UNION  												>> %3_BCP_TABLES.sql

:NO_IMAGES

IF %4X == YESX GOTO TEXT
GOTO NO_TEXT

:TEXT
REM les tables du type _PT
REM Les champs pas du type image, donc champs text sont compris dans ceux-ci, on les corrigera avec RemoveCrLf

ECHO select tab=' echo .'+char(13)+char(10)+' echo .'+char(13)+char(10)+					>> %3_BCP_TABLES.sql
ECHO ' echo exporting %2..'+substring(name,1,patindex("%%_PT",name)-1)+char(13)+char(10)+		>> %3_BCP_TABLES.sql
ECHO 'bcp "%2..'+substring(name,1,patindex("%%_PT",name)-1)+ '" out '+substring(name,1,patindex("%%_PT",name)-1)+'.txt -c -U%3 -P%3 -J -t\t;, -r#EndOfLine#\r\n -S%1 -T100000000' 	>> %3_BCP_TABLES.sql
ECHO from sysobjects 											>> %3_BCP_TABLES.sql
ECHO where type = "U" 											>> %3_BCP_TABLES.sql
ECHO and name like "%%[_]PT"										>> %3_BCP_TABLES.sql
ECHO and name not in (select object_name(id) from syscolumns where type = 34)				>> %3_BCP_TABLES.sql						
ECHO Order By tab											>> %3_BCP_TABLES.sql
ECHO GO  												>> %3_BCP_TABLES.sql

GOTO EXECUTE_SQL
:NO_TEXT
REM les tables du type _PT
REM Les champs pas du type image, donc champs text sont compris dans ceux-ci mais ils ont une taille de 1 caractere (-T1) , on les corrigera avec RemoveCrLf

ECHO select tab=' echo .'+char(13)+char(10)+' echo .'+char(13)+char(10)+					>> %3_BCP_TABLES.sql
ECHO ' echo exporting %2..'+substring(name,1,patindex("%%_PT",name)-1)+char(13)+char(10)+		>> %3_BCP_TABLES.sql
ECHO 'bcp "%2..'+substring(name,1,patindex("%%_PT",name)-1)+ '" out '+substring(name,1,patindex("%%_PT",name)-1)+'.txt -c -U%3 -P%3 -J -t\t;, -r#EndOfLine#\r\n -S%1 -T1' 	>> %3_BCP_TABLES.sql
ECHO from sysobjects 											>> %3_BCP_TABLES.sql
ECHO where type = "U" 											>> %3_BCP_TABLES.sql
ECHO and name like "%%[_]PT"										>> %3_BCP_TABLES.sql
ECHO and name not in (select object_name(id) from syscolumns where type = 34)				>> %3_BCP_TABLES.sql						
ECHO Order By tab											>> %3_BCP_TABLES.sql
ECHO GO  												>> %3_BCP_TABLES.sql

:EXECUTE_SQL
isql -HCONVERT_2_SQLSERVER -Usa -S%1 -P -i%3_BCP_TABLES.sql -o%3_BCP_TABLES.bat -w400
REM Check bat generation errors
..\checksqloutput.vbs %3_BCP_TABLES.bat
IF ERRORLEVEL == 1 GOTO ERREURCHECK

ECHO @@ECHO OFF > %3_temp.bat
for /F "skip=2 tokens=*" %%j in (%3_BCP_TABLES.bat) do @echo %%j >> %3_temp.bat

REM =====================================
ECHO 	Execute bcp commands 
ECHO Execute bcp commands >> %3_CONVERT_SUCCEED.LOG
REM =====================================
CALL %3_temp.bat > %3_temp.out

..\checksqloutput.vbs %3_temp.out
IF ERRORLEVEL == 1 GOTO ERREURCHECK2
type %3_temp.out >> %3_CONVERT_SUCCEED.LOG

:NO_DATA
REM =====================================
ECHO 	Generate bcp in commands 
ECHO Generate bcp in commands >> %3_CONVERT_SUCCEED.LOG
REM =====================================
ECHO SET NOCOUNT ON 											> %3_BCP_TABLES.sql
ECHO USE %2 												>> %3_BCP_TABLES.sql
ECHO GO 												>> %3_BCP_TABLES.sql

IF %5X == YESX GOTO IMAGES
GOTO NO_IMAGES

:IMAGES
REM les tables du type _PT
REM Les champs type image
ECHO select tab=' echo .'+char(13)+char(10)+' echo .'+char(13)+char(10)+				>> %3_BCP_TABLES.sql

ECHO ' echo importing %7..'+substring(name,1,patindex("%%_PT",name)-1)+char(13)+char(10)+		>> %3_BCP_TABLES.sql
ECHO 'bcp "%7.dbo.'+substring(name,1,patindex("%%_PT",name)-1)+ '" in '+substring(name,1,patindex("%%_PT",name)-1)+'.txt -c -U%3 -P%3 -t\t;, -r#EndOfLine#\n -S%6 ' 	>> %3_BCP_TABLES.sql

ECHO from sysobjects 											>> %3_BCP_TABLES.sql
ECHO where type = "U" 											>> %3_BCP_TABLES.sql
ECHO and name like "%%[_]PT"										>> %3_BCP_TABLES.sql
ECHO and name in (select object_name(id) from syscolumns where type = 34)				>> %3_BCP_TABLES.sql						
ECHO UNION  												>> %3_BCP_TABLES.sql

:NO_IMAGES

IF %4X == YESX GOTO TEXT
GOTO NO_TEXT

:TEXT
REM les tables du type _PT
REM Les champs pas du type image, donc champs text sont compris dans ceux-ci, on les corrigera avec RemoveCrLf

ECHO select tab=' echo .'+char(13)+char(10)+' echo .'+char(13)+char(10)+					>> %3_BCP_TABLES.sql

ECHO ' echo importing %7..'+substring(name,1,patindex("%%_PT",name)-1)+char(13)+char(10)+		>> %3_BCP_TABLES.sql
ECHO 'bcp "%7.dbo.'+substring(name,1,patindex("%%_PT",name)-1)+ '" in '+substring(name,1,patindex("%%_PT",name)-1)+'.txt -c -U%3 -P%3 -t\t;, -r#EndOfLine#\n -S%6' 	>> %3_BCP_TABLES.sql

ECHO from sysobjects 											>> %3_BCP_TABLES.sql
ECHO where type = "U" 											>> %3_BCP_TABLES.sql
ECHO and name like "%%[_]PT"										>> %3_BCP_TABLES.sql
ECHO and name not in (select object_name(id) from syscolumns where type = 34)				>> %3_BCP_TABLES.sql						
ECHO Order By tab											>> %3_BCP_TABLES.sql
ECHO GO  												>> %3_BCP_TABLES.sql

GOTO EXECUTE_SQL
:NO_TEXT
REM les tables du type _PT
REM Les champs pas du type image, donc champs text sont compris dans ceux-ci mais ils ont une taille de 1 caractere (-T1) , on les corrigera avec RemoveCrLf

ECHO select tab=' echo .'+char(13)+char(10)+' echo .'+char(13)+char(10)+					>> %3_BCP_TABLES.sql

ECHO ' echo importing %7..'+substring(name,1,patindex("%%_PT",name)-1)+char(13)+char(10)+		>> %3_BCP_TABLES.sql
ECHO 'bcp "%7.dbo.'+substring(name,1,patindex("%%_PT",name)-1)+ '" in '+substring(name,1,patindex("%%_PT",name)-1)+'.txt -c -U%3 -P%3 -t\t;, -r#EndOfLine#\n -S%6 ' 	>> %3_BCP_TABLES.sql

ECHO from sysobjects 											>> %3_BCP_TABLES.sql
ECHO where type = "U" 											>> %3_BCP_TABLES.sql
ECHO and name like "%%[_]PT"										>> %3_BCP_TABLES.sql
ECHO and name not in (select object_name(id) from syscolumns where type = 34)				>> %3_BCP_TABLES.sql						
ECHO Order By tab											>> %3_BCP_TABLES.sql
ECHO GO  												>> %3_BCP_TABLES.sql

:EXECUTE_SQL
isql -HCONVERT_2_SQLSERVER -Usa -S%1 -P -i%3_BCP_TABLES.sql -o%3_BCP_TABLES.bat -w400
REM Check bat generation errors
..\checksqloutput.vbs %3_BCP_TABLES.bat
IF ERRORLEVEL == 1 GOTO ERREURCHECK

ECHO @@ECHO OFF > LOAD_%7.bat
for /F "skip=2 tokens=*" %%j in (%3_BCP_TABLES.bat) do @echo %%j >> LOAD_%7.bat

REM =====================================
ECHO 	Generate SQLServer datamodel commands
ECHO Generate SQLServer datamodel commands >> %3_CONVERT_SUCCEED.LOG
REM =====================================
REM =====================================
ECHO 	Generating  Groups Scripts ...
ECHO Generating  Groups Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_GROUPS.sql
ECHO GO 				>> %3_CREATE_GROUPS.sql
ECHO EXEC sp_MS_CreateGroups '%3' 	>> %3_CREATE_GROUPS.sql
ECHO GO 				>> %3_CREATE_GROUPS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_GROUPS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 101_MSSQL_CreateGroups.Sql

DEL %3_CREATE_GROUPS.sql

REM =====================================
ECHO 	Generating  Users Scripts ...
ECHO Generating  Users Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_USERS.sql
ECHO GO 				>> %3_CREATE_USERS.sql
ECHO EXEC sp_MS_CreateUsers '%3' 	>> %3_CREATE_USERS.sql
ECHO GO 				>> %3_CREATE_USERS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_USERS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 102_MSSQL_CreateUsers.Sql

DEL %3_CREATE_USERS.sql

REM =====================================
ECHO 	Generating  Aliases Scripts ...
ECHO Generating  Aliases Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_ALIASES.sql
ECHO GO 				>> %3_CREATE_ALIASES.sql
ECHO EXEC sp_MS_CreateAliases '%3' 	>> %3_CREATE_ALIASES.sql
ECHO GO 				>> %3_CREATE_ALIASES.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_ALIASES.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 103_MSSQL_CreateAliases.Sql

DEL %3_CREATE_ALIASES.sql

REM =====================================
ECHO 	Generating  Defaults Scripts ...
ECHO Generating  Defaults Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 					> %3_CREATE_DEFAULTS.sql
ECHO GO 					>> %3_CREATE_DEFAULTS.sql
ECHO EXEC sp_MS_CreateObjects 'D','%3'  	>> %3_CREATE_DEFAULTS.sql
ECHO GO 					>> %3_CREATE_DEFAULTS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_DEFAULTS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 104_MSSQL_CreateDefaults.Sql

DEL %3_CREATE_DEFAULTS.sql

REM =====================================
ECHO 	Generating  Types Scripts ...
ECHO Generating  Types Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_TYPES.sql
ECHO GO 				>> %3_CREATE_TYPES.sql
ECHO EXEC sp_MS_CreateTypes '%3' 	>> %3_CREATE_TYPES.sql
ECHO GO 				>> %3_CREATE_TYPES.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_TYPES.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 105_MSSQL_CreateTypes.Sql

DEL %3_CREATE_TYPES.sql

REM =====================================
ECHO 	Generating  Defaults Bindings Scripts ...
ECHO Generating  Defaults Bindings Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_DEFAULTS_BINDINGS.sql
ECHO GO 				>> %3_DEFAULTS_BINDINGS.sql
ECHO EXEC sp_MS_BindDefaults '%3' 	>> %3_DEFAULTS_BINDINGS.sql
ECHO GO 				>> %3_DEFAULTS_BINDINGS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_DEFAULTS_BINDINGS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 106_MSSQL_DefaultsBindings.Sql

DEL %3_DEFAULTS_BINDINGS.sql

REM =====================================
ECHO 	Generating  Tables Scripts ...
ECHO Generating  Tables Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================
ECHO SET NOCOUNT ON 											> %3_CREATE_TABLES.sql
ECHO USE %2 												>> %3_CREATE_TABLES.sql
ECHO GO 												>> %3_CREATE_TABLES.sql

ECHO declare @a	varchar(255)										>> %3_CREATE_TABLES.sql
ECHO select @a = convert(varchar,version)+"-"+comments+"-"+c_type_broker from db_vers			>> %3_CREATE_TABLES.sql
ECHO print "-- Datamodel Version : %%1!",@a								>> %3_CREATE_TABLES.sql
ECHO GO  												>> %3_CREATE_TABLES.sql

ECHO exec sp_MS_CreateTables '%3','%4'									>> %3_CREATE_TABLES.sql
ECHO GO  												>> %3_CREATE_TABLES.sql

isql -HCONVERT_2_SQLSERVER -Usa -S%1 -P -i%3_CREATE_TABLES.sql -oTEMP.Sql -w400
REM Check bat generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREURDATAMODEL
..\RemoveReturnCodes.vbs TEMP.SQL 107_MSSQL_CreateTables.Sql

DEL %3_CREATE_TABLES.sql

REM =====================================
ECHO 	Generating  Indexes Scripts ...
ECHO Generating  Indexes Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_INDEXES.sql
ECHO GO 				>> %3_CREATE_INDEXES.sql
ECHO EXEC sp_MS_CreateIndexes '%3' 	>> %3_CREATE_INDEXES.sql
ECHO GO 				>> %3_CREATE_INDEXES.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_INDEXES.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 108_MSSQL_CreateIndexes.Sql

DEL %3_CREATE_INDEXES.sql

REM =====================================
ECHO 	Generating  Views Scripts ...
ECHO Generating  Views Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 					> %3_CREATE_VIEWS.sql
ECHO GO 					>> %3_CREATE_VIEWS.sql
ECHO EXEC sp_MS_CreateObjects 'V','%3'  	>> %3_CREATE_VIEWS.sql
ECHO GO 					>> %3_CREATE_VIEWS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_VIEWS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 109_MSSQL_CreateViews.Sql
COPY 109_MSSQL_CreateViews.Sql 110_MSSQL_CreateViews.Sql

DEL %3_CREATE_VIEWS.sql

REM =====================================
ECHO 	Generating  Triggers Scripts ...
ECHO Generating  Triggers Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 					> %3_CREATE_TRIGGERS.sql
ECHO GO 					>> %3_CREATE_TRIGGERS.sql
ECHO EXEC sp_MS_CreateObjects 'TR','%3'  	>> %3_CREATE_TRIGGERS.sql
ECHO GO 					>> %3_CREATE_TRIGGERS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_TRIGGERS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 111_MSSQL_CreateTriggers.Sql

DEL %3_CREATE_TRIGGERS.sql

REM =====================================
ECHO 	Generating  Procedures Scripts ...
ECHO Generating  Procedures Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 					> %3_CREATE_PROCEDURES.sql
ECHO GO 					>> %3_CREATE_PROCEDURES.sql
ECHO EXEC sp_MS_CreateObjects 'P','%3'  	>> %3_CREATE_PROCEDURES.sql
ECHO GO 					>> %3_CREATE_PROCEDURES.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_PROCEDURES.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 112_MSSQL_CreateProcedures.Sql

DEL %3_CREATE_PROCEDURES.sql

REM =====================================
ECHO 	Generating  Grants Scripts ...
ECHO Generating  Grants Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_GRANTS.sql
ECHO GO 				>> %3_CREATE_GRANTS.sql
ECHO EXEC sp_MS_GrantObjects '%3' 	>> %3_CREATE_GRANTS.sql
ECHO GO 				>> %3_CREATE_GRANTS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_GRANTS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 113_MSSQL_GrantObjects.Sql

DEL %3_CREATE_GRANTS.sql

REM =====================================
ECHO 	Generating  ForeignKeys Scripts ...
ECHO Generating  ForeignKeys Scripts ... >> %3_CONVERT_SUCCEED.LOG
REM =====================================

ECHO USE %2 				> %3_CREATE_FKEYS.sql
ECHO GO 				>> %3_CREATE_FKEYS.sql
ECHO EXEC sp_MS_CreateForeignKeys '%3' 	>> %3_CREATE_FKEYS.sql
ECHO GO 				>> %3_CREATE_FKEYS.sql

isql -Usa -HREORG_DB -S%1 -P -i%3_CREATE_FKEYS.sql -oTEMP.sql -w400
REM Check generation errors
..\checksqloutput.vbs TEMP.SQL
IF ERRORLEVEL == 1 GOTO ERREUROUT
..\RemoveReturnCodes.vbs TEMP.SQL 114_MSSQL_CreateForeignKeys.Sql

DEL %3_CREATE_FKEYS.sql

ECHO.
REM =====================================
ECHO 	Cleaning up working directory ... 
ECHO Cleaning up working directory ... >> %3_CONVERT_SUCCEED.LOG 
REM =====================================
DEL TEMP.SQL

IF EXIST %3_BCP_*.SQL DEL %3_BCP_*.SQL
IF EXIST %3_BCP_*.BAT DEL %3_BCP_*.BAT
IF EXIST %3_temp.OUT DEL %3_temp.OUT
IF EXIST %3_temp.BAT DEL %3_temp.BAT

REM =====================================
REM ECHO 	Creating zip file ... 
REM ECHO Creating zip file ... >> %3_CONVERT_SUCCEED.TXT 
REM =====================================
REM ..\ZIP %3.ZIP *.* >> %3_CONVERT_SUCCEED.LOG
REM IF EXIST *.TXT DEL *.TXT

ECHO Export %3 from %2 successfully processed ... >> %3_CONVERT_SUCCEED.LOG

time /t >> %3_CONVERT_SUCCEED.LOG



ECHO.
ECHO 	CONVERSION of %2 to SQLServer successfully processed ...
IF %3X == NONEX GOTO SUITE2
ECHO 	INCLUDING THE EXPORT of %3.
:SUITE2
ECHO 	       results in ..\%3
ECHO.
ECHO Program ended at %time%

CD ..

REM ..\MAIL\sendmail.vbs "..\MAIL\toto.INI" "MIGRATION NOTIFICATION" "DATABASE %DBNAME% IS READY FOR PRODUCTION,DECIDE WHEN..."

EXIT /B 1

GOTO FIN

:ERREURPARAM
CLS
ECHO *********************************************************************** 
ECHO MISSING Server Name [%1]                                                
ECHO MISSING RLA Database Name [%2]                                                   
ECHO MISSING OPTIONAL OfficeId [%3] or NONE                                                   
ECHO MISSING With Text columns [%4] YES / NO
ECHO MISSING With Image columns [%5] YES / NO
ECHO MISSING Destination Server Name [%6]
ECHO MISSING Destination Database [%7]
ECHO ������������������
ECHO OPTIONAL PARAMETER : "BETA" (on ne gere pas l'account)
ECHO ������������������
ECHO Example : CONVERT_2_SQLSERVER BRIOPATCH02 BRIO_RLA_BRIOPLUS_01 DB59876 YES NO BETA
ECHO *********************************************************************** 
GOTO FIN

:ERREURVERSIONS
REN %3_CONVERT_SUCCEED.LOG %3_CONVERT_ERROR.LOG
TYPE checkversions.log >> %3_CONVERT_ERROR.LOG
TYPE checkversions.log 
GOTO MSG

:ERREURCHECK
REN %3_CONVERT_SUCCEED.LOG %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
time/t									     >> %3_CONVERT_ERROR.LOG
date/t									     >> %3_CONVERT_ERROR.LOG
ECHO ERROR GENERATING bcp commands                                           >> %3_CONVERT_ERROR.LOG
ECHO * Here Is the print of log script file %3_BCP_TABLES.bat                >> %3_CONVERT_ERROR.LOG
TYPE %3_BCP_TABLES.bat                                                       >> %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
GOTO MSG

:ERREURCHECK2
REN %3_CONVERT_SUCCEED.LOG %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
time/t									     >> %3_CONVERT_ERROR.LOG
date/t									     >> %3_CONVERT_ERROR.LOG
ECHO ERROR executing bcp commands                                            >> %3_CONVERT_ERROR.LOG
ECHO * Here Is the print of log script file %3_temp.out                      >> %3_CONVERT_ERROR.LOG
TYPE %3_temp.out                                                             >> %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
GOTO MSG

:ERREUR_DATAMODEL_VERSION
REN %3_CONVERT_SUCCEED.LOG %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
time/t									     >> %3_CONVERT_ERROR.LOG
date/t									     >> %3_CONVERT_ERROR.LOG
ECHO ERROR executing version script                                          >> %3_CONVERT_ERROR.LOG
ECHO * Here Is the print of log script file %3_VERSION_TABLES.LOG            >> %3_CONVERT_ERROR.LOG
TYPE %3_VERSION_TABLES.LOG                                                   >> %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
GOTO MSG

:ERREURDATAMODEL
REN %3_CONVERT_SUCCEED.LOG %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
time/t									     >> %3_CONVERT_ERROR.LOG
date/t									     >> %3_CONVERT_ERROR.LOG
ECHO ERROR creating datamodel scripts                                        >> %3_CONVERT_ERROR.LOG
ECHO * Here Is the print of log script file temp.sql                         >> %3_CONVERT_ERROR.LOG
TYPE Temp.sql                                                                >> %3_CONVERT_ERROR.LOG
ECHO *********************************************************************** >> %3_CONVERT_ERROR.LOG
GOTO MSG

:MSG
ECHO.
ECHO 	ERROR Converting %2 to SQLServer, optionaly exporting %3 data !!!!! Please check %3_CONVERT_ERROR.LOG
REM ..\MAIL\sendmail.vbs "..\MAIL\toto.INI" "MIGRATION NOTIFICATION" "ERROR OCCURED FOR %2 ON DATABASE %DBNAME%" "%3_CONVERT_ERROR.LOG"
CD ..
EXIT /B 2

GOTO FIN
 
:FIN 

