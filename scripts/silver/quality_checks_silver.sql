/*
==============================================================================
Quality Checks
==============================================================================
Script Purpose:
	This script performs various quality checks for duplicates, whitespaces, data consistency,
	and rows with no layoff information
	- No duplicate rows
	- Unwanted spaces in string fields.
	- Data normalization

Note: In the industry we have one NULL couldn't fill it since there was only one record

Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancies found during the checks.
==============================================================================
*/

/*
=========================================================
			          	CHECK FOR DUPLICATES
=========================================================
*/
WITH CTE_duplicates AS (
	SELECT *, 	
	ROW_NUMBER() OVER(
		PARTITION BY company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions 
		ORDER BY company
	) AS row_num
 FROM silver.layoffs
)

SELECT * FROM CTE_duplicates
WHERE row_num > 1;

/*
=========================================================
				        CHECK FOR WHITESPACES
=========================================================
*/

SELECT * FROM silver.layoffs
WHERE company != TRIM(company);

SELECT * FROM silver.layoffs
WHERE [location] != TRIM([location]);

SELECT * FROM silver.layoffs
WHERE industry != TRIM(industry);

SELECT * FROM silver.layoffs
WHERE stage != TRIM(stage);

SELECT * FROM silver.layoffs
WHERE country != TRIM(country);

/*
=========================================================
		      	CHECK FOR DATA NORMALIZATION
=========================================================
*/

SELECT * FROM silver.layoffs
WHERE industry LIKE 'Crypto%';

SELECT * FROM silver.layoffs
WHERE country LIKE 'United States%'
AND country <> 'United States';

/* 
=========================================================
		      	CHECK FOR MISSING INDUSTRY NAMES
========================================================= 
*/

SELECT * FROM silver.layoffs
WHERE industry IS NULL;

/* 
=========================================================
	    	CHECK FOR ROWS WITH NO LAYOFF INFORMATION
========================================================= 
*/

SELECT * FROM silver.layoffs
WHERE total_laid_off IS NULL 
	AND percentage_laid_off IS NULL;

/* 
=========================================================
			    	  CHECK FOR NO STRING NULLS
========================================================= 
*/

SELECT *
FROM silver.layoffs
WHERE company = 'NULL'
   OR industry = 'NULL'
   OR country = 'NULL';


