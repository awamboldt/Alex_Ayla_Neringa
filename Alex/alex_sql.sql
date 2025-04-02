SELECT *
FROM PREP_SONGS 
LIMIT 1;

SELECT * 
FROM PREP_BETTING PB
LIMIT 100;

SELECT *
FROM VOTES V 
LIMIT 1;

WITH relationship_time AS 
	(SELECT prep_votes.relationship 
		, prep_votes.to_country
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
		,(CASE WHEN relationship_start >= 2016 THEN relationship_end-relationship_start
			ELSE relationship_end-2016 END) AS new_voting_system
		,(CASE WHEN relationship_start >= 2016 THEN relationship_start*0
			ELSE 2016-relationship_start END) AS old_voting_system
		FROM relationship_time),
	points AS (SELECT prep_votes.relationship
		, sum(total_points) AS points_earned
		FROM prep_votes
		WHERE round='final'
		GROUP BY prep_votes.relationship),
	expected AS (SELECT voting_system.relationship
		, voting_system.to_country
		, new_voting_system*24 AS new_points
		, old_voting_system*12 AS old_points
		FROM voting_system),
	ratio AS (SELECT points.points_earned
		, expected.relationship
		, expected.to_country
		, (expected.new_points+expected.old_points) AS total_possible
		FROM points
		JOIN expected ON expected.relationship=points.relationship)
SELECT ratio.relationship
	, ratio.to_country
	, (CASE WHEN total_possible > 0 THEN points_earned/total_possible 
	ELSE 0 END) AS point_ratio
FROM ratio;
		


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
JOIN betting_ratio AS br ON ((ps.YEAR = br.YEAR) AND (ps.artist_name = br.performer) AND (ps.song_name = br.song))