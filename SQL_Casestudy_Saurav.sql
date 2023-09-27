USE imdb;

/* Now since the dataset have been imported, we will explore some of the tables. */

-- Segment 1:
-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT
	"Movie" AS "Table Name",
    COUNT(*) AS "Total Rows" 
FROM movie
UNION
SELECT
	"Genre" AS "Table Name",
    COUNT(*) AS "Total Rows" 
FROM genre
UNION
SELECT
	"Ratings" AS "Table Name",
    COUNT(*) AS "Total Rows" 
FROM ratings
UNION
SELECT
	"Director_mapping" AS "Table Name",
    COUNT(*) AS "Total Rows" 
FROM director_mapping
UNION
SELECT
	"Names" AS "Table Name",
    COUNT(*) AS "Total Rows" 
FROM names
UNION
SELECT
	"Role_mapping" AS "Table Name",
    COUNT(*) AS "Total Rows" 
FROM role_mapping;

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

select * from movie where country is null;
select * from movie where title is null;
select * from movie where year is null;
select * from movie where date_published is null;
select * from movie where duration is null;
select * from movie where worlwide_gross_income is null;
select * from movie where languages is null;
select * from movie where production_company is null;
     
-- NOTE:   There are four columns which have null values - country, worlwide_gross_income, languages and production_company 

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

-- Type your code below:
SELECT 
	year, 
	COUNT(title) AS "number_of_movies" 
FROM movie 
GROUP BY year;

SELECT 
	month(date_published) AS "month_num", 
    COUNT(title) AS "number_of_movies" 
FROM movie 
GROUP BY month(date_published) 
ORDER BY month(date_published) asc;

/*The highest number of movies is produced in the month of March-  - 824.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT COUNT(title) AS number_of_movies, year
FROM movie
WHERE (country = 'India' or country = 'USA') AND year = 2019;

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.  -- EXACT NUMBER IS 1059.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT 
	DISTINCT (GENRE) 
FROM GENRE;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT     genre,
           Count(m.id) AS number_of_movies
FROM       movie       AS m
INNER JOIN genre       AS g
where      g.movie_id = m.id
GROUP BY   genre
ORDER BY   number_of_movies DESC limit 1;

/* So, based on the insight we should focus on the ‘Drama’ genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
-- HAVING COUNT(genre)=1;
WITH genre_count AS  
(
	SELECT 
		movie_id, 
		count(genre) 
	FROM genre 
	GROUP BY movie_id 
	HAVING count(genre)=1
)
SELECT 
	count(movie_id) 
FROM genre_count;

/* There are more than three thousand movies which has only one genre associated with them. = 3289*/

-- Q8.What is the average duration of movies in each genre? 
-- Type your code below:

select genre, avg(duration) as avg_duration 
from movie as m join genre as g
on g.movie_id= m.id
group by genre
ORDER BY avg(duration) DESC;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

-- Type your code below:
SELECT 
	genre, 
	count(movie_id) AS "movie_count",
    DENSE_RANK() OVER(ORDER BY count(movie_id) DESC) AS "genre_rank"
FROM genre 
GROUP BY genre;

/*Thriller movies is in top 3 among all genres in terms of number of movies
  
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

-- Type your code below:

select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating, min(total_votes) as min_total_votes, max(total_votes) as max_total_votes, min(median_rating) as min_median_rating, max(median_rating) as max_median_rating
from ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
-- Type your code below:

SELECT 
	m.title , 
	r.avg_rating,
	RANK() OVER(ORDER BY avg_rating DESC) AS "movie_rank" 
FROM ratings AS r 
INNER JOIN
movie AS m
ON m.id=r.movie_id
WHERE r.avg_rating>=9
limit 10;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
-- Type your code below:
-- Order by is good to have

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;


/* Movies with a median rating of 7 is highest in number -2257.

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??*/
-- Type your code below:

