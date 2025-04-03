SELECT *
FROM mart_song
WHERE country = 'Belarus';

SELECT *
FROM prep_contestants
WHERE country = 'Belarus';

SELECT *
FROM prep_songs
WHERE country = 'Belarus';

SELECT avg(point_ratio)
FROM mart_relationship
WHERE to_country = 'Belarus';

SELECT YEAR,
avg(betting_score)
FROM PREP_BETTING PB
WHERE country_name = 'Belarus'
GROUP BY year;

SELECT * 
FROM PREP_BETTING PB
LIMIT 100;

SELECT relationship,
total_points, tele_points, jury_points,
year
FROM prep_votes
WHERE relationship = 'Russia-Belarus' and round = 'final'
ORDER BY total_points Desc;

SELECT relationship,
tele_points,
year
FROM prep_votes
WHERE relationship = 'Belarus-Russia'
ORDER BY total_points Desc;

SELECT relationship
, avg(tele_points) AS avg_points
FROM prep_votes
WHERE relationship = 'Russia-Belarus'
GROUP BY relationship;

WITH relationship_time AS 
	(SELECT prep_votes.relationship 
		, prep_votes.to_country
		, prep_votes.from_country
		,(CASE WHEN from_start_year >= to_start_year THEN 
			from_start_year 
		ELSE 
			to_start_year END) AS relationship_start
		,(CASE WHEN from_last_year <= to_last_year THEN 
			from_last_year
		ELSE 
			to_last_year END) AS relationship_end
		FROM prep_votes
		WHERE round = 'final'),
	voting_system AS (SELECT relationship_time.relationship
		, relationship_time.to_country
		, relationship_time.from_country
		,(CASE WHEN relationship_start >= 2016 THEN relationship_end-relationship_start
			WHEN relationship_end > 2016 THEN relationship_end-2016 
			ELSE 0 END) AS new_voting_system
		,(CASE WHEN relationship_start >= 2016 THEN relationship_start*0
			WHEN relationship_end > 2016 THEN relationship_end-relationship_start
			ELSE 2016-relationship_start END) AS old_voting_system
		FROM relationship_time),
	points AS (SELECT prep_votes.relationship
		, sum(total_points) AS points_earned
		FROM prep_votes
		WHERE round='final'
		GROUP BY prep_votes.relationship),
	expected AS (SELECT voting_system.relationship
		, voting_system.to_country
		, voting_system.from_country
		, new_voting_system AS new_system_years
		, old_voting_system AS old_system_years
		, new_voting_system*24 AS new_points
		, old_voting_system*12 AS old_points
		FROM voting_system),
	ratio AS (SELECT points.points_earned
		, expected.relationship
		, expected.to_country
		, expected.from_country
		, expected.new_system_years
		, expected.old_system_years
		, (expected.new_points+expected.old_points) AS total_possible
		FROM points
		JOIN expected ON expected.relationship=points.relationship)
SELECT ratio.relationship
	, ratio.to_country
	, ratio.from_country
	, ratio.new_system_years
	, ratio.old_system_years
	, (CASE WHEN total_possible > 0 THEN points_earned/total_possible 
	ELSE 0 END) AS point_ratio
FROM ratio
WHERE ratio.from_country = '';
		


WITH relationship_ratio AS 
    (SELECT to_country,
    AVG(point_ratio) AS point_ratio
    FROM mart_relationship
    GROUP BY to_country)
, betting_ratio AS
	(SELECT YEAR
	, performer
	, song
	, AVG(betting_score) AS betting_odds
	FROM PREP_BETTING
	GROUP BY YEAR, performer, song)
SELECT ps.*
	, rr.point_ratio
	, br.betting_odds
FROM PREP_SONGS AS ps
JOIN relationship_ratio AS rr ON ps.country = rr.to_country
JOIN betting_ratio AS br ON ((ps.YEAR = br.YEAR) AND (ps.artist_name = br.performer) AND (ps.song_name = br.song));


SELECT *
FROM prep_votes
ORDER BY to_country
LIMIT 3;

SELECT *
FROM prep_votes
WHERE from_country = 'Albania';

SELECT *
FROM prep_contestants
WHERE Place_FINAL = 1
ORDER BY year DESC;

SELECT *
FROM mart_relationship
WHERE from_country = 'Andorra';

SELECT *
FROM prep_votes
WHERE from_country = 'Andorra' AND round = 'final';



WITH relationship_time AS 
	(SELECT prep_votes.relationship
		, prep_votes.year
		, prep_votes.to_country
		, prep_votes.from_country
		,(CASE WHEN from_start_year >= to_start_year THEN 
			from_start_year 
		ELSE 
			to_start_year END) AS relationship_start
		,(CASE WHEN from_last_year <= to_last_year THEN 
			from_last_year
		ELSE 
			to_last_year END) AS relationship_end
		FROM prep_votes
		WHERE round = 'final')
SELECT relationship_time.relationship
		, relationship_time.to_country
		, relationship_time.from_country
		, relationship_time.year
		,(CASE WHEN ((relationship_time.YEAR >= relationship_start) AND (relationship_time.YEAR <= relationship_end) AND (relationship_time.YEAR>=2016)) THEN 1
			ELSE 0 END) AS new_voting_system
		,(CASE WHEN ((relationship_time.YEAR >= relationship_start) AND (relationship_time.YEAR <= relationship_end) AND (relationship_time.YEAR<2016)) THEN 1
			ELSE 0 END) AS old_voting_system
FROM relationship_time;

WITH relationship_time AS 
	(SELECT prep_votes.year
		, prep_votes.relationship 
		, prep_votes.to_country
		, prep_votes.from_country
		,(CASE WHEN from_start_year >= to_start_year THEN 
			from_start_year 
		ELSE 
			to_start_year END) AS relationship_start
		,(CASE WHEN from_last_year <= to_last_year THEN 
			from_last_year
		ELSE 
			to_last_year END) AS relationship_end
		FROM prep_votes
		WHERE round = 'final'),
	voting_system AS (SELECT relationship_time.relationship
		, relationship_time.to_country
		, relationship_time.from_country
		, relationship_time.year
		,(CASE WHEN ((relationship_time.YEAR >= relationship_start) AND (relationship_time.YEAR <= relationship_end) AND (relationship_time.YEAR>=2016)) THEN 1
			ELSE 0 END) AS new_voting_system
		,(CASE WHEN ((relationship_time.YEAR >= relationship_start) AND (relationship_time.YEAR <= relationship_end) AND (relationship_time.YEAR<2016)) THEN 1
			ELSE 0 END) AS old_voting_system
		FROM relationship_time),
	points AS (SELECT prep_votes.relationship
		, sum(total_points) AS points_earned
		FROM prep_votes
		WHERE round='final'
		GROUP BY prep_votes.relationship),
	expected AS (SELECT voting_system.year
		, voting_system.relationship
		, voting_system.from_country
		, voting_system.to_country
		, SUM(new_voting_system)*24 AS new_points
		, SUM(old_voting_system)*12 AS old_points
		FROM voting_system
		GROUP BY voting_system.year
		, voting_system.relationship
		, voting_system.from_country
		, voting_system.to_country),
	ratio AS (SELECT points.points_earned
		, expected.year
		, expected.relationship
		, expected.from_country
		, expected.to_country
		, (expected.new_points+expected.old_points) AS total_possible
		FROM points
		JOIN expected ON expected.relationship=points.relationship)
SELECT ratio.YEAR
	, ratio.relationship
	, ratio.to_country
	, ratio.from_country
	, (CASE WHEN total_possible > 0 THEN points_earned/total_possible 
	ELSE 0 END) AS point_ratio
FROM ratio;

SELECT prep_votes.relationship
		, SUM(total_points) AS old_points_earned
		FROM prep_votes
		WHERE (round='final' AND year < 2016)
		GROUP BY prep_votes.relationship
		

SELECT DISTINCT LANGUAGE
FROM mart_song;

DROP TABLE IF EXISTS european_languages;
CREATE TABLE european_languages (
    id SERIAL PRIMARY KEY,
    language VARCHAR(50),
    language_family VARCHAR(50)
);

INSERT INTO european_languages (language, language_family) VALUES
('English', 'Germanic'),
('German', 'Germanic'),
('Dutch', 'Germanic'),
('Swedish', 'Germanic'),
('Danish', 'Germanic'),
('Norwegian', 'Germanic'),
('Icelandic', 'Germanic'),
('Faroese', 'Germanic'),
('French', 'Romance'),
('Spanish', 'Romance'),
('Portuguese', 'Romance'),
('Italian', 'Romance'),
('Romanian', 'Romance'),
('Catalan', 'Romance'),
('Galician', 'Romance'),
('Occitan', 'Romance'),
('Sardinian', 'Romance'),
('Latin', 'Romance'),
('Russian', 'Slavic'),
('Polish', 'Slavic'),
('Czech', 'Slavic'),
('Slovak', 'Slavic'),
('Ukrainian', 'Slavic'),
('Belarusian', 'Slavic'),
('Bulgarian', 'Slavic'),
('Serbian', 'Slavic'),
('Croatian', 'Slavic'),
('Bosnian', 'Slavic'),
('Montenegrin', 'Slavic'),
('Slovenian', 'Slavic'),
('Macedonian', 'Slavic'),
('Greek', 'Hellenic'),
('Albanian', 'Albanian'),
('Hungarian', 'Uralic'),
('Finnish', 'Uralic'),
('Estonian', 'Uralic'),
('Basque', 'Isolate'),
('Irish', 'Celtic'),
('Scottish Gaelic', 'Celtic'),
('Welsh', 'Celtic'),
('Breton', 'Celtic'),
('Manx', 'Celtic'),
('Cornish', 'Celtic'),
('Arabic', 'Afro-Asiatic'),
    ('Hebrew', 'Afro-Asiatic'),
    ('Amharic', 'Afro-Asiatic'),
    ('Tigrinya', 'Afro-Asiatic'),
    ('Aramaic', 'Afro-Asiatic'),
    ('Maltese', 'Afro-Asiatic'),
    ('Geez', 'Afro-Asiatic'),
    ('Assyrian Neo-Aramaic', 'Afro-Asiatic'),
    ('Chaldean Neo-Aramaic', 'Afro-Asiatic'),
    ('Syriac', 'Afro-Asiatic'),
    ('Ugaritic', 'Afro-Asiatic'),
    ('Phoenician', 'Afro-Asiatic'),
    ('Moabite', 'Afro-Asiatic'),
    ('Edomite', 'Afro-Asiatic'),
    ('Canaanite', 'Afro-Asiatic');

SELECT *
FROM european_languages;
		
SELECT *
FROM mart_song
WHERE LANGUAGE ILIKE '%English%';

WITH separated AS (SELECT 
	language
	, Split_part(LANGUAGE, ',', 1) AS first_language
	, Split_part(LANGUAGE, ',', 2) AS second_language
	, Split_part(LANGUAGE, ',', 3) AS third_language
	FROM mart_song),
language_fam1 AS (SELECT separated.LANGUAGE
	, separated.first_language
	, separated.second_language
	, separated.third_language
	, european_languages.language_family
	FROM separated
	JOIN european_languages ON european_languages.LANGUAGE = separated.first_language)
 , language_fam2 AS (SELECT separated.LANGUAGE
	, separated.first_language
	, separated.second_language
	, separated.third_language
	, european_languages.language_family
	FROM separated
	JOIN european_languages ON european_languages.LANGUAGE = separated.second_language)
--, language_fam3 AS (SELECT separated.LANGUAGE
--	, separated.first_language
--	, separated.second_language
--	, separated.third_language
--	, european_languages.language_family
--	FROM separated
--	JOIN european_languages ON european_languages.LANGUAGE = separated.third_language)
SELECT song_name
	, MS.LANGUAGE
	, (CASE WHEN MS.language ILIKE '%English%' THEN 1
		ELSE 0 END) AS is_english
	, (CASE WHEN MS.LANGUAGE NOT LIKE 'English' THEN 1
		ELSE 0 END) AS is_not_english
	, language_fam1.language_family AS first_language_fam
	, language_fam2.language_family AS second_language_fam
--	, language_fam3.language_family AS third_language_fam
FROM MART_SONG MS
JOIN language_fam1 ON language_fam1.LANGUAGE = MS.LANGUAGE
JOIN language_fam2 ON language_fam2.LANGUAGE = MS.LANGUAGE
--JOIN language_fam3 ON language_fam3.LANGUAGE = MS.language;

SELECT song_name
	, MS.LANGUAGE
	, (CASE WHEN MS.language ILIKE '%English%' THEN 1
		ELSE 0 END) AS is_english
	, (CASE WHEN MS.LANGUAGE NOT LIKE 'English' THEN 1
		ELSE 0 END) AS is_not_english
---	, european_languages.language_family
FROM MART_SONG MS
---JOIN european_languages ON european_languages.language LIKE MS.LANGUAGE
WHERE MS.LANGUAGE ILIKE '%,%';