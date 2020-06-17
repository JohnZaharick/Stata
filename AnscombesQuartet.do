********************************************************************************
*SECTION ONE: PRELIMINARIES
********************************************************************************

*This file demonstrates Anscombe's Quartet and the importance of visualizing 
*data.

*Set up Stata
	clear all
	set linesize 80
	set more off, permanently
	
*Create a log file to record what code is run during this session.
	global DoFileName "AnscombesQuartet"
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
	global GraphPath ""C:\StataTutorial\GraphFiles\"
	capture mkdir ${GraphPath}

********************************************************************************
*SECTION TWO: Anscombe's Quartet
********************************************************************************
	
/*
We're going to build a data set consisting of four x,y pairs.  For each pair,
we'll find the mean, sample variance, correlation, linear regression line, and 
coefficient of determination of the linear regression.  Then, we'll make scatter
plots of each pair to visualize the data.
*/
	
*Build the data set
	capture drop x1 y1 x2 y2 x3 y3 x4 y4
	input x1 y1 x2 y2 x3 y3 x4 y4
		10.0 	8.04 	10.0 	9.14 	10.0 	7.46 	8.0 	6.58
		8.0 	6.95 	8.0 	8.14 	8.0 	6.77 	8.0 	5.76
		13.0 	7.58 	13.0 	8.74 	13.0 	12.74 	8.0 	7.71
		9.0 	8.81 	9.0 	8.77 	9.0 	7.11 	8.0 	8.84
		11.0 	8.33 	11.0 	9.26 	11.0 	7.81 	8.0 	8.47
		14.0 	9.96 	14.0 	8.10 	14.0 	8.84 	8.0 	7.04
		6.0 	7.24 	6.0 	6.13 	6.0 	6.08 	8.0 	5.25
		4.0 	4.26 	4.0 	3.10 	4.0 	5.39 	19.0 	12.50
		12.0 	10.84 	12.0 	9.13 	12.0 	8.15 	8.0 	5.56
		7.0 	4.82 	7.0 	7.26 	7.0 	6.42 	8.0 	7.91
		5.0 	5.68 	5.0 	4.74 	5.0 	5.73 	8.0 	6.89 
	end
	
*Compare the mean and variance or each column of numbers.
	tabstat x1 x2 x3 x4, stat(mean variance)
/*
   stats |        x1        x2        x3        x4
---------+----------------------------------------
    mean |         9         9         9         9
variance |        11        11        11        11
--------------------------------------------------
*/

	tabstat y1 y2 y3 y4, stat(mean variance)
/*
   stats |        y1        y2        y3        y4
---------+----------------------------------------
    mean |  7.500909  7.500909       7.5  7.500909
variance |  4.127269   4.12763   4.12262  4.123249
--------------------------------------------------
*/

*What is the correlation between x and y for each pair?
	cor x1 y1
	*0.8164
	cor x2 y2
	*0.8162
	cor x3 y3
	*0.8163
	cor x4 y4
	*0.8165

*Run regressions on each pair and compare the statistics produce for each to
*every other pair.
	regress y1 x1
/*
	  Source |       SS           df       MS      Number of obs   =        11
-------------+----------------------------------   F(1, 9)         =     17.99
       Model |  27.5100011         1  27.5100011   Prob > F        =    0.0022
    Residual |  13.7626904         9  1.52918783   R-squared       =    0.6665
-------------+----------------------------------   Adj R-squared   =    0.6295
       Total |  41.2726916        10  4.12726916   Root MSE        =    1.2366

------------------------------------------------------------------------------
          y1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   .5000909   .1179055     4.24   0.002     .2333701    .7668117
       _cons |   3.000091   1.124747     2.67   0.026     .4557369    5.544445
------------------------------------------------------------------------------
*/

	regress y2 x2
