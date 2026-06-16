-- Data Cleaning

use data_cleaning;

Select * from layoffs;

-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Null Value checks
-- 4. Remove any columns

-- 1. Remove duplicates

Create 	Table layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

Select * from layoffs_staging;

Select * ,
ROW_NUMBER() OVER(
PARTITION BY Company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS ROW_NUM
from layoffs_staging;


WITH duplicate_cte AS
(Select * ,
ROW_NUMBER() OVER(PARTITION BY Company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS ROW_NUM
from layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE ROW_NUM>1;

Select * from layoffs_staging
WHERE COMPANY= 'Ada';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select * from layoffs_staging2;


INSERT INTO layoffs_staging2
Select * ,
ROW_NUMBER() OVER(PARTITION BY Company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS ROW_NUM
from layoffs_staging;


Select * from layoffs_staging2
WHERE ROW_NUM >1;

SET SQL_SAFE_UPDATES = 0;

DELETE from layoffs_staging2
WHERE ROW_NUM >1;

Select * from layoffs_staging2;

-- STANDADIZING DATA

SELECT COMPANY, TRIM(COMPANY)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET COMPANY = TRIM(COMPANY);

SELECT DISTINCT INDUSTRY
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2
WHERE INDUSTRY LIKE 'Crypto%';


UPDATE layoffs_staging2
SET INDUSTRY = 'Crypto'
WHERE INDUSTRY LIKE 'Crypto%';

SELECT distinct country
FROM layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'USA'
where country like 'United States%';


SELECT *
FROM layoffs_staging2
where country like 'USA';


SELECT `date`,
STR_TO_DATE(`DATE`, '%m/%d/%Y')
FROM layoffs_staging2;

update layoffs_staging2
set `date` = STR_TO_DATE(`DATE`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off is null
AND PERCENTAGE_LAID_OFF IS NULL ;


SELECT layoffs_staging2
WHERE INDUSTRY IS NULL
OR INDUSTRY = '';

SELECT *
FROM layoffs_staging2
WHERE COMPANY= 'AIRBNB';

SELECT * FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.COMPANY= T2.COMPANY
	AND T1.LOCATION = T2.LOCATION
WHERE (T1.INDUSTRY IS NULL OR T2.INDUSTRY = '')
AND T2.INDUSTRY IS NOT NULL;

UPDATE layoffs_staging2 
SET INDUSTRY = NULL
WHERE INDUSTRY = '';

UPDATE  layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.COMPANY= T2.COMPANY
SET T1.INDUSTRY = T2.INDUSTRY
WHERE T1.INDUSTRY IS NULL
AND T2.INDUSTRY IS NOT NULL;

START TRANSACTION;

-- 2. Run your data cleaning query
UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry = '';


SELECT * FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.COMPANY= T2.COMPANY
	AND T1.LOCATION = T2.LOCATION
WHERE (T1.INDUSTRY IS NULL OR T2.INDUSTRY = '')
AND T2.INDUSTRY IS NOT NULL;

-- 3. CHECK YOUR DATA FIRST!
SELECT * FROM layoffs_staging2;

-- 4. IF YOU MADE A MISTAKE:
ROLLBACK;

DELETE  FROM layoffs_staging2
WHERE TOTAL_LAID_OFF IS NULL
AND PERCENTAGE_LAID_OFF IS NULL; 

ALTER TABLE layoffs_staging2
DROP COLUMN ROW_NUM;


