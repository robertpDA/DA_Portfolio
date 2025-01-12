-- REAL ESTATE SALE PROJECT 01-21

-- 1. Remove duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank Values
-- 4. Remove Any Columns

SELECT *
FROM real_estate_01_21;

-- Creating staging table to keep the raw
CREATE TABLE real_estate_staging
LIKE real_estate_01_21;

INSERT real_estate_staging
SELECT *
FROM real_estate_01_21;

SELECT *
FROM real_estate_staging;

 -- Removing duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Serial Number`, `List Year`, `Date Recorded`, Town, Address) AS duplicates
FROM real_estate_staging;
 
WITH cte_duplicates AS
	(
    SELECT *,
	ROW_NUMBER() OVER(PARTITION BY `Serial Number`, `List Year`, `Date Recorded`, Town, Address) AS duplicates
	FROM real_estate_staging
    )
SELECT *
FROM cte_duplicates
WHERE duplicates > 1;

-- No Duplicates Found

-- STANDARDIZING DATA

SELECT *
FROM real_estate_staging;

-- Changing the date recorded column from text to date format
SELECT `Date Recorded`, str_to_date(`Date Recorded`, '%m/%d/%Y')
FROM real_estate_staging;

UPDATE real_estate_staging
SET `Date Recorded` = str_to_date(`Date Recorded`, '%m/%d/%Y');

-- Error Code 1411, Looking for null or empty values
SELECT *
FROM real_estate_staging
WHERE `Date Recorded` IS NULL or `Date Recorded` = '';

-- Serial Number 0 and 20280 rows are empty, deleting the rows
DELETE
FROM real_estate_staging
WHERE `Date Recorded` IS NULL or `Date Recorded` = '';

-- Update now worked, Date is in a good format
-- Updating the column from text to date

ALTER TABLE real_estate_staging
MODIFY COLUMN `Date Recorded` DATE
;

-- Standardizing Town Column, 1 Unknown town found
SELECT DISTINCT Town
FROM real_estate_staging;

SELECT *
FROM real_estate_staging
WHERE Town = '***Unknown***';

SELECT *
FROM real_estate_staging
WHERE Address = '18 MATHIEU LANE';

-- After further investigation the 'Unknown' Town is a duplicate of Serial Number 70086 from 2007 in East Hampton
-- Deleting the row

Delete
FROM real_estate_staging
WHERE Town = '***Unknown***';

-- InvestigatinG the non use code
SELECT DISTINCT `Non Use Code`
FROM real_estate_staging;

-- Single digit codes need to be replaced with its corresponding description
UPDATE real_estate_staging
SET `Non Use Code` = CASE 
    WHEN `Non Use Code` = '1' THEN '01 - Family'
    WHEN `Non Use Code` = '2' THEN '02 - Love and Affection'
    WHEN `Non Use Code` = '3' THEN '03 - Inter Corporation'
    WHEN `Non Use Code` = '4' THEN '04 - Correcting Deed'
    WHEN `Non Use Code` = '5' THEN '05 - Deed Date'
    WHEN `Non Use Code` = '6' THEN '06 - Portion of Property'
    WHEN `Non Use Code` = '7' THEN '07 - Change in Property'
    WHEN `Non Use Code` = '8' THEN '08 - Part Interest'
    WHEN `Non Use Code` = '9' THEN '09 - Tax'
    WHEN `Non Use Code` = '10' THEN '10 - A Will'
    WHEN `Non Use Code` = '11' THEN '11 - Court Order'
    WHEN `Non Use Code` = '12' THEN '12 - Non Buildable Lot'
    WHEN `Non Use Code` = '13' THEN '13 - Bankruptcy'
    WHEN `Non Use Code` = '14' THEN '14 - Foreclosure'
    WHEN `Non Use Code` = '15' THEN '15 - Government Agency'
    WHEN `Non Use Code` = '16' THEN '16 - Charitable Group'
    WHEN `Non Use Code` = '17' THEN '17 - Two Towns'
    WHEN `Non Use Code` = '18' THEN '18 - In Lieu Of Foreclosure'
    WHEN `Non Use Code` = '19' THEN '19 - Easement'
    WHEN `Non Use Code` = '20' THEN '20 - Cemetery'
    WHEN `Non Use Code` = '21' THEN '21 - Personal Property Exchange'
    WHEN `Non Use Code` = '22' THEN '22 - Money and Personal Property'
    WHEN `Non Use Code` = '23' THEN '23 - Zoning'
    WHEN `Non Use Code` = '24' THEN '24 - Plottage'
    WHEN `Non Use Code` = '25' THEN '25 - Other'
    WHEN `Non Use Code` = '26' THEN '26 - Rehabilitation Deferred'
    WHEN `Non Use Code` = '27' THEN '27 - Crumbling Foundation Assessment Reduction'
    WHEN `Non Use Code` = '28' THEN '28 - Use Assessment'
    WHEN `Non Use Code` = '29' THEN '29 - No Consideration'
    WHEN `Non Use Code` = '30' THEN '30 - Auction'
    ELSE `Non Use Code`
END;

-- Fixing a typo
SELECT *
FROM real_estate_staging
WHERE `Non Use Code` = '13 - Bankruptcy';

UPDATE real_estate_staging
SET `Non Use Code` = '13 - Bankruptcy'
WHERE `Non Use Code` = '13 - Bankrupcy';

-- Property type
SELECT DISTINCT `Property Type`
FROM real_estate_staging;

SELECT DISTINCT `Property Type`, COUNT( `Property Type`)
FROM real_estate_staging
GROUP BY `Property Type`;

-- Residential type
SELECT DISTINCT `Residential Type`, COUNT(`Residential Type`)
FROM real_estate_staging
GROUP BY `Residential Type`;

-- Found 6 rows where the Sales Ratio is not calculated by checking for 0s
-- Sales Ratio zero count - (Sale Amount zero count + Assessed Value 0 count) = 6

SELECT *
FROM real_estate_staging
WHERE `Sales Ratio` = 0
  AND `Assessed Value` != 0
  AND `Sale Amount` != 0;
  
UPDATE real_estate_staging
SET `Sales Ratio` = `Assessed Value` / `Sale Amount`
WHERE `Sales Ratio` = 0
  AND `Assessed Value` != 0
  AND `Sale Amount` != 0;
  
-- Rounding Sales Ratio
UPDATE real_estate_staging
SET `Sales Ratio` = ROUND(`Sales Ratio`,4);

-- Standardizing is done

-- Nulls and blanks
-- After checking all the columns one by one Address does have blanks, further investigation necessary

SELECT *
FROM real_estate_staging
WHERE `Address` IS NULL OR `Address` = '';

-- Where assessed value and the sale amount is 0, the listing needs to be deleted from database
DELETE
FROM real_estate_staging
WHERE `Sale Amount` = 0
AND `Assessed Value` = 0;

SELECT *
FROM real_estate_staging
ORDER BY 1;

-- Removing not needed columns
ALTER TABLE real_estate_staging
DROP COLUMN `OPM remarks`,
DROP COLUMN Location;

-- END OF DATA CLEANING

-- ANALYSIS 
-- 1. Identifying High-Performing Regions
-- 2. Sales Seasonality and Optimal Selling Times

-- EDA
SELECT *
FROM real_estate_staging;

-- Analyzing Non Use Codes whether to include them in the analysis as some indicate the transaction wasn't an open market sale
-- meaning the sale amount may not reflect true market value

-- non use codes one by one
SELECT `List Year`, `Date Recorded`, Town, `Assessed Value`, `Sale Amount`, `Sales Ratio`, `Non Use Code`, `Assessor Remarks`
FROM real_estate_staging
WHERE `Non Use Code` = '01 - Family';

SELECT *
FROM real_estate_staging
WHERE `Non Use Code` = '';

-- cities are in Connecticut
SELECT DISTINCT Town
FROM real_estate_staging;

-- after further analysis the sales with non use code will be excluded
-- the codes do not reflect open market transactions and distort metrics like the sales ratio
-- creating a temporary table without `Non Use Code` to investigate further

CREATE TEMPORARY TABLE ct_sales AS
SELECT `Serial Number`, `List Year`, `Date Recorded`, Town, `Assessed Value`, `Sale Amount`, `Sales Ratio`, `Property Type`, `Residential Type`, `Assessor Remarks`
FROM real_estate_staging
WHERE `Non Use Code` = '';

-- 1. Identifying High-Performing Regions
SELECT Town,
ROUND(avg(`Sales Ratio`),3)
FROM ct_sales
GROUP BY Town;

-- Hartford has an unusual high sales ratio 15.064
SELECT *
FROM ct_sales
WHERE Town = 'Hartford';

-- typo/outlier found in the Sale Amount (= 1)
-- total 5 rows of outliers found
SELECT *
FROM ct_sales
WHERE `Sales Ratio` < 0.01;

SELECT *
FROM ct_sales
WHERE `Sales Ratio` > 500;

-- Creating a final table for analysis
CREATE TABLE real_estate_analysis AS
SELECT `Serial Number`, `List Year`, `Date Recorded`, Town, `Assessed Value`, `Sale Amount`, `Sales Ratio`, `Property Type`, `Residential Type`, `Assessor Remarks`
FROM real_estate_staging
WHERE `Non Use Code` = ''
AND `Sales Ratio` != 0
AND `Sales Ratio` < 500
AND `Sales Ratio` > 0.01;

SELECT *
FROM real_estate_analysis;

-- 1. IDENTIFYING HIGH-PERFORMING REGIONS

SELECT Town,
    COUNT(*) AS transactions,
    ROUND(avg(`Sale Amount` / `Assessed Value`),3) as avg_sar
FROM real_estate_analysis
GROUP BY Town
HAVING transactions > 1000
ORDER BY avg_sar DESC
LIMIT 10;

-- above I am focusing on regions where properties are selling at a significant premium over theri assessed value
-- which can be an indicator of high demand (or under-assessment - this would require further analysis whether it was or not)
-- only towns with a substantial number of transactions are considered (> 1000)

-- analyzing avg years to sell, total transactios and SAR for these towns
WITH HighPerformingRegions AS (
    SELECT Town,
           COUNT(*) AS transactions,
           ROUND(AVG(`Sale Amount` / `Assessed Value`), 3) AS avg_sar
    FROM real_estate_analysis
    GROUP BY Town
    HAVING transactions > 1000
    ORDER BY avg_sar DESC
    LIMIT 10
)
SELECT 
    Town,
    ROUND(AVG(YEAR(`Date Recorded`) - `List Year`), 2) AS avg_years_to_sell,
    COUNT(*) AS total_transactions,
    ROUND(AVG(`Sale Amount` / `Assessed Value`), 3) AS avg_sar
FROM real_estate_analysis
WHERE Town IN (SELECT Town FROM HighPerformingRegions)
GROUP BY Town
ORDER BY avg_sar DESC;

-- calculating a weighted final score (85% SAR rank - 15% years to sell rank) to determine the best overall performers
-- weighted 15% for years to sell because only the year was available, limiting precision in time-to-sell calculations.
WITH HighPerformingRegions AS (
    SELECT Town,
           ROUND(AVG(`Sale Amount` / `Assessed Value`), 3) AS avg_sar,
           ROUND(AVG(YEAR(`Date Recorded`) - `List Year`), 2) AS avg_years_to_sell
    FROM real_estate_analysis
    GROUP BY Town
    HAVING COUNT(*) > 1000
    ORDER BY avg_sar DESC
    LIMIT 10
),
RankedRegions AS (
    SELECT Town,
           avg_sar,
           avg_years_to_sell,
           -- Assign rankings (1 = best)
           RANK() OVER (ORDER BY avg_sar DESC) AS sar_rank,
           RANK() OVER (ORDER BY avg_years_to_sell ASC) AS years_to_sell_rank -- Lower years to sell is better
    FROM HighPerformingRegions
)
SELECT Town,
       avg_sar,
       avg_years_to_sell,
       sar_rank,
       years_to_sell_rank,
       -- Combine rankings into a final score (lower score = better overall)
       ROUND((sar_rank * 0.85) + (years_to_sell_rank * 0.15), 2) AS final_score
FROM RankedRegions
ORDER BY final_score ASC; -- Lower scores are better

-- Final rank:
-- 1. Hartford, 2. Stamford, 3. Waterbury, 4. Bridgeport, 5. New Haven, 6. Killingly, 7. New Britain, 8. Plainfield, 9. Milford, 10. West Hartford
-- The top-ranked towns (Hartford, Stamford, Waterbury, etc.) are likely major cities or urban areas with high demand and robust real estate markets, driving higher SAR ratios and competitive selling times. Smaller towns like Killingly and Plainfield may stand out due to unique local factors like affordability or recent growth trends.


-- 2. SALES SEASONALITY AND OPTIMAL SELLING TIMES

-- based on the transaction count the optimal selling time is around summer, June being the best time, 2nd July, 3rd Aug
-- less sale occurs during winter and march
-- the avg sale is also higher during summer time
SELECT MONTH(`Date Recorded`),
	COUNT(*),
    ROUND(avg(`Sale Amount`),2) as avg_sale,
	RANK() OVER(ORDER BY COUNT(*) DESC) AS transaction_rank
FROM real_estate_analysis
GROUP BY MONTH(`Date Recorded`)
ORDER BY 1
;

-- The analysis reveals that the real estate market is strongest during the summer months (June, July, and August), with June ranking highest in transaction volume and average sale amount. This indicates heightened market activity and potentially increased demand during this period. Conversely, winter months (January, February, and March) show lower transaction volumes and average sale amounts, suggesting weaker market activity. Spring (April and May) and early autumn (September and October) display moderate performance, serving as transitional periods.

-- analysing this year by year for visualization
SELECT YEAR(`Date Recorded`),
	MONTH(`Date Recorded`),
	COUNT(*),
	RANK() OVER(PARTITION BY YEAR(`Date Recorded`) ORDER BY COUNT(*) DESC) AS ranking
FROM real_estate_analysis
GROUP BY YEAR(`Date Recorded`), MONTH(`Date Recorded`)
ORDER BY 1,2
;
-- 1 row typo found
-- New London List Year 2017 - Sale date 1999

-- analyzing the error
SELECT *
FROM real_estate_analysis
WHERE YEAR(`Date Recorded`) = 1999
;

SELECT *
FROM real_estate_analysis
WHERE Town = 'New London' AND YEAR(`Date Recorded`) = 2019
;
-- after further analyzis the sale date is most probably 2019
-- it is in pair with the property type, price and sales ratio for the year
-- modifying the date:
UPDATE real_estate_analysis
SET `Date Recorded` = '2019-04-05'
WHERE `Date Recorded` = '1999-04-05'
;

SELECT *
FROM real_estate_analysis
WHERE YEAR(`Date Recorded`) - `List Year` < 0
;
-- In the dataset, 41 rows have a Date Recorded earlier than the List Year, which is inconsistent with typical workflows where properties are listed before being sold. After investigation, these rows were deleted to ensure the integrity of the analysis
DELETE
FROM real_estate_analysis
WHERE YEAR(`Date Recorded`) - `List Year` < 0
;

-- 3. PRICE TRENDS YEAR BY YEAR
SELECT YEAR(`Date Recorded`),
	ROUND(avg(`Sale Amount`),2) as avg_sale,
	RANK() OVER(ORDER BY avg(`Sale Amount`) DESC) AS SaleByYear_ranking
FROM real_estate_analysis
GROUP BY YEAR(`Date Recorded`)
ORDER BY 1
;
-- This code analyzes average sale prices year by year, ranking each year based on the highest average sales. It provides insights into how external factors like economic events and market trends have influenced real estate prices over time.
-- 2001 (Rank 22): Lowest prices, likely due to the dot-com bubble burst and post-9/11 recession, which weakened the housing market.
-- 2006 (Rank 17): The market began cooling after years of growth, with early signs of the upcoming housing crisis.
-- 2008 (Rank 9): Great Recession impact; prices dropped significantly due to economic turmoil and mortgage crisis.
-- 2009 (Rank 18): Continued effects of the recession with low consumer confidence and increased foreclosures.
-- 2016 (Rank 15): Slower growth year amidst political and economic uncertainties, including state budget issues in Connecticut.
-- 2018 & 2019 (Ranks 13 & 14): Steady but cooling market as the recovery from the recession plateaued.
-- 2021 & 2022 (Ranks 2 & 1): Pandemic-driven housing boom with record-high prices fueled by low interest rates and high demand.
