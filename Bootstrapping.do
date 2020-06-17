********************************************************************************
*SECTION ONE: PRELIMINARIES
********************************************************************************

*This file demonstrates the bootstrapping concept and how it works in Stata.

*Set up Stata
	clear all
	set linesize 80
	set more off, permanently
	
*Create a log file to record what code is run during this session.
	global DoFileName "Bootstrapping"
	global CurrentDate : display %tdCCYY-NN-DD date(c(current_date),"DM20Y")
	global LogPath ""C:\StataTutorial\LogFiles\\${DoFileName}"
	
*Create a directory for log files if it doesn't already exist.
	capture mkdir ${LogPath}
	
*Start the log file.
	capture log close
	log using ${LogPath}\\${DoFileName}_${CurrentDate}.log", text replace
	
*Document who ran the file.
	dis "This file run by `c(username)'"

/*
Recall that a population from which we draw a sample has a true mean, but due to
limitations on measuring, we usually can only ever find a sample mean.  We
assume the sample mean is close to the population mean, but would like to know
how close.  Finding the standard error (SE) and confidence limits for a sample
mean can help us estimate how far the sample mean is from the population mean. 
Standard error can also be thought of as a measure of the variability of the 
sample mean across repeated samples.  If we were to repeat our study and take a 
second sample, we would expect the mean of the second sample to be close to, but
not identical to, the mean of the first sample.  Repeat the study over and over 
again, and the sample means from each repetition will vary about the population 
mean.  Standard error is an estimate of this variation.

The SE of a sample mean is easy to calculate.  It's simply the sample's standard
deviation (SD) divided by the square root of the sample size:

SE = SD/sqrt(n)

(Remember, the sample's SD is how much each measurement from that sample varies 
from the single sample mean, while standard error is how much multiple means
from multiple samples vary from the population mean).

However, other statistics, such as median or difference-in-difference
calculations, don't have simple ways to estimate standard error.  A solution 
lies in that the SE of a single sample statistic is equal to the standard
deviation of that statistic's sampling distribution.  In other words, if we
repeated the same study a large number of times, let's say 1000 times, we could
contruct a sampling distribution from those 1000 means, the SD of which is the 
SE of any particular mean.  Confidence limits for a statistic can also be 
estimated from the percentiles of the sampling distribution.  The 2.5 and 97.5
percentiles will bound 95% of the sampling distribution, thus providing 95%
confidence limits.

Obviously, we can't repeat our study 1000 times.  It was hard enough getting one
sample.  This is where bootstrapping comes in.  While we can't resample our 
population, we can create a second sample by randomly selecting our existing
measurements with replacement.  This second sample will have its own mean (or 
whatever statistic we're interested in) that will vary slightly from the 
original sample.  If we repeat this sampling with replacement technique a large 
number of times (let's say 1000 again), we'll end up with 1000 sample means. 
We now have a sampling distribution of the statistic in question.  We can take 
the SD of that distribution, as well as percentiles, and thus find an estimate 
for the statistic's SE and 95% confidence limits.

Put concisely, bootstrapping estimates the sampling distribution of the
statistic in question.
*/

********************************************************************************
*SECTION TWO: Create a sample, bootstrap estimates from it
********************************************************************************
 
*Set our number of samples and measurements per sample.  Set seed so the
*bootstrap gives the same results each time this file is run.
	clear all
	scalar nSamples = 1000
	scalar nMeasurements = 200
	set seed 0

*Collect a sample of 200 measurements by drawing random values from a normal
*distribution
	drawnorm theOriginalSample, n(`=nMeasurements')
	
*Find the mean, standard deviation, and standard error of this sample
	summarize
	scalar sampleMean = r(mean)
	scalar sampleSD = r(sd)
	scalar sampleSE = sampleSD/sqrt(`=nMeasurements')

*Now let's see if we can recreate the SE above using bootstrapping.  First, we
*create a matrix to store the mean of each sample we'll generate.
	set matsize `=nSamples'
	matrix meanList = J(`=nSamples', 1, 5) //1000 rows, 1 column, filled with null values
	
/*
bsample will randomly choose, with replacement, rows from the data in memory and
construct a new data set from them of length nMeasurements.  The data chosen by 
bootstrapping will overwrite the data drawnorm generated, so we use preserve and
restore to get that data back after each bootstrap.
*/
	quietly {								  //suppress console output
		forvalues i = 1(1) `=nSamples' {	  //run 1000 bootstraps
			preserve						  //save the original sample data
			bsample `=nMeasurements'		  //bootstrap!
			summarize, meanonly				  //find the mean
			matrix meanList[`i', 1] = r(mean) //store it in our matrix
			restore							  //recover the original sample data
		}
	}
	
*Now that we have 1000 means from 1000 samples, convert the matrix into a 
*variable.
	svmat meanList
		
*Find mean, standard error, and confidence intervals from the bootstrapped data.
	summarize meanList
	scalar bootstrappedMean = r(mean)
	scalar bootstrappedSE = r(sd)
	
*The 95% confidence limits are the 2.5 and 97.5 percentiles.
	centile meanList, centile (2.5, 97.5)		
	scalar lowerBound = r(c_1)
	scalar upperBound = r(c_2)
	
*Let's see how well we did.
	dis _newline ///
		"Number of measurements: " `=nMeasurements' _newline ///
		"Number of samples: " `=nSamples' _newline ///
		"Mean of the sample: " `=sampleMean' _newline ///
		"Bootstrapped mean: " `=bootstrappedMean' _newline ///
		"Calculated standard error of the sample mean: " `=sampleSE' _newline ///
		"Bootstrapped standard error of the sample mean: " `=bootstrappedSE' _newline ///
		"95% Confidence limits: " `=lowerBound' "," `=upperBound'
		
********************************************************************************
*SECTION FINAL
********************************************************************************

*Document the end of the file in the log, then close the log.
	display "${DoFileName}.do has completed successfully"
	log close


