SELECT * FROM netflix_titles;

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

/*Check total rows vs unique show IDs*/
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT show_id) AS unique_ids
FROM netflix_titles;

/*Remove duplicate record*/
DELETE FROM netflix_titles a
USING netflix_titles b
WHERE a.ctid > b.ctid
AND a.show_id = b.show_id;

/*Check Null Values*/
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

/*Fix Null Values*/
UPDATE netflix_titles SET director = 'Unknown' WHERE director IS NULL;
UPDATE netflix_titles SET casts = 'Unknown' WHERE casts IS NULL;
UPDATE netflix_titles SET country  = 'Unknown' WHERE country  IS NULL;
UPDATE netflix_titles SET rating   = 'Not Rated' WHERE rating IS NULL;
UPDATE netflix_titles SET duration = 'Unknown' WHERE duration IS NULL;

/*Exploratory Data Analysis*/
/*What is the split between Movies and TV Shows (count & percentage)?*/
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_share
FROM netflix_titles
GROUP BY type
ORDER BY total_titles DESC;

/*How has the number of titles added to Netflix changed year over year?*/
SELECT
	EXTRACT(YEAR FROM date_added) AS year_over,
	COUNT(*) AS total_titles
FROM
	netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_over
ORDER BY year_over

/*Which countries produce the most Netflix content? (Top 10)*/
SELECT country, COUNT(*) AS highest_content 
FROM netflix_titles
WHERE country <> 'Unknown'
GROUP BY country
ORDER BY highest_content DESC
LIMIT 10;

/*How does the distribution of Movies vs TV Shows vary across top countries?*/
SELECT type, country, COUNT(*) AS total_content 
FROM netflix_titles
WHERE country <> 'Unknown'
GROUP BY type, country
ORDER BY total_content DESC

/*What is the distribution of content by release year? Are newer titles dominating?*/
SELECT release_year, COUNT(*) AS total_content 
FROM netflix_titles
GROUP BY release_year
ORDER BY release_year DESC

/*What are the most common content ratings on Netflix, and how do they differ by type?*/
SELECT type, rating, COUNT(*) AS total_content 
FROM netflix_titles
GROUP BY type, rating
ORDER BY type, total_content DESC

/*Alter and update table*/
ALTER TABLE netflix_titles ADD COLUMN duration_minutes INT;

UPDATE netflix_titles
SET duration_minutes = NULLIF(SPLIT_PART(duration, ' ', 1), 'Unknown')::INT
WHERE type = 'Movie';

/*What is the average, minimum, and maximum duration of Movies?*/
SELECT
    ROUND(AVG(SPLIT_PART(duration, ' ', 1)::INT), 2) AS avg_duration_min,
    MAX(SPLIT_PART(duration, ' ', 1)::INT) AS max_duration_min,
    MIN(SPLIT_PART(duration, ' ', 1)::INT) AS min_duration_min
FROM netflix_titles
WHERE type = 'Movie'
	AND duration <> 'Unknown';

/*Which genres are most common on Netflix? (Top 10 categories)*/
SELECT
    TRIM(genre) AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
CROSS JOIN UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 10;

/*Top genre by type*/
SELECT
    type,
    TRIM(genre) AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
CROSS JOIN UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY type, genre
ORDER BY type, total_titles DESC;

/* % of Content Added in Last 5 Years*/
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 5)
        * 100.0 / COUNT(*), 2
    ) AS percent_recent_content
FROM netflix_titles;

/*Which 3 years saw the highest year-over-year growth in Netflix content additions?*/
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
        titles_added
            - LAG(titles_added) OVER (ORDER BY year) AS yoy_growth
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

/*Create view*/
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