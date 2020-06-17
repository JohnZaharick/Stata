********************************************************************************
*SECTION ONE: PRELIMINARIES
********************************************************************************

*This file demonstrates how to use the frmttable command to create a table.

*Set up Stata
	clear all
	set linesize 80
	set more off, permanently
	
*Create a log file to record what code is run during this session.
	global DoFileName "FrmttableExample"
	global CurrentDate : display %tdCCYY-NN-DD date(c(current_date),"DM20Y")
	global LogPath ""C:\StataTutorial\LogFiles\\${DoFileName}"
	
*Create a directory for log files if it doesn't already exist.
	capture mkdir ${LogPath}
	
*Start the log file.
	capture log close
	log using ${LogPath}\\${DoFileName}_${CurrentDate}.log", text replace
	
*Document who ran the file.
	dis "This file run by `c(username)'"
	
*Create a directory to save graph files.
	global TablePath ""C:\StataTutorial\TableFiles\"
	capture mkdir ${TablePath}
	
********************************************************************************
*SECTION TWO: A step by step walk through
********************************************************************************
	
/*
This section will walk you through basic frmttable commands and illustrate how
they shape the structure of the table. Run each piece of code one at a time and
view the results in the console.
	
If frmttable is not installed, type "findit frmttable" in the command line to 
bring up a list of websites where the package can be downloaded from.
*/

*frmttable takes a matrix as an argument.  Let's make a simple 4 cell matrix and
*observe what it looks like
	matrix A = (100,50\0,25)
	matrix list A
	
*Now we'll format the matrix to display as a table. This is the simplest table
*you can make.
	frmttable, statmat(A)
	
/*
Let's work with a more complicated example now.  This is a 9x5 matrix where the
first number is a mean, the next two numbers are the confidence interval bounds 
for that mean, and then the fourth number repeats the  pattern.
*/
	matrix B = (275,205,346,436,345,526,161,49,273\ ///
				262,136,389,399,198,600,137,-99,372\ ///
				225,170,280,267,208,327,42,-36,120\ ///
				161,118,205,207,133,280,45,-36,127\ ///
				-37,-174,100,-132,-340,77,-95,-344,155)
	matrix list B
	
/*
We're going to combine the confidence interval bounds into a single cell in the
table we're about to make.  We need a second matrix of 1 dimension, or a vector,
to tell frmttable which columns to combine using 0's and 1's.  This new vector
must match the number of columns in the original matrix.  The 1's indicate which
columns to combine. For example, matrix CI is written to combine the 3rd column
with the 2nd, the 6th with the 5th, and the 9th with the 8th.
*/
	matrix CI = (0,0,1,0,0,1,0,0,1)
	
*First, let's view a simple table of our data
	frmttable, statmat(B)
	
*To combine the confidence interval cells, we use doubles() and supply it with
*the CI matrix.  Notice that a dash is placed between the values.
	frmttable, statmat(B) doubles(CI)
	
/*
Let's place the confidence interval beneath the mean to make it clear that the 
three numbers go together.  substat(1) will place the values in the second 
column beneath the first, fourth beneth the third, etc. substat(2) would place
the second AND third column values beneath the first.
*/
	frmttable, statmat(B) doubles(CI) substat(1)
	
*dbldiv replaces the dash in doubles() with a comma.
	frmttable, statmat(B) doubles(CI) substat(1) dbldiv(", ")
	
*Next, we can set the number of decimal places to zero.
	frmttable, statmat(B) doubles(CI) substat(1) dbldiv(", ") sdec(0)
	
/*
Now the table is looking a lot nicer and our data are easier to understand.
Let's label the rows with rtitles().  While we have a column of 5 means, there
are 10 rows total now since each confidence interval is its own row.  Our data
are from truck drivers diagnosed with sleep apnea.  We have a control group, a
positively diagnosed group that did not adhere to treatment, a positively
diagnosed group that did adhere to treatment, a negatively diagnosed group, and
a cost difference calculation.
*/
	frmttable, statmat(B) doubles(CI) substat(1) dbldiv(", ") sdec(0) ///
	rtitles("Control"\ "95% CI"\ ///
			"No Adh."\ "95% CI"\ ///
			"Pos Adh."\ "95% CI"\ ///
			"Negative"\ "95% CI"\ ///
			"Cost Difference (Pos Adh.)-(No Adh)"\ "95% CI")
	
/*
Next, we can label the columsn with ctitles().  We are estimating Per Member
Per Month (PMPM) costs before and after a polysomnogram (PSG) testing date. 
Notice that we split our titles over two rows.
*/
	frmttable, statmat(B) doubles(CI) substat(1) dbldiv(", ") sdec(0) ///
	rtitles("Control"\ "95% CI"\ ///
			"No Adh."\ "95% CI"\ ///
			"Pos Adh."\ "95% CI"\ ///
			"Negative"\ "95% CI"\ ///
			"Cost Difference (Pos Adh.)-(No Adh)"\ "95% CI") ///
	ctitles("Study Subgroup", "Estimated PMPM", "Estimated PMPM", "Cost Difference"\ ///
			"","Cost Before", "Cost After", "After - Before")
			
