/* 
==========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==========================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
  It performs the following actions:
	- Loads raw data from bronze.layoffs into silver.layoffs_staging
	- Removes duplicates
	- Cleans and standardizes data
	- Fills missing industry values (If we already have record in the bronze.layoffs table Else It's NULL)
	- Removes invalid rows
	- Loads transformed data into silver.layoffs

Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC silver.load_silver
==========================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Silver Layer';
		PRINT '==============================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.layoffs_staging';
		TRUNCATE TABLE silver.layoffs_staging;
		PRINT '>> Inserting Table: silver.layoffs_staging';
		INSERT INTO silver.layoffs_staging (
			company,
			[location],
			industry,
			total_laid_off,
			percentage_laid_off,
			[date],
			stage,
			country,
			funds_raised_millions
		)
		SELECT
			company,
			[location],
			industry,
			total_laid_off,
			percentage_laid_off,
			[date],
			stage,
			country,
			funds_raised_millions
		FROM bronze.layoffs;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------';
		/* 
		=========================================================
						 REMOVE DUPLICATES
		========================================================= 
		*/
		SET @start_time = GETDATE();
		PRINT '>> Removing duplicate rows';

		WITH CTE_duplicity AS
		(
			SELECT *, 	
			ROW_NUMBER() OVER(
				PARTITION BY 
					company, 
					[location], 
					industry, 
					total_laid_off, 
					percentage_laid_off, 
					[date], 
					stage, 
					country, 
					funds_raised_millions 
		   		ORDER BY company
				) AS row_num
			FROM silver.layoffs_staging
		)

		DELETE 
		FROM CTE_duplicity
		WHERE row_num > 1;
		PRINT '--------------------------------';
		/* 
		=========================================================
				REMOVE WHITESPACES AND NORMALIZE DATA
		========================================================= 
		*/

		PRINT '>> Standardizing and cleaning data';

		UPDATE silver.layoffs_staging 
		SET
			company = TRIM(company),
			[location] = TRIM([location]),
			industry = 
				CASE
					WHEN NULLIF(TRIM(industry), 'NULL') LIKE 'Crypto%' THEN 'Crypto'
					ELSE NULLIF(TRIM(industry), 'NULL')
				END,
			total_laid_off = NULLIF(TRIM(total_laid_off), 'NULL'),
			percentage_laid_off = NULLIF(TRIM(percentage_laid_off), 'NULL'),
			[date] = TRIM([date]),
			[stage] = TRIM(stage),
			country = 	
			CASE
				WHEN TRIM(country) LIKE 'United States%' THEN 'United States'
				ELSE TRIM(country)
			END,
			funds_raised_millions = NULLIF(TRIM(funds_raised_millions), 'NULL');
		PRINT '--------------------------------';
		/* 
		=========================================================
						FILL MISSING INDUSTRY NAMES
		========================================================= 
		*/

		PRINT '>> Filling missing industry values';

		UPDATE st1
		SET st1.industry = st2.industry
		FROM silver.layoffs_staging AS st1
		INNER JOIN (
			SELECT
				company,
				[location],
				MAX(industry) AS industry
			FROM silver.layoffs_staging
			WHERE industry IS NOT NULL
			GROUP BY company, [location]
		) AS st2
			ON st1.company = st2.company
			AND st1.[location] = st2.[location]
		WHERE st1.industry IS NULL;
		PRINT '--------------------------------';
		/* 
		=========================================================
				REMOVE ROWS WITH NO LAYOFF INFORMATION
		========================================================= 
		*/

		PRINT '>> Removing rows with no layoff information';

		DELETE 
		FROM silver.layoffs_staging
		WHERE total_laid_off IS NULL 
			AND percentage_laid_off IS NULL;
		PRINT '--------------------------------';
		/* 
		=========================================================
					LOAD CLEAN DATA INTO FINAL TABLE
		========================================================= 
		*/

		PRINT '>> Loading cleaned data into silver.layoffs';
		PRINT '--------------------------------';

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.layoffs';
		TRUNCATE TABLE silver.layoffs;
		PRINT '>> Inserting Table: silver.layoffs';
		INSERT INTO silver.layoffs(
			company,
			[location],
			industry,
			total_laid_off,
			percentage_laid_off,
			[date],
			stage,
			country,
			funds_raised_millions
		)
		SELECT
			company,
			[location],
			industry,
			TRY_CONVERT(INT, total_laid_off) AS total_laid_off,
			TRY_CONVERT(FLOAT, percentage_laid_off) AS percentage_laid_off,
			TRY_CONVERT(DATE, [date]) AS [date],
			stage,
			country,
			TRY_CONVERT(FLOAT, funds_raised_millions) AS funds_raised_millions
		FROM silver.layoffs_staging;
		SET @end_time = GETDATE();
		PRINT '>>Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @batch_end_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Silver Layer is Completed';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==============================================';

	END TRY
	BEGIN CATCH
		PRINT '==============================================';
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================================';
	END CATCH
END

