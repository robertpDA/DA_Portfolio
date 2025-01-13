# Real Estate Sales Analysis (2001-2021)

## Project Description
This project analyzed a Connecticut real estate sales dataset from 2001–2021, focusing on identifying high-performing regions, analyzing seasonal trends, and exploring price fluctuations year by year. The data underwent rigorous cleaning and standardization, ensuring the results were reliable and actionable. Key findings include summer as the optimal selling period, Hartford and Stamford as top-performing towns, and a pandemic-driven price surge in 2021–2022. SQL techniques such as CTEs, window functions, and data transformation were employed to derive insights.

---

## Steps Taken

1. **Data Cleaning**:
   - **Removed Duplicates**: Used `ROW_NUMBER()` to identify and confirm there were no duplicate records in the dataset.
   - **Standardized Data**:
     - Converted `Date Recorded` from text to date format.
     - Standardized columns like `Town` and `Non Use Code`, ensuring consistent and meaningful values.
   - **Handled Null Values**:
     - Removed rows where critical fields like `Sale Amount` or `Assessed Value` were zero or missing.
     - Fixed invalid or missing `Non Use Code` entries.
   - **Column Removal**: Dropped irrelevant columns (`OPM Remarks`, `Location`) to focus the analysis.

2. **Data Transformation**:
   - Created a staging table to preserve the original dataset.
   - Removed non-market transactions by excluding rows with `Non Use Codes`, which distorted market metrics like `Sales Ratio`.
   - Corrected outliers:
     - Addressed extreme `Sales Ratio` values, such as a sale amount of `1` in Hartford.
     - Fixed rows where `Date Recorded` was inconsistent with `List Year` (e.g., sales recorded before their listing year).

3. **Exploratory Data Analysis (EDA)**:
   - **High-Performing Regions**:
     - Ranked towns using a weighted scoring system:
       - **85% SAR Rank**: Based on Sale Amount/Assessed Value (SAR) ratio.
       - **15% Years-to-Sell Rank**: Adjusted for average selling times.
     - Identified the top 10 towns with high SAR and competitive selling times.
   - **Sales Seasonality**:
     - Analyzed transaction volumes and average sale amounts across months.
     - Identified summer (June, July, August) as the optimal selling period.
   - **Price Trends**:
     - Examined yearly average sale prices and the influence of major economic events (e.g., 2008 recession, 2021 pandemic-driven housing boom).

---

## Tools Used
- **SQL (MySQL)**: Primary tool for data cleaning, transformation, and analysis.
- **CTEs and Window Functions**: Used for modular analysis, ranking, and calculating metrics like average SAR.
- **Temporary Tables**: Facilitated focused analysis by isolating clean datasets.

---

## Dataset
- **File**: `Real_Estate_Sales_2001-2021_GL.csv`
   - **Description**: A comprehensive dataset containing detailed real estate sales records from Connecticut for the years 2001-2021.
   - **File Size**: Approximately 120 MB. Due to its size, it has been uploaded using Git Large File Storage (LFS).
   - **Fields Included**:
     - `List Year`
     - `Date Recorded`
     - `Town`
     - `Sale Amount`
     - `Assessed Value`
     - `Sales Ratio`
     - `Non Use Code`

---

## Key Insights

### High-Performing Regions
- Towns like **Hartford** and **Stamford** ranked highest, driven by high demand and robust market dynamics. Hartford stood out for its high SAR, while Stamford showed strong transaction volume and competitive selling times.
- Smaller towns like **Killingly** and **Plainfield** were notable for their affordability and recent growth, suggesting niche markets or emerging demand trends.
- **Top 10 towns (in order)**: Hartford, Stamford, Waterbury, Bridgeport, New Haven, Killingly, New Britain, Plainfield, Milford, West Hartford.
- **Methodology**: Rankings were based on the **Sale Amount/Assessed Value (SAR)** ratio (85% weight) and average years to sell (15% weight). The lower weight for years to sell reflects the limitation of only having the listing year, not the full date, which reduced precision in the calculation.

### Sales Seasonality
#### Optimal Selling Periods:
- **Summer months (June, July, August)** exhibited the highest transaction volumes and average sale prices, making them the best time to sell.
- June ranked highest overall, followed by July and August, indicating peak market activity during these months.

#### Low Activity Periods:
- **Winter months (January, February, March)** had the lowest market activity, characterized by reduced transaction counts and lower average sale prices.

#### Moderate Periods:
- **Spring (April, May)** and **early autumn (September, October)** saw moderate activity, serving as transitions between high and low seasons.

#### Interpretation:
- Summer demand may be linked to **favorable weather**, **family relocation timing**, and **school planning**, while winter lulls could result from **holiday distractions** and **harsher weather**.

- **Price Trends**:
  - **2001–2007 Growth**: Steady price increases peaked in 2007 due to the housing bubble fueled by easy credit and high demand.
  - **2008–2009 Drop**: The financial crisis caused a sharp decline in prices, with 2009 marking the lowest values post-bubble.
  - **2010–2015 Recovery**: Gradual recovery followed, though uneven due to Connecticut's fiscal challenges and population outmigration.
  - **2016 Dip**: Prices fell slightly, reflecting ongoing state-specific economic difficulties.
  - **2020–2022 Surge**: Pandemic-driven demand for suburban housing and low mortgage rates led to record-high prices, with 2022 as the peak.

---

## Repository Structure
- `Real_Estate_Sales_2001-2021_GL.sql`: Contains all SQL queries used for data cleaning, transformation, and analysis.
- `Real_Estate_Sales_2001-2021_GL.csv`: Dataset used for the analysis. This file was uploaded using Git LFS due to its size.
- `README.md`: Project overview, including steps taken, tools used, and key insights derived from the data.

---

## How to Run
1. Ensure you have **Git LFS** installed: [Git LFS Installation Guide](https://git-lfs.github.com/).
2. Clone the repository. Git LFS will automatically handle the large dataset.
3. Import the `Real_Estate_Sales_2001-2021_GL.csv` dataset into a MySQL database.
4. Run the SQL queries in `Real_Estate_Sales_2001-2021_GL.sql` sequentially to replicate the data cleaning and analysis.
5. Review the results and insights from the output.