*Let's add a title and also place each command on its own line to make the table
*code easier to read now that it's getting complicated.
	frmttable, ///
		statmat(B) ///
		doubles(CI) ///
		substat(1) ///
		dbldiv(", ") ///
		sdec(0) ///
		rtitles("Control"\ "95% CI"\ ///
				"No Adh."\ "95% CI"\ ///
				"Pos Adh."\ "95% CI"\ ///
				"Negative"\ "95% CI"\ ///
				"Cost Difference (Pos Adh.)-(No Adh)"\ "95% CI") ///
		ctitles("Study Subgroup", "Estimated PMPM", "Estimated PMPM", "Cost Difference"\ ///
				"","Cost Before", "Cost After", "After - Before") ///
		title("Table 1: PMPM Descriptive Cost Differences Before versus After the PSG date")
		
/*
To save the table, we add the using command.  Stata defaults to .doc, but we can
save as a TeX file as well.  Look in the TablePath folder for SampleTable1.doc
	
NOTE: Include replace at the end to overwrite any existing table with the same
name.
*/
	frmttable using ${TablePath}\\SampleTable1, ///
		statmat(B) ///
		doubles(CI) ///
		substat(1) ///
		dbldiv(", ") ///
		sdec(0) ///
		rtitles("Control"\ "95% CI"\ ///
				"No Adh."\ "95% CI"\ ///
				"Pos Adh."\ "95% CI"\ ///
				"Negative"\ "95% CI"\ ///
				"Cost Difference (Pos Adh.)-(No Adh)"\ "95% CI") ///
		ctitles("Study Subgroup", "Estimated PMPM", "Estimated PMPM", "Cost Difference"\ ///
				"","Cost Before", "Cost After", "After - Before") ///
		title("Table 1: PMPM Descriptive Cost Differences Before versus After the PSG date") ///
		replace


********************************************************************************
*SECTION THREE: Full table example
********************************************************************************
	
/*
There are numerous formatting commands that will improve the appearance of the
table, such as font and lines, that won't show up in the console.  Below is the 
final version of the table with these visual commands implemented.  Again, look 
in the TablePath folder for the finished output.
	
NOTE: To include quotes within quotes ("abbreviated as "PMPM"."), enclose
the string in `" "': `"abbreviated as "PMPM"."'
*/
	
	frmttable using ${TablePath}\SampleTable, ///
		statmat(B) ///
		doubles(CI) ///
		substat(1) ///
		dbldiv(", ") ///
		sdec(0) ///
		rtitles("Control"\ "95% CI"\ ///
				"No Adh."\ "95% CI"\ ///
				"Pos Adh."\ "95% CI"\ ///
				"Negative"\ "95% CI"\ ///
				"Cost Difference (Pos Adh.)-(No Adh)"\ "95% CI") ///
		ctitles("Study Subgroup", "Estimated PMPM", "Estimated PMPM", "Cost Difference"\ ///
				"","Cost Before", "Cost After", "After - Before") ///
		title("Table 1: PMPM Descriptive Cost Differences Before versus After the PSG date") ///
		vlines(11111) /// where in the table verticle lines will appear
		hlines(101111111111) /// where in the table horizontal lines will appear
		vlstyle(ddssd) ///  vertical line style: d = double s = single o = dotted (look in help frmttable for more)
		hlstyle(dddososososos) /// ditto for horizontal line style
		coljust(lccc) /// justify (align) each column: l = left c = center r = right
		basefont(roman) /// sets the table's base font; can also change font for specific parts of the table with other commands
		center note(Per-member per-month is abbreviated as "PMPM". Costs are adjusted, ///
		from dollars at the time of the study to 2019 dollars using the Personal Consumption, ///
		Expenditure (PCE) index for health care expenses. Within-period differences that are statistically, ///
		different (P =.05) are indicated by paired superscripts (e.g. two values having "a" are different);, ///
		`""*" indicates a statistically significant difference (P<=.05) between the before- and after-period"', ///
		(relevant t-tests were used.)) /// adds a centered note at the bottom of the table.
		replace
		/*
		You'll notice a comma at the end of each line in center note().  These
		don't appear in the actual table; they tell frmttable to break the line
		at this point.  This is separate from /// which tells Stata to continue
		reading code onto the next line.
		*/

********************************************************************************
*SECTION FINAL
********************************************************************************

*Document the end of the file in the log, then close the log.
	display "${DoFileName}.do has completed successfully"
	log close
