# Layoffs Analysis 2020-2023

## Project Description
This project analyses layoffs across various industries from 2020 to 2023 using SQL. The objective is to explore trends in layoffs over time, including seasonal patterns, the impact of funding on layoffs, and industry-specific volatility. The data was cleaned, transformed, and analysed using a series of SQL operations to derive meaningful insights.

## Steps Taken

### Data Cleaning
- **Removed Duplicates**: Utilised `ROW_NUMBER()` to identify and eliminate duplicate records from the dataset.
- **Standardised Data**: Normalised columns such as `industry`, `country`, and `date` to ensure consistency (e.g., converting all date fields to a uniform format).
- **Handled Null Values**: Investigated and managed `NULL` values and blank entries by either imputing missing data or removing records where critical fields were absent.

### Data Transformation
- Created staging tables to maintain a copy of the original dataset.
- Used SQL functions such as `TRIM()`, `MONTH()`, and `STR_TO_DATE()` to clean and transform data for better analysis.
- **Implemented Joins**: Used joins to populate missing values and cross-reference data within the dataset, ensuring data completeness.

### Exploratory Data Analysis (EDA)
- **Layoff Trends**: Examined total layoffs by `industry`, `country`, and `year` to identify overall trends.
- **Seasonal Analysis**: Classified layoffs by season using `CASE` statements to determine which periods were most prone to layoffs across industries.
- **Funding Impact**: Investigated the relationship between `funds_raised` and `percentage_laid_off` by developing a scoring system that ranks companies based on layoff percentage and funding levels.
- **Industry Volatility**: Measured layoff volatility using `STDDEV()` and compared year-over-year fluctuations to identify industries with the highest instability.

## Tools Used
- **SQL (MySQL)**: Primary tool for data cleaning, transformation, and analysis.
- **CTEs and Window Functions**: Utilised Common Table Expressions (CTEs) for modular analysis and window functions such as `RANK()` and `DENSE_RANK()` to rank industries based on various metrics.
- **Joins**: Applied joins to enrich the dataset by filling missing values and ensuring robust data integrity.

## Dataset
- **File**: `layoffs.csv`
- **Description**: The dataset contains records of layoffs from various companies between 2020 and 2023. It includes columns such as `company`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, and more.

## Key Insights

### Seasonal Layoffs
- Layoffs were more frequent during winter for industries such as consumer, retail, and finance.
- Some industries, including technology and healthcare, exhibited increased layoffs during spring and summer, indicating industry-specific variability.

### Funding Correlation
- Companies with higher funding generally had lower layoff percentages, suggesting that financial stability acts as a buffer against layoffs.
- Layoff percentages equal to 1 were excluded from the analysis to remove extreme outliers and ensure a more focused evaluation.
- A weighted scoring system confirmed the inverse correlation between funding levels and layoff rates.

### Industry Volatility
- Layoff volatility varied significantly year-on-year, with industries such as aerospace, fitness, and education demonstrating the highest instability.
- The analysis revealed that some industries consistently experienced high layoff volatility, particularly during economic downturns, while others maintained relative stability.

## Repository Structure
- `layoffs_analysis.sql` – Contains all SQL queries used for data cleaning, transformation, and analysis.
- `layoffs.csv` – Dataset used for the analysis.
- `README.md` – Project overview, including steps taken, tools used, and key insights derived from the data.

## How to Run
- Import the `layoffs` dataset into a MySQL database.
- Execute the SQL queries in `layoffs_analysis.sql` sequentially to reproduce the data cleaning, transformation, and analysis steps.
