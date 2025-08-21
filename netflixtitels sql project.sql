---- netflix project questions (table: netflixtitels)

-- 1  count how many movies and tv shows are available.
select type, count(*) as total_count from netflixtitels group by type

-- 2  find the top 5 countries with the most titles.
select top 5 country, count(*) as total_titles from netflixtitels group by country order by total_titles desc 

--- 3 get the total number of titles released each year.
select release_year, count(*) as total_titles from netflixtitels group by release_year order by release_year desc

--- 4 show the average title duration for movies only.
select avg(cast(replace(duration, ' min', '') as int)) as avg_duration from netflixtitels where type = 'Movie'

--- 5 list all titles released in the same year as 'breaking bad'.
select title, release_year from netflixtitels where release_year = 
( select release_year from netflixtitels where title = 'breaking bad')

--- 6  get the latest added title for each country 
select country,title,date_added from(
select country,title,date_added,row_number() over(partition by country order by date_added desc) as rn from  netflixtitels)x
where rn=1

--- 7 find directors who directed more than 5 titles.
select director,count(*) from  netflixtitels where director is not null group by director having count(*) > 5

-- 8 count the number of titles for each rating.
select rating,count(*) as total_titles from netflixtitels group by rating order by total_titles 

-- 9 get the 3 longest movies.
select top 3 title, duration from netflixtitels where type = 'Movie' order by cast(replace(duration, ' min', '') as int) desc

-- 10 find all titles that have 'love' in their title.
select title from netflixtitels where title like '%love%';

-- 11 use cte to list all tv shows released after 2015 with rating 'tv-ma'.
with tv_ma_shows as (select * from netflixtitels where type = 'TV Show' and release_year > 2015 and rating = 'TV-MA')
select title, country, release_year from tv_ma_shows;

-- 12  get the number of unique directors per country.
select country, count(distinct director) as unique_directors from netflixtitels group by country;

-- 13 find the country with the highest average release year for movies.
select country,avg(release_year) as highest_average_release_year from  netflixtitels where country is not null and type = 'Movie' group by country 

-- 14 rank the movies by duration (window function).
select title, duration, rank() over (order by cast(replace(duration, ' min', '') as int) desc) as duration_rank from netflixtitels where type = 'Movie';

-- 15 create a view summarizing all Netflix insights
select * from vw_netflix_summary

-- 15 create a view summarizing all Netflix insights
CREATE VIEW vw_netflix_summary AS
SELECT * FROM (
    -- 1. Total Movies
    SELECT 'Total Movies' AS metric, CAST(COUNT(*) AS VARCHAR) AS value 
    FROM netflixtitels WHERE type = 'Movie'
    
    UNION ALL
    -- 2. Total TV Shows
    SELECT 'Total TV Shows', CAST(COUNT(*) AS VARCHAR) 
    FROM netflixtitels WHERE type = 'TV Show'
    
    UNION ALL
    -- 3. Top Country with Most Titles
    SELECT 'Top Country (Most Titles)', country 
    FROM (
        SELECT TOP 1 country, COUNT(*) AS total_titles
        FROM netflixtitels 
        WHERE country IS NOT NULL
        GROUP BY country
        ORDER BY total_titles DESC
    ) t
    
    UNION ALL
    -- 4. Average Movie Duration
    SELECT 'Average Movie Duration (mins)', CAST(AVG(CAST(REPLACE(duration,' min','') AS INT)) AS VARCHAR)
    FROM netflixtitels WHERE type = 'Movie'
    
    UNION ALL
    -- 5. Release Year of Breaking Bad
    SELECT 'Release Year of Breaking Bad', CAST(release_year AS VARCHAR)
    FROM netflixtitels WHERE title = 'Breaking Bad'
    
    UNION ALL
    -- 6. Unique Directors Count
    SELECT 'Unique Directors', CAST(COUNT(DISTINCT director) AS VARCHAR)
    FROM netflixtitels WHERE director IS NOT NULL
    
    UNION ALL
    -- 7. Country with Highest Avg Release Year (Movies)
    SELECT 'Country with Highest Avg Release Year (Movies)', country
    FROM (
        SELECT TOP 1 country, AVG(release_year) AS avg_release
        FROM netflixtitels 
        WHERE type='Movie' AND country IS NOT NULL
        GROUP BY country
        ORDER BY avg_release DESC
    ) t
    
    UNION ALL
    -- 8. Top 3 Longest Movies
    SELECT 'Top 3 Longest Movies', STRING_AGG(title, ', ')
    FROM (
        SELECT TOP 3 title
        FROM netflixtitels
        WHERE type='Movie'
        ORDER BY CAST(REPLACE(duration,' min','') AS INT) DESC
    ) t
    
    UNION ALL
    -- 9. Top 5 Ranked Movies by Duration
    SELECT 'Top 5 Movies (Ranked by Duration)', STRING_AGG(title, ', ')
    FROM (
        SELECT TOP 5 title
        FROM netflixtitels
        WHERE type='Movie'
        ORDER BY CAST(REPLACE(duration,' min','') AS INT) DESC
    ) t
) AS summary;

