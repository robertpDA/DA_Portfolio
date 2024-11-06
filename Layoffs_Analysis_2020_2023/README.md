# Layoffs Analysis 2020-2023

## Project Description
This project analyzes layoffs across various industries from 2020 to 2023 using SQL. The goal is to explore trends in layoffs over time, including seasonal patterns, the impact of funding on layoffs, and industry-specific volatility. The data was cleaned, transformed, and analyzed using a series of SQL operations to derive meaningful insights.

## Steps Taken

1. **Data Cleaning**:
   - **Removed Duplicates**: Used `ROW_NUMBER()` to identify and remove duplicate records from the dataset.
   - **Standardized Data**: Standardized columns such as `industry`, `country`, and `date` to ensure consistency (e.g., converting all date fields to the same format).
   - **Handled Null Values**: Investigated and handled `NULL` values and blank entries by either filling them where possible or removing records where critical fields were missing.

2. **Data Transformation**:
   - Created staging tables to maintain a copy of the original dataset.
   - Used various SQL functions like `TRIM()`, `MONTH()`, and `STR_TO_DATE()` to clean and transform data for better analysis.
   - **Used Joins**: Implemented joins to populate missing values and to cross-reference data within the dataset, ensuring data completeness.

3. **Exploratory Data Analysis (EDA)**:
   - **Layoff Trends**: Analyzed total layoffs by `industry`, `country`, and `year` to identify overall trends.
   - **Seasonal Analysis**: Classified layoffs by season using `CASE` statements to explore which seasons were most prone to layoffs across industries.
   - **Funding Impact**: Investigated the relationship between `funds_raised` and `percentage_laid_off` by creating a scoring system that ranks companies based on layoff percentage and funds raised.
   - **Industry Volatility**: Calculated the volatility of layoffs (using `STDDEV`) by industry and compared volatility year-over-year to determine which industries had the highest layoff instability.

## Tools Used
- **SQL (MySQL)**: Main tool used for data cleaning, transformation, and analysis.
- **CTEs and Window Functions**: Employed Common Table Expressions (CTEs) for modular analysis and window functions like `RANK()` and `DENSE_RANK()` to rank industries based on various metrics.
- **Joins**: Used joins to fill missing values and cross-check industry data, ensuring more robust data integrity.

## Key Insights
- **Seasonal Layoffs**: Layoffs were more frequent during winter for industries such as consumer, retail, and finance. However, some industries like technology and healthcare also showed increased layoffs during spring and summer, indicating variability based on industry-specific factors.
- **Funding Correlation**: Companies with higher funding tended to have a lower percentage of layoffs, suggesting that better financial standing can act as a buffer against layoffs. Layoff percentages equal to 1 were excluded from the analysis to provide a more focused view without including extreme edge cases. This was confirmed through a weighted scoring system that ranked companies based on both layoff percentage and funds raised.
- **Industry Volatility**: The volatility of layoffs varied significantly year-over-year, with industries like aerospace, fitness, and education showing the highest instability in layoff percentages. The analysis revealed that some industries consistently experienced high volatility, especially during economic downturns, while others demonstrated more stability.

## Repository Structure
- `layoffs_analysis.sql`: Contains all SQL queries used for data cleaning, transformation, and analysis.
- `README.md`: Project overview, including steps taken, tools used, and key insights derived from the data.

## How to Run
- Import the `layoffs` dataset into a MySQL database.
- Run the SQL queries in `layoffs_analysis.sql` in sequence to reproduce the data cleaning, transformation, and analysis steps.
