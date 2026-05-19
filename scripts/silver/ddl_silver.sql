/*
====================================================================
DDL Script: Create Silver Tables
====================================================================
Script Purpose:
  This script creates tables in the 'silver' schema, dropping existing tables
  if they already exist.
  Adding primary key for silver.layoffs + increasing NVARCHAR
  Run this script to re-define the DDL structure of 'silver' Tables
 ====================================================================
*/

IF OBJECT_ID('silver.layoffs', 'U') IS NOT NULL
	DROP TABLE silver.layoffs;
GO

CREATE TABLE silver.layoffs (
	layoff_id INT IDENTITY(1,1) PRIMARY KEY,
	company NVARCHAR(100),
	[location] NVARCHAR(100),
	industry NVARCHAR(100),
	total_laid_off INT,
	percentage_laid_off FLOAT,
	[date] DATE,
	stage NVARCHAR(100),
	country NVARCHAR(100),
	funds_raised_millions FLOAT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.layoffs_staging', 'U') IS NOT NULL
	DROP TABLE silver.layoffs_staging

CREATE TABLE silver.layoffs_staging (
	company NVARCHAR(50),
	[location] NVARCHAR(50),
	industry NVARCHAR(50),
	total_laid_off NVARCHAR(50),
	percentage_laid_off NVARCHAR(50),
	[date] NVARCHAR(50),
	stage NVARCHAR(50),
	country NVARCHAR(50),
	funds_raised_millions NVARCHAR(50)
);
GO