WITH production_company_hit_movie_summary AS 
(SELECT 
	production_company,
    Count(movie_id) AS movie_count,
	Rank() OVER(ORDER BY Count(movie_id) DESC ) AS PROD_COMPANY_RANK
FROM ratings AS R
INNER JOIN movie AS M
ON M.id = R.movie_id
WHERE  avg_rating > 8
AND production_company IS NOT NULL
GROUP  BY production_company)
SELECT *
FROM   production_company_hit_movie_summary
WHERE  prod_company_rank = 1; 

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
-- Type your code below:

SELECT 
	m.title, r.avg_rating, g.genre 
FROM 
	movie AS m 
	INNER JOIN genre AS g 
    ON m.id=g.movie_id
    INNER JOIN ratings AS r
    ON m.id=r.movie_id
WHERE avg_rating> 8
AND title LIKE "The%" 
ORDER BY avg_rating DESC;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT median_rating, COUNT(movie_id) AS movie_count
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE median_rating = 8 AND date_published BETWEEN '2018-04-01' AND '2019-04-01';

-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
select count(*) as name_nulls from names where name IS NULL;

SELECT Count(*) AS height_nulls
FROM   names
WHERE  height IS NULL;
SELECT Count(*) AS date_of_birth_nulls
FROM   names
WHERE  date_of_birth IS NULL;
SELECT Count(*) AS known_for_movies_nulls
FROM   names
WHERE  known_for_movies IS NULL;

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

-- Type your code below:
WITH top_3_genres AS
(
SELECT 
	genre, Count(m.id) AS movie_count ,
    Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
FROM movie AS m
	INNER JOIN genre AS g
    ON g.movie_id = m.id
	INNER JOIN ratings AS r
	ON r.movie_id = m.id
WHERE avg_rating > 8
GROUP BY genre limit 3 
)
SELECT 
	n.NAME AS director_name ,
    Count(d.movie_id) AS movie_count
FROM director_mapping  AS d
INNER JOIN genre G
USING (movie_id)
INNER JOIN names AS n
ON n.id = d.name_id
INNER JOIN top_3_genres
USING (genre)
INNER JOIN ratings
USING (movie_id)
WHERE avg_rating > 8
GROUP BY NAME
ORDER BY movie_count 
DESC limit 3 ;

/*Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
-- Type your code below:
SELECT     
	production_company,
    SUM(total_votes) AS vote_count,
    RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
	INNER JOIN ratings AS r
	ON r.movie_id = m.id
GROUP BY production_company 
limit 3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.*/

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT title,
		CASE WHEN avg_rating > 8 THEN 'Superhit movies'
			 WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
             WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
			 WHEN avg_rating < 5 THEN 'Flop movies'
		END AS avg_rating_category
FROM movie AS m
INNER JOIN genre AS g
ON m.id=g.movie_id
INNER JOIN ratings as r
ON m.id=r.movie_id
WHERE genre='thriller'
order by avg_rating_category desc;

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- Type your code below:
SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top_genres AS
(
           SELECT     genre,
                      Count(m.id)                            AS movie_count ,
                      Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie                                  AS m
           INNER JOIN genre                                  AS g
           ON         g.movie_id = m.id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre limit 3 ), movie_summary AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
                      DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10))  DESC ) AS movie_rank
           FROM       movie                                                                     AS m
           INNER JOIN genre                                                                     AS g
           ON         m.id = g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_genres)
            GROUP BY   movie_name
           )
SELECT *
FROM   movie_summary
WHERE  movie_rank<=5
ORDER BY YEAR;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
-- Type your code below:
WITH production_company_summary AS 
(
SELECT
	production_company,
    COUNT(*) AS movie_count
FROM movie AS m
	INNER JOIN ratings AS r
    ON r.movie_id = m.id
WHERE  median_rating >= 8
	AND production_company IS NOT NULL
    AND POSITION(',' IN languages) > 0
GROUP BY production_company
ORDER BY movie_count DESC
)
SELECT 
	*,
    RANK() OVER (ORDER BY movie_count DESC) AS prod_comp_rank
FROM production_company_summary
LIMIT 2; 

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations
*/
-- Type you code below:
WITH next_date_published_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping                                                                      AS d
           INNER JOIN names                                                                                 AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)               AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;