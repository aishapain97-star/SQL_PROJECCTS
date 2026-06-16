-- Exploratory Data Analysis

Use Data_cleaning;

Select * from layoffs_staging2;

Select MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs_staging2;

SELECT *
from layoffs_staging2
WHERE  percentage_laid_off =1 
ORDER BY funds_raised_millions DESC;



SELECT COMPANY, SUM(TOTAL_LAID_OFF)
FROM layoffs_staging2
group by COMPANY
ORDER BY 2 DESC;

SELECT substring(`DATE`, 1,7) AS `MONTH`, SUM(TOTAL_LAID_OFF)
FROM layoffs_staging2
WHERE Substring(`DATE`, 1,7)  IS NOT NULL
group by `MONTH`
ORDER BY 1 ASC;

WITH ROLLING_TOTAL AS (
SELECT substring(`DATE`, 1,7) AS `MONTH`, SUM(TOTAL_LAID_OFF) AS TOTAL_OFF
FROM layoffs_staging2
WHERE Substring(`DATE`, 1,7)  IS NOT NULL
group by `MONTH`
ORDER BY 1 ASC)
SELECT  `MONTH`, total_off, SUM(TOTAL_OFF) OVER (ORDER BY `MONTH`) AS ROLLING_TOTAL
FROM ROLLING_TOTAL;


SELECT COMPANY, YEAR(`DATE`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY COMPANY, YEAR(`DATE`)
ORDER BY 3 desc;


WITH COMPANY_YEAR (COMPANY, YEARS, TOTAL_LAID_OFF )AS (
SELECT COMPANY, YEAR(`DATE`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY COMPANY, YEAR(`DATE`)
), COMPANY_YEAR_RANK AS
(
SELECT * ,
DENSE_RANK() OVER(PARTITION BY YEARS ORDER BY TOTAL_LAID_OFF DESC) AS RANKING
FROM COMPANY_YEAR
WHERE YEARS IS NOT NULL
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANKING <= 5;


