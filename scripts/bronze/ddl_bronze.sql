/*
====================================================================
DDL Script: Create Bronze Table
====================================================================
Script Purpose:
 This script creates tables in the 'bronze' schema, dropping existing tables
 if they already exist.
 Run this script to re-define the DDL structure of 'bronze' table
====================================================================
*/

IF OBJECT_ID ('bronze.layoffs', 'U') IS NOT NULL
	DROP TABLE bronze.layoffs;
GO

CREATE TABLE bronze.layoffs (
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
