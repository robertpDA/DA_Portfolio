-- WORLD LAYOFFS PROJECT

-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank Values
-- 4. Remove Any Columns

-- Create a table to keep our raw table 
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- DUPLICATES

-- Checking for duplicates with row number
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Identifying duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Creating a new table with row number to remove duplicates
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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert the data to new table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- deleting duplicates
DELETE
FROM layoffs_staging2
WHERE row_num = 2;


-- STANDARDIZING DATA

SELECT *
FROM layoffs_staging2
;

-- Checking company names with distinct looking for typos, space
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Updating it with TRIM
UPDATE layoffs_staging2
SET company = TRIM(company);

-- checking Industry and all the column names one by one
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

-- Standardizing crypto industry
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardizing country - usa
SELECT *
FROM layoffs_staging2
WHERE country = 'United States';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United Sta%';

-- Standardizing date
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- NULL AND BLANK VALUES

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Investigating and populating industry with joins
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Updating blanks to NULLS
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populating Nulls with joins
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- REMOVING NOT NEEDED COLUMNS/ROWS

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- removing the nulls
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- dropping the no longer needed row number column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

SELECT max(total_laid_off), max(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT min(`date`), max(`date`)
FROM layoffs_staging2;

SELECT industry, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Progression of layoffs / Rolling sum
SELECT substring(`date`,1,7) AS `MONTH`,
	sum(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT substring(`date`,1,7) AS `MONTH`,
	sum(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, sum(total_off) OVER(ORDER BY `MONTH`) as rolling_total
FROM Rolling_Total;

-- total lay offs per company / year
SELECT company, YEAR(`date`),  sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- top 5 most layoffs per company / year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`),  sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- Impact of funding on layoffs
-- Analyzing whether there is a correalation between the amount of funds raised and the numbers for companies.
-- Does higher funding reduce the likelihood of layoffs, or is there no clear relationship?

SELECT *
FROM layoffs_staging2;

SELECT company,
	sum(total_laid_off) AS total,
    avg(percentage_laid_off) AS percent,
    ROUND(avg(funds_raised_millions)) AS funds_raised
FROM layoffs_staging2
GROUP BY company
ORDER BY 3 DESC;

-- Using a scoring system to rank the companies based on both layoff % and funding amount
-- companies with lower layoff percentage and higher funding ranked first
WITH percentage_to_funds AS
(
SELECT company,
	sum(total_laid_off) AS total,
    avg(percentage_laid_off) AS percent,
    ROUND(avg(funds_raised_millions)) AS funds_raised
FROM layoffs_staging2
GROUP BY company
HAVING avg(percentage_laid_off) IS NOT NULL
	AND ROUND(avg(funds_raised_millions)) IS NOT NULL
), layoff_score AS
(
SELECT *,
DENSE_RANK() OVER(ORDER BY percent ASC) AS per_rank,
DENSE_RANK() OVER(ORDER BY funds_raised DESC) funds_rank
FROM percentage_to_funds
)
SELECT *,
per_rank + funds_rank AS score
FROM layoff_score
ORDER BY score ASC;

-- Using a weighted score to 60-40% split
-- 60% to layoff percentage is more closely associated how well the company is managing its workforce
-- 40% funding is still important but its relationship to layoffs might not be as direct
WITH percentage_to_funds AS
(
SELECT company,
	sum(total_laid_off) AS total,
    avg(percentage_laid_off) AS percent,
    ROUND(avg(funds_raised_millions)) AS funds_raised
FROM layoffs_staging2
GROUP BY company
HAVING avg(percentage_laid_off) IS NOT NULL
	AND ROUND(avg(funds_raised_millions)) IS NOT NULL
), layoff_score AS
(
SELECT *,
DENSE_RANK() OVER(ORDER BY percent ASC) AS per_rank,
DENSE_RANK() OVER(ORDER BY funds_raised DESC) funds_rank
FROM percentage_to_funds
)
SELECT *,
ROUND(0.6 * per_rank + 0.4 * funds_rank,2) AS weighted_score
FROM layoff_score
ORDER BY weighted_score ASC;


-- Idustry trends over time
-- examining the trend of layoffs in different industries over the years:
-- are certain industries more prone to layoffs during specific times?
-- which industries have shown the highest volatility in terms of layoffs, how does this compare year by year?


-- are certain industries more prone to layoffs during specific times?
SELECT *
FROM layoffs_staging2;

SELECT industry,
sum(total_laid_off) AS sum_laid_off,
substring(`date`,1,7) AS Y_m
FROM layoffs_staging2
GROUP BY industry, substring(`date`,1,7)
HAVING sum_laid_off IS NOT NULL AND Y_m IS NOT NULL
ORDER BY industry;

-- this shows the total layoffs of industry per 4 seasons
WITH sum_season_table AS
(
SELECT industry,
	sum(total_laid_off) AS sum_laid_off,
		CASE
			WHEN MONTH(`date`) IN (3,4,5) THEN 'Spring'
            WHEN MONTH(`date`) IN (6,7,8) THEN 'Summer'
            WHEN MONTH(`date`) IN (9,10,11) THEN 'Fall'
            WHEN MONTH(`date`) IN (1,2,12) THEN 'Winter'
            ELSE NULL
		END AS season
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND `date` IS NOT NULL
GROUP BY industry, season
)
SELECT industry,
	season,
	sum(sum_laid_off) AS total_laid_off
FROM sum_season_table
GROUP BY industry, season
ORDER BY sum(sum_laid_off) DESC;

-- Calculating and ranking layoff percentage of industry by season
WITH percent_season_table AS
(
    SELECT industry,
           AVG(percentage_laid_off) AS avg_percent_laid_off,
           CASE
               WHEN MONTH(`date`) IN (3, 4, 5) THEN 'Spring'
               WHEN MONTH(`date`) IN (6, 7, 8) THEN 'Summer'
               WHEN MONTH(`date`) IN (9, 10, 11) THEN 'Fall'
               WHEN MONTH(`date`) IN (1, 2, 12) THEN 'Winter'
               ELSE NULL
           END AS season
    FROM layoffs_staging2
    WHERE percentage_laid_off IS NOT NULL
		AND percentage_laid_off != 1
		AND `date` IS NOT NULL
    GROUP BY industry, season
)
SELECT industry,
       season,
       ROUND(avg_percent_laid_off, 2) AS avg_percentage_laid_off,
       DENSE_RANK() OVER(PARTITION BY industry ORDER BY avg_percent_laid_off DESC) AS percentrank
FROM percent_season_table
ORDER BY industry;

-- counts of the seasons with the most layoffs
-- 1. Spring 12
-- 2. Fall 8
-- 3. Winter 6
-- 4. Summer 5
WITH percent_season_table AS
(
    SELECT industry,
           AVG(percentage_laid_off) AS avg_percent_laid_off,
           CASE
               WHEN MONTH(`date`) IN (3, 4, 5) THEN 'Spring'
               WHEN MONTH(`date`) IN (6, 7, 8) THEN 'Summer'
               WHEN MONTH(`date`) IN (9, 10, 11) THEN 'Fall'
               WHEN MONTH(`date`) IN (1, 2, 12) THEN 'Winter'
               ELSE NULL
           END AS season
    FROM layoffs_staging2
    WHERE percentage_laid_off IS NOT NULL
		AND percentage_laid_off != 1
		AND `date` IS NOT NULL
    GROUP BY industry, season
), ranked_table AS
(
SELECT industry,
       season,
       ROUND(avg_percent_laid_off, 2) AS avg_percentage_laid_off,
       DENSE_RANK() OVER(PARTITION BY industry ORDER BY avg_percent_laid_off DESC) AS percentrank
FROM percent_season_table
ORDER BY industry
) SELECT season, count(season)
FROM ranked_table
WHERE percentrank = 1
GROUP BY season
ORDER BY count(season) DESC;

-- calculating the standard deviation of the layoff percentages by industry over the seasons
-- this shows which industries experience the most fluctuations across seasons indicating higher volatility
WITH percentage_season_table AS
(
    SELECT industry,
           percentage_laid_off,
           CASE
               WHEN MONTH(`date`) IN (3, 4, 5) THEN 'Spring'
               WHEN MONTH(`date`) IN (6, 7, 8) THEN 'Summer'
               WHEN MONTH(`date`) IN (9, 10, 11) THEN 'Fall'
               WHEN MONTH(`date`) IN (1, 2, 12) THEN 'Winter'
               ELSE NULL
           END AS season
    FROM layoffs_staging2
    WHERE percentage_laid_off IS NOT NULL AND `date` IS NOT NULL AND percentage_laid_off != 1
), volatility_table AS
(
    SELECT industry,
           season,
           STDDEV(percentage_laid_off) AS layoff_volatility
    FROM percentage_season_table
    GROUP BY industry, season
)
SELECT industry,
       season,
       ROUND(layoff_volatility, 2) AS volatility,
       RANK() OVER (ORDER BY layoff_volatility DESC) AS volatility_rank
FROM volatility_table
ORDER BY volatility DESC;


-- which industries have shown the highest volatility in terms of layoffs, how does this compare year by year?
-- examining layoff patterns year by year for different industries by calculating the avg layoff percentage
SELECT industry,
	ROUND(avg(percentage_laid_off),2),
    YEAR(`date`)
FROM layoffs_staging2
WHERE percentage_laid_off != 1
GROUP BY industry, YEAR(`date`)
ORDER BY ROUND(avg(percentage_laid_off),2) DESC, YEAR(`date`);

-- using standard deviation to understand how much layoff percentages fluctuate withing a given year across different industries
WITH industry_yearly_stats AS (
    SELECT industry,
           YEAR(`date`) AS year,
           ROUND(AVG(percentage_laid_off), 2) AS avg_percent_laid_off,
           ROUND(STDDEV(percentage_laid_off), 2) AS stddev_percent_laid_off
    FROM layoffs_staging2
    WHERE percentage_laid_off IS NOT NULL
          AND percentage_laid_off != 1
          AND `date` IS NOT NULL
    GROUP BY industry, YEAR(`date`)
)
SELECT industry,
       year,
       avg_percent_laid_off,
       stddev_percent_laid_off,
       RANK() OVER (PARTITION BY year ORDER BY stddev_percent_laid_off DESC) AS volatility_rank
FROM industry_yearly_stats
ORDER BY year, volatility_rank;