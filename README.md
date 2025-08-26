#  🎬 Netflix Titles Analysis (SQL + Power BI Project)

This repository contains a Netflix Data Analysis Project that combines SQL Server queries for data exploration and Power BI dashboards for visualization.

The project uncovers business insights from Netflix’s dataset (Movies + TV Shows), including content trends, genres, ratings, durations, and country-level distributions.


## 📸 Project Screenshots 

- **Dashboard Screenshot 1**
[Dashboard Screenshot 1]: Comprehensive overview of 8800+ titles with insights into genre distribution, top contributing countries, rating breakdowns, and content growth over time.
![Dashboard Screenshot 1](https://github.com/Vishalmorya380/Netflix-TV-Movie-Analysis--SQL-PowerBI/blob/main/Netflix%201.png)


- **Dashboard Screenshot 2**
[Dashboard Screenshot 2](: Filterable analysis of 5000+ titles with slicers for country, type, release year, and director. Includes genre-wise breakdowns for both movies and TV shows, plus yearly trends from 2000 to 2024.
![Dashboard Screenshot 2](https://github.com/Vishalmorya380/Netflix-TV-Movie-Analysis--SQL-PowerBI/blob/main/Netflix%202.png)   


- **Image 1 – Queries Q1–Q9**  
  Covers: Movie/TV counts, top countries, yearly releases, avg movie duration, *Breaking Bad* year, latest added titles, directors >5, titles per rating, and longest movies.  
  ![Netflix Queries Q1–Q9](https://github.com/Vishalmorya380/Netflix-TV-Movie-Analysis--SQL-PowerBI/blob/main/Netlix%20sql%201.png)

- **Image 2 – Queries Q10–Q15**  
  Covers: Titles with *love*, TV-MA shows after 2015 (CTE), unique directors per country, highest avg release year, ranking movies, and view creation/query.  
  ![Netflix Queries Q10–Q15](https://github.com/Vishalmorya380/Netflix-TV-Movie-Analysis--SQL-PowerBI/blob/main/Netflix%20Sql%202.png)

- **Image 3 – Netflix Insights View**  
  Shows SQL code for `vw_netflix_summary` view combining key insights: totals, top country, avg duration, *Breaking Bad* year, directors, longest movies, and ranked movies.
  ![Netflix Insights View](https://github.com/Vishalmorya380/Netflix-TV-Movie-Analysis--SQL-PowerBI/blob/main/Netflix%20sql%203.png)

---

## 📌 Project Overview

This project focuses on analyzing the **Netflix Titles dataset** (Movies + TV Shows) using **SQL Server** for data analysis and **Power BI** for visualization. The goal was to transform raw metadata into actionable business insights that highlight Netflix’s global content strategy.

---

## 🔎 What We Built

- A set of **SQL queries** to explore and answer critical business questions such as:
  - How many movies vs TV shows are available?
  - Which countries contribute the most content?
  - What are the dominant genres and ratings?
  - How has content production evolved over the years?
  - Who are the most frequent directors and contributors?

- A summary SQL View `vw_netflix_summary` that consolidates multiple insights into a single reference table.

- A fully interactive **Power BI Dashboard** that visualizes:
  - KPIs like total titles, average duration, total countries, and genres
  - Movies vs TV Shows distribution (both count & percentage)
  - Yearly release trends (growth of content over time)
  - Genre and Rating breakdowns
  - Geographic content distribution across top contributing countries

---

## 🎯 Why This Project?

Netflix has a vast and diverse library. By analyzing its catalog:

- Business teams can understand content distribution trends.
- Analysts can identify dominant genres, ratings, and countries.
- Stakeholders can track growth patterns and production strategies.

This project demonstrates how to apply **SQL for backend analytics** and **Power BI for storytelling dashboards** — bridging raw data and business decisions.

---


## Netflix Data Insights (SQL + Power BI) project questions (table: netflixtitels)

 ```sql
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
select country,avg(release_year) as highest_average_release_year from  netflixtitels 
where country is not null and type = 'Movie' group by country 

-- 14 rank the movies by duration (window function).
select title, duration, rank() over (order by cast(replace(duration, ' min', '') as int) desc) as duration_rank
from netflixtitels where type = 'Movie';

-- 15 create a view summarizing all Netflix insights
select * from vw_netflix_summary
```

---

## Netflix Data Insights Using View Summary from vw_netflix_summary

```sql
-- 15 create a view summarizing all Netflix insights
CREATE VIEW vw_netflix_summary AS
SELECT * FROM (
    -- 1. Total Movies
    SELECT 'Total Movies' AS metric, CAST(COUNT(*) AS VARCHAR) AS value  FROM netflixtitels WHERE type = 'Movie' UNION ALL
    -- 2. Total TV Shows
    SELECT 'Total TV Shows', CAST(COUNT(*) AS VARCHAR) FROM netflixtitels WHERE type = 'TV Show' UNION ALL
    -- 3. Top Country with Most Titles
    SELECT 'Top Country (Most Titles)', country FROM (SELECT TOP 1 country, COUNT(*) AS total_titles
        FROM netflixtitels WHERE country IS NOT NULL GROUP BY country ORDER BY total_titles DESC ) t UNION ALL
    -- 4. Average Movie Duration
    SELECT 'Average Movie Duration (mins)', CAST(AVG(CAST(REPLACE(duration,' min','') AS INT)) AS VARCHAR) 
	FROM netflixtitels WHERE type = 'Movie'UNION ALL
    -- 5. Release Year of Breaking Bad
    SELECT 'Release Year of Breaking Bad', CAST(release_year AS VARCHAR) FROM netflixtitels WHERE title = 'Breaking Bad' UNION ALL
    -- 6. Unique Directors Count
    SELECT 'Unique Directors', CAST(COUNT(DISTINCT director) AS VARCHAR) FROM netflixtitels WHERE director IS NOT NULL UNION ALL
    -- 7. Country with Highest Avg Release Year (Movies)
    SELECT 'Country with Highest Avg Release Year (Movies)', country FROM (
 SELECT TOP 1 country, AVG(release_year) AS avg_release FROM netflixtitels  WHERE type='Movie' AND country IS NOT NULL
   GROUP BY country ORDER BY avg_release DESC ) t UNION ALL
    -- 8. Top 3 Longest Movies
    SELECT 'Top 3 Longest Movies', STRING_AGG(title, ', ') FROM (
        SELECT TOP 3 title FROM netflixtitels WHERE type='Movie' ORDER BY CAST(REPLACE(duration,' min','') AS INT) DESC) t UNION ALL
    -- 9. Top 5 Ranked Movies by Duration
 SELECT 'Top 5 Movies (Ranked by Duration)', STRING_AGG(title, ', ')FROM 
 ( SELECT TOP 5 title FROM netflixtitels WHERE type='Movie' ORDER BY CAST(REPLACE(duration,' min','') AS INT) DESC ) t) AS summary;
```

---




# 📊 Query Outputs  

---

### 1️⃣ Count Employees  
**Query**  
```sql
SELECT COUNT(EmpID) AS total_employees FROM Employees;
Output

diff
Copy
Edit
+----------------+
| total_employees|
+----------------+
|       10       |
+----------------+
```

---

---



# 📊 SQL Query Outputs  

---
Here are the SQL queries used in this project with sample outputs.

###1️⃣ Count Movies vs TV Shows

Query

SELECT type, COUNT(*) AS total_count 
FROM netflixtitels 
GROUP BY type;


Output

+----------+--------------+
|   type   | total_count  |
+----------+--------------+
| Movie    |     6130     |
| TV Show  |     2679     |
+----------+--------------+
```

---

---


📂 Download CSV

###2️⃣ Top 5 Countries with Most Titles

Query

SELECT TOP 5 country, COUNT(*) AS total_titles 
FROM netflixtitels 
GROUP BY country 
ORDER BY total_titles DESC;


Output

+----------------+--------------+
|    country     | total_titles |
+----------------+--------------+
| United States  |     2818     |
| India          |      972     |
| United Kingdom |      712     |
| Japan          |      523     |
| South Korea    |      398     |
+----------------+--------------+
```

---

---


📂 Download CSV

###3️⃣ Titles Released Each Year

Query

SELECT release_year, COUNT(*) AS total_titles 
FROM netflixtitels 
GROUP BY release_year 
ORDER BY release_year DESC;


Output (sample)

+--------------+--------------+
| release_year | total_titles |
+--------------+--------------+
|    2021      |     1199     |
|    2020      |     1236     |
|    2019      |     1032     |
+--------------+--------------+
```

---

---

###4️⃣ Average Movie Duration

Query

SELECT AVG(CAST(REPLACE(duration, ' min', '') AS INT)) AS avg_duration
FROM netflixtitels 
WHERE type = 'Movie';


Output

+--------------+
| avg_duration |
+--------------+
|     69.84    |
+--------------+
```

---

---


📂 Download CSV

###5️⃣ Titles Released in Same Year as Breaking Bad

Query

SELECT title, release_year 
FROM netflixtitels 
WHERE release_year = 
 (SELECT release_year FROM netflixtitels WHERE title = 'Breaking Bad');


Output (sample)

+--------------------+--------------+
| title              | release_year |
+--------------------+--------------+
| Breaking Bad       |     2008     |
| The Dark Knight    |     2008     |
| Iron Man           |     2008     |
+--------------------+--------------+
```

---

---

###6️⃣ Latest Added Title for Each Country

Query

SELECT country, title, date_added 
FROM (
    SELECT country, title, date_added,
           ROW_NUMBER() OVER(PARTITION BY country ORDER BY date_added DESC) AS rn 
    FROM netflixtitels
) x
WHERE rn=1;


Output (sample)

+------------+------------------------+------------+
| country    | title                  | date_added |
+------------+------------------------+------------+
| United States | The Queen’s Gambit  | 2021-01-01 |
| India         | Sacred Games        | 2021-01-01 |
+------------+------------------------+------------+
```

---

---

###7️⃣  Titles per Rating

Query

SELECT rating, COUNT(*) AS total_titles 
FROM netflixtitels 
GROUP BY rating 
ORDER BY total_titles DESC;


Output (Top 5)

+--------+--------------+
| rating | total_titles |
+--------+--------------+
| TV-MA  |     3200     |
| TV-14  |     2200     |
| TV-PG  |      900     |
| R      |      800     |
| PG-13  |      500     |
+--------+--------------+
```

---

---


## 🛠️ Tech Stack

- **SQL Server** → Writing queries, aggregations, CTEs, Window Functions, and creating Views for analysis  
- **Power BI Desktop** → Building dashboards with KPIs, slicers, filters, and interactive charts  
- **Excel / CSV** → Source dataset storage & preprocessing  
- **DAX (basic)** → Simple calculated measures in Power BI for KPIs (if required)  
- **GitHub** → Version control and project portfolio hosting  
    
---

##📈 Power BI Dashboard Features  


KPIs: Total Titles, Countries, Genres, Avg Duration, Year Range

Genre Analysis: Distribution by titles and categories

Rating Analysis: Titles by ratings (TV-MA, TV-14, PG, etc.)

Country Trends: Top contributing countries

Type Comparison: Movies vs TV Shows

Release Trend: Yearly growth of Movies vs TV Shows

Filters/Slicers: Country, Type, Release Year, Rating, Director

Interactive Toggle: "Clear All Slicers"

---


## 🚀 Insights Derived

📌 Total 8,800+ titles analyzed from 1925 to 2024

🎥 Majority of titles are Movies (69%) vs TV Shows (31%)

🌍 Netflix content spans across 700+ countries

⭐ TV-MA and TV-14 dominate age ratings

📊 Genres like Drama, Documentary, and Comedy lead

⏳ Average Movie duration ~ 70 minutes

🌏 Top contributing countries include USA, India, UK

---


## 📎 How to Use

Run SQL queries in SQL Server to reproduce analysis.

Open Netflix Dashboard.pbix in Power BI Desktop.

Explore dashboard with slicers & filters.

--

## 📢 Conclusion

This project demonstrates how to use SQL + Power BI for real-world data analytics.
It highlights how business intelligence tools can uncover trends in global content platforms like Netflix.

---

## 📌 Author
👤 **Your Name**  
📧 [Vishal](mailto:Vishalmorya380@gmail.com)  
🔗 [LinkedIn Profile](https://www.linkedin.com/in/vishal-maurya-bb66b4378)  
```
