/*
Create Database and Schemas

Script Purpose:
  This script creates a new database named 'World_layoffs' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up two schemas
  within the database: 'bronze', 'silver'.

WARNING:
  Running this script will drop the entire 'World_layoffs' database if it exists.
*/

USE master;
GO


/*
=========================================================
	  DROP AND RECREATE THE 'World_layoffs' DATABASE
=========================================================
*/

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'World_layoffs')
BEGIN
	ALTER DATABASE World_layoffs SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE World_layoffs;
END;
GO

/*
=========================================================
		      CREATE THE 'World_layoffs' DATABASE
=========================================================
*/
CREATE DATABASE World_layoffs;
GO

USE World_layoffs;
GO

/*
=========================================================
				          	CREATE SCHEMAS
=========================================================
*/

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO
