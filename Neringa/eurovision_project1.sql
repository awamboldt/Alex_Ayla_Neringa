SELECT * 
FROM songs s 
WHERE song_name ILIKE '%mama šč%'

---
SELECT *
FROM contestants_enhanced ce 
WHERE performer = 'Let 3'


----
SELECT *
FROM songs s 
WHERE artist_name = 'Let 3'


----
SELECT count(*)
FROM songs_info


----
SELECT count(*)
FROM songs
----
SELECT columns
FROM songs_info si 

----
SELECT * FROM contestants_enhanced
LIMIT 1



----
SELECT * 
FROM songs s 
WHERE song_name ILIKE '%mama šč%'
---

SELECT *,
PERCENT_RANK() OVER (ORDER BY point_ratio asc) AS pct_rank_ratio
FROM mart_relationship;

---
SELECT 
avg(point_ratio) AS mean_ratio,
stddev(point_ratio) AS std_ratio
FROM mart_relationship mr 



---
SELECT *
FROM votes v 
WHERE jury_points IS NOT NULL;

SELECT *
FROM votes v 
ORDER BY total_points DESC;

SELECT *
FROM mart_song ms;


---UPDATE mart_song
---SET language = CASE 
---    WHEN language = 'English6' THEN 'English'
---    WHEN language = 'English, Greek3' THEN 'English, Greek'
---    WHEN language = 'German5' THEN 'German'
---    ELSE language
---END;

SELECT *
FROM mart_song ms 
WHERE LANGUAGE ILIKE '%%';

SELECT DISTINCT LANGUAGE
FROM mart_song ms 
WHERE LANGUAGE ILIKE '%English%';

SELECT *, 
ROW_NUMBER() OVER (ORDER BY "year" ASC) AS row_num
FROM mart_relationship;

SELECT *,
RANK () OVER (ORDER BY point_ratio DESC) AS rank_num
FROM mart_relationship;

SELECT *,
PERCENT_RANK () OVER (ORDER BY point_ratio asc) AS pct_rank
FROM mart_relationship;

SELECT *
FROM prep_contestants pc;

/*below is the cte to organize songs INTO 5 GROUPS based ON the place_contest*/

WITH grouped_list AS (
	SELECT
		*,
		NTILE(5) OVER (ORDER BY place_contest )  AS NTILE
	FROM prep_contestants pc
)
SELECT 
	gl.to_country
	,gl.place_contest
	,gl.NTILE
FROM grouped_list gl
WHERE gl.NTILE = 1;

WITH grouped_list AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY place_contest) AS NTILE
    FROM prep_contestants
)
SELECT 
    to_country,
    COUNT(*) AS count
FROM grouped_list
WHERE NTILE = 1
GROUP BY to_country;

/*below is the cte to show top winning countries*/

SELECT 
	count(*) AS total_wins
	,to_country AS country
FROM prep_contestants pc 
WHERE place_contest=1
GROUP BY to_country
ORDER BY total_wins desc;

SELECT 
	stddev(loudness) AS std_loudness
,	var_samp(loudness) AS var_samp_loudness
,	var_pop(loudness) AS var_pop_loudness
,	avg(loudness) AS AVG_loudness
FROM songs_info;

SELECT loudness FROM songs_info LIMIT 10;

-------------

WITH cleaned_loudness AS (
	SELECT 
		split_part(loudness, ' ', 1) AS loudness_db
	FROM songs_info )
SELECT 
	stddev(loudness_db::numeric) AS std_loudness
,	var_samp(loudness_db::numeric) AS var_samp_loudness
,	var_pop(loudness_db::numeric) AS var_pop_loudness
,	avg(loudness_db::numeric) AS AVG_loudness
FROM cleaned_loudness; 

WITH cleaned_loudness AS (
    SELECT 
        CASE 
            WHEN NULLIF(TRIM(loudness), '') IS NULL THEN NULL
            ELSE split_part(TRIM(loudness), ' ', 1) 
        END AS loudness_db
    FROM songs_info
)
SELECT 
    stddev(loudness_db::numeric) AS std_loudness,
    var_samp(loudness_db::numeric) AS var_samp_loudness,
    var_pop(loudness_db::numeric) AS var_pop_loudness,
    avg(loudness_db::numeric) AS AVG_loudness
FROM cleaned_loudness
WHERE loudness_db IS NOT NULL;


SELECT song, backing_singers, final_place 
FROM mart_song;


SELECT
	*
, RANK OVER (ORDER BY point_ratio) AS rank_point_ratio		
FROM mart_relationship mr ;

SELECT *
FROM mart_relationship mr;


SELECT *
FROM mart_song ms 


---
SELECT *
FROM mart_relationship
WHERE point_ratio = '0E-20'


---
SELECT *
FROM contestants_enhanced ce 
WHERE performer = 'Dana International'

SELECT *
FROM betting;
---updating missing countries based on performer name, done for betting and prep_betting tables
UPDATE mart_betting 
SET country_name = CASE 
    WHEN performer = 'J. Newman' THEN 'United Kingdom'
	WHEN performer = 'Jones' THEN 'United Kingdom'
    WHEN performer = 'SuRie' THEN 'United Kingdom'
    WHEN performer = 'James Newman' THEN 'United Kingdom'
	WHEN performer = 'Andrea' THEN 'North Macedonia'
    WHEN performer = 'Michael Rice' THEN 'United Kingdom'
    WHEN performer = 'Tamara Todevska' THEN 'North Macedonia'
	WHEN performer = 'Mae Muller' THEN 'United Kingdom'
    WHEN performer = 'Vasil' THEN 'North Macedonia'
    WHEN performer = 'Sam Ryder' THEN 'United Kingdom'
    WHEN performer = 'Joe & Jake' THEN 'United Kingdom'
    WHEN performer = 'Velvet' THEN 'United Kingdom'
    ELSE country_name
END;

---updating performer name, done for betting and prep_betting tables

UPDATE mart_betting 
SET performer = CASE 
    WHEN performer = 'J. Newman' THEN 'James Newman'
 	ELSE performer
END;

SELECT * 
FROM mart_song


