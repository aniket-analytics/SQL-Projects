# SQL-Project-Netflix-Content-Analysis

## Project Overview

**Project Title**: Netflix Content Analysis  
**Level**: Beginner–Intermediate  
**Database**: `netflix_db`  
**Table**: `netflix_titles`

This project is designed to demonstrate SQL skills used by data analysts to **clean, explore, and analyze Netflix content data**.  
The analysis focuses on understanding content distribution, growth trends, genres, countries, ratings, and durations using **PostgreSQL**.

---

## Objectives

1. **Set up Netflix database** and inspect dataset structure
2. **Data Cleaning**: Handle duplicates, missing values, and inconsistent formats
3. **Exploratory Data Analysis (EDA)**: Analyze content trends and distributions
4. **Advanced SQL Analysis**: Apply window functions and string operations
5. **Portfolio Showcase**: Demonstrate SQL proficiency for analyst roles

---

## Dataset Information

- Dataset: Netflix Titles Dataset
- Records: ~8,800
- Content Types: Movies and TV Shows
- Key Columns:
  - show_id
  - type
  - title
  - director
  - casts
  - country
  - date_added
  - release_year
  - rating
  - duration
  - listed_in
  - description

---

## Project Structure
- **Database Creation**: The project starts by creating a database named `netflix_db`.
- **Table Creation**: A table named `netflix_titles` is created to store the netflix data. The table structure includes columns for show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description.

```sql
CREATE DATABASE netflix_db;

CREATE TABLE netflix_titles (
    show_id        VARCHAR(10) PRIMARY KEY,
    type           VARCHAR(10),
    title          TEXT,
    director       TEXT,
    cast           TEXT,
    country        TEXT,
    date_added     DATE,
    release_year   INT,
    rating         VARCHAR(10),
    duration       VARCHAR(20),
    listed_in      TEXT,
    description    TEXT
);
```

---

## 1. Data Profiling

### View dataset
```sql
SELECT * FROM netflix_titles;
```

### Check total rows vs unique show IDs
```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT show_id) AS unique_ids
FROM netflix_titles;
```
## 2.Data Cleaning

### Remove duplicate records
```sql
DELETE FROM netflix_titles a
USING netflix_titles b
WHERE a.ctid > b.ctid
AND a.show_id = b.show_id;
```

### Check Missing Values
```sql
SELECT
    COUNT(*) FILTER (WHERE show_id IS NULL) AS missing_show_id,
    COUNT(*) FILTER (WHERE type IS NULL) AS missing_type,
    COUNT(*) FILTER (WHERE title IS NULL) AS missing_title,
    COUNT(*) FILTER (WHERE director IS NULL) AS missing_director,
    COUNT(*) FILTER (WHERE casts IS NULL) AS missing_casts,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country,
    COUNT(*) FILTER (WHERE date_added IS NULL) AS missing_date_added,
    COUNT(*) FILTER (WHERE release_year IS NULL) AS missing_year,
    COUNT(*) FILTER (WHERE rating IS NULL) AS missing_rating,
    COUNT(*) FILTER (WHERE duration IS NULL) AS missing_duration,
    COUNT(*) FILTER (WHERE listed_in IS NULL) AS missing_listed,
    COUNT(*) FILTER (WHERE description IS NULL) AS missing_description
FROM netflix_titles;
```
### Replace NULL values
```sql
UPDATE netflix_titles SET director = 'Unknown' WHERE director IS NULL;
UPDATE netflix_titles SET casts = 'Unknown' WHERE casts IS NULL;
UPDATE netflix_titles SET country = 'Unknown' WHERE country IS NULL;
UPDATE netflix_titles SET rating = 'Not Rated' WHERE rating IS NULL;
UPDATE netflix_titles SET duration = 'Unknown' WHERE duration IS NULL;
```

## 3. Exploratory Data Analysis (EDA)
### a. Movies vs TV Shows (count & percentage)
```sql
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_share
FROM netflix_titles
GROUP BY type
ORDER BY total_titles DESC;
```

### b. Year-over-year content additions
```sql
SELECT
    EXTRACT(YEAR FROM date_added) AS year_over,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_over
ORDER BY year_over;
```

