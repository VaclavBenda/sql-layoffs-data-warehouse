/* 
==========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==========================================================================
Script Purpose:
 This stored procedure loads data into the 'bronze' layers' schema from external CSV files.
 It performs the following actions:
 - Truncates the bronze tables before loading data
 - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

 Parameters:
	None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
 EXEC bronze.load_bronze
==========================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME
	BEGIN TRY
		SET @start_time = GETDATE()
		PRINT '==============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==============================================';

		PRINT '>> Truncating Table: bronze.layoffs';
		TRUNCATE TABLE bronze.layoffs;
	
		PRINT '>> Inserting Data Into: bronze.layoffs';
		BULK INSERT bronze.layoffs
		FROM 'C:\Users\vaske\Downloads\layoffs.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '--------------------------------';

	END TRY
	BEGIN CATCH
		PRINT '==============================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================================';
	END CATCH
END
