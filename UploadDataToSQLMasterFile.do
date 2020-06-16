********************************************************************************
*SECTION ONE: PRELIMINARIES
********************************************************************************

*This file demonstrates how to use Open Database Connectivity (odbc) in Stata to
*connect to Microsoft SQL Server and upload flat files to it.

***Set up Stata
	clear all
	set linesize 80
	set more off , permanently
	
*Create a log file to record what code is run during this session.
	global DoFileName "UploadDataToSQLMasterFile"
	global CurrentDate : display %tdCCYY-NN-DD date(c(current_date),"DM20Y")
	global LogPath ""C:\SQL\LogFiles\\${DoFileName}"
	
*Create a directory for log files if it doesn't already exist.
	capture mkdir ${LogPath}
	
*Start the log file.
	capture log close
	log using ${LogPath}\\${DoFileName}_${CurrentDate}.log", text replace
	
*Document who ran the file.
	dis "This file run by `c(username)'"
	
*Store the path to the flat files in a global macro.
	global FileToUploadPath ""C:\FolderFullOfFlatFiles"

********************************************************************************
*SECTION TWO: UPLOAD PROGRAM
********************************************************************************

*Display the contents of your SQL Server database.
	odbc query DataBaseName

*This program takes a table name, a command to create that table or insert data
*into it, and the path of the file being uploaded.
	capture program drop uploadToSQL_
	program uploadToSQL_
		* TableName: Schema.TableName
		* InsertOptions: create; insert
		* FilePath: ${FileToUploadPath}\Date\...csv"
		args TableName InsertOptions FilePath
		
		*Import the flat file into Stata.
		clear
		import delimited "`FilePath'", delimiter(comma) varnames(1) clear
		
		*Record the date the data was added to SQL Server
		capture drop DateAddedToSQLServer
		gen DateAddedToSQLServer = "$CurrentDate"

		odbc insert, table("`TableName'") `InsertOptions'
		
	end
	
********************************************************************************
*SECTION THREE: UPLOAD LOG
********************************************************************************
	
*Here you can maintain a list of calls to the program, documenting what files
*have been uploaded to SQL Server.

	uploadToSQL_ ///
		Schema.TableName create ${FileToUploadPath}\05-20\TestData1.csv"
		
	uploadToSQL_ ///
		Schema.TableName insert ${FileToUploadPath}\05-20\TestData2.csv"
		
********************************************************************************
*SECTION FINAL
********************************************************************************

*Document the end of the file in the log, then close the log file.

	display "${DoFileName}.do has completed successfully"

	log close