### c. Top 10 content-producing countries
```sql
SELECT
    country,
    COUNT(*) AS highest_content
FROM netflix_titles
WHERE country <> 'Unknown'
GROUP BY country
ORDER BY highest_content DESC
LIMIT 10;
```

### d. Movies vs TV Shows distribution by country
```sql
SELECT
    type,
    country,
    COUNT(*) AS total_content
FROM netflix_titles
WHERE country <> 'Unknown'
GROUP BY type, country
ORDER BY total_content DESC;
```

### e. Content distribution by release year
```sql
SELECT
    release_year,
    COUNT(*) AS total_content
FROM netflix_titles
GROUP BY release_year
ORDER BY release_year DESC;
```

### f. Rating distribution by content type
```sql
SELECT
    type,
    rating,
    COUNT(*) AS total_content
FROM netflix_titles
GROUP BY type, rating
ORDER BY type, total_content DESC;
```

## 4. Duration Analysis
### Add numeric duration column and Add numeric duration column
```sql
ALTER TABLE netflix_titles ADD COLUMN duration_minutes INT;

UPDATE netflix_titles
SET duration_minutes = NULLIF(SPLIT_PART(duration, ' ', 1), 'Unknown')::INT
WHERE type = 'Movie';

```
### Movie duration statistics
```sql
SELECT
    ROUND(AVG(duration_minutes), 2) AS avg_duration_min,
    MAX(duration_minutes) AS max_duration_min,
    MIN(duration_minutes) AS min_duration_min
FROM netflix_titles
WHERE type = 'Movie';
```

## 5. Genre Analysis
### Top 10 genres
```sql
SELECT
    TRIM(genre) AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
CROSS JOIN UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 10;
```
### Top genres by content type
```sql
SELECT
    type,
    TRIM(genre) AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
CROSS JOIN UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY type, genre
ORDER BY type, total_titles DESC;
```

## 6. Advanced SQL Analysis
### Percentage of content released in last 5 years
```sql
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5)
        * 100.0 / COUNT(*), 2
    ) AS percent_recent_content
FROM netflix_titles;
```

### Year-over-Year growth analysis
```sql
WITH yearly_content AS (
    SELECT
        EXTRACT(YEAR FROM date_added) AS year,
        COUNT(*) AS titles_added
    FROM netflix_titles
    WHERE date_added IS NOT NULL
    GROUP BY year
),
yoy_growth AS (
    SELECT
        year,
        titles_added,
        titles_added - LAG(titles_added) OVER (ORDER BY year) AS yoy_growth
    FROM yearly_content
)
SELECT
    year,
    titles_added,
    yoy_growth
FROM yoy_growth
WHERE yoy_growth IS NOT NULL
ORDER BY yoy_growth DESC
LIMIT 3;
```

## 7. Create Cleaned View
```sql
CREATE VIEW netflix_cleaned AS
SELECT
    show_id,
    type,
    title,
    COALESCE(director, 'Unknown') AS director,
    COALESCE(casts, 'Unknown') AS casts,
    COALESCE(country, 'Unknown') AS country,
    date_added,
    release_year,
    COALESCE(rating, 'Not Rated') AS rating,
    duration,
    listed_in,
    description
FROM netflix_titles;
```

## Key Findings
Movies dominate Netflix’s catalog, though TV Shows have grown rapidly
Content additions peaked in specific expansion years
The US and India are top content-producing countries
Drama and International genres are most common
Most Netflix content has been released in recent years

## SQL Concepts Used
Data cleaning & preprocessing
Aggregate functions
Window functions (LAG)
CTEs
String manipulation
Conditional aggregation
Date & time analysis
View creation

## Conclusion
This project demonstrates a complete SQL-only data analysis workflow, from raw data cleaning to advanced analytics. It highlights practical SQL skills required for real-world data analyst roles.

## Author – Aniket Yadav

This project is part of my data analytics portfolio.

LinkedIn: https://www.linkedin.com/in/aniket-yadav-/
Email: aniket.analytics1210@gmail.com