/*
	  Source |       SS           df       MS      Number of obs   =        11
-------------+----------------------------------   F(1, 9)         =     17.97
       Model |  27.5000024         1  27.5000024   Prob > F        =    0.0022
    Residual |   13.776294         9  1.53069933   R-squared       =    0.6662
-------------+----------------------------------   Adj R-squared   =    0.6292
       Total |  41.2762964        10  4.12762964   Root MSE        =    1.2372

------------------------------------------------------------------------------
          y2 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x2 |         .5   .1179638     4.24   0.002     .2331475    .7668526
       _cons |   3.000909   1.125303     2.67   0.026     .4552978     5.54652
------------------------------------------------------------------------------
*/

	regress y3 x3
/*
	  Source |       SS           df       MS      Number of obs   =        11
-------------+----------------------------------   F(1, 9)         =     17.97
       Model |  27.4700075         1  27.4700075   Prob > F        =    0.0022
    Residual |  13.7561905         9  1.52846561   R-squared       =    0.6663
-------------+----------------------------------   Adj R-squared   =    0.6292
       Total |  41.2261979        10  4.12261979   Root MSE        =    1.2363

------------------------------------------------------------------------------
          y3 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x3 |   .4997273   .1178777     4.24   0.002     .2330695    .7663851
       _cons |   3.002455   1.124481     2.67   0.026     .4587014    5.546208
------------------------------------------------------------------------------
*/
	
	regress y4 x4
/*
	  Source |       SS           df       MS      Number of obs   =        11
-------------+----------------------------------   F(1, 9)         =     18.00
       Model |  27.4900007         1  27.4900007   Prob > F        =    0.0022
    Residual |  13.7424908         9  1.52694342   R-squared       =    0.6667
-------------+----------------------------------   Adj R-squared   =    0.6297
       Total |  41.2324915        10  4.12324915   Root MSE        =    1.2357

------------------------------------------------------------------------------
          y4 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x4 |   .4999091   .1178189     4.24   0.002     .2333841    .7664341
       _cons |   3.001727   1.123921     2.67   0.026     .4592411    5.544213
------------------------------------------------------------------------------
*/

	
/*
Each of the four pairs has the same or close to the same mean, sample
variance, correlation between x and y, linear regression line, and coeffecient
of determination of the linear regression.  From all those summary stats, we
could conclude that they are the same data.  But let's graph them and see what
happens.

First we're going to run the regression again, this time hiding the output with
the "quietly" command and storing the predicted values of the regression with
"predict".
*/
	capture drop regressionOne regressionTwo regressionThree regressionFour
	quietly reg y1 x1
	predict regressionOne
	
	quietly reg y2 x2
	predict regressionTwo

	quietly reg y3 x3
	predict regressionThree

	quietly reg y4 x4
	predict regressionFour

/*
Now we graph each pair as a scatter plot and use the || separator to draw a line
over the scatter plot, in this case the predicted regression values.  We save
each graph so they can be combined afterwards.
*/
	graph twoway scatter y1 x1, || ///
		line regressionOne x1, lcolor(blue) saving(${GraphPath}\first", replace)
	graph twoway scatter y2 x2, || ///
		line regressionTwo x2, lcolor(blue) saving(${GraphPath}\second", replace)
	graph twoway scatter y3 x3, || ///
		line regressionThree x3, lcolor(blue) saving(${GraphPath}\third", replace)
	graph twoway scatter y4 x4, || ///
		line regressionFour x4, lcolor(blue) saving(${GraphPath}\fourth", replace)
	
*Combine the saved graphs to display at the same time.
	gr combine ${GraphPath}\first.gph ${GraphPath}\second.gph ///
		${GraphPath}\third.gph ${GraphPath}\fourth.gph, ///
		title(Anscombe's Quartet)
		
*The four pairs of data all have nearly identical summary stats.  How do they
*compare when visualized, however?  Always visualize your data to gain
*additional insights into its nature.
	 
	
********************************************************************************
*SECTION FINAL
********************************************************************************

*Document the end of the file in the log, then close the log.
	display "${DoFileName}.do has completed successfully"
	log close
