-- ============================================================
-- STEAM GAME HISTORICAL ANALYSIS
-- SQL QUESTIONS FOR POWER BI
-- ============================================================


-- ============================================================
-- 1. OVERALL GAME POPULARITY
-- ============================================================

-- Q1. How many games are in each estimated ownership category?
--
-- Goal:
-- Understand the overall distribution of game popularity.
--
-- Output:
--   estimated_owners
--   number_of_games
 SELECT estimated_owners, count(*) as num_games From games
 GROUP BY estimated_owners
 ORDER BY num_games DESC

-- Q2. What percentage of all games fall into each estimated
-- ownership category?
--
-- Goal:
-- Understand how concentrated the Steam game market is
-- toward lower ownership levels.
--
-- Output:
--   estimated_owners
--   number_of_games
--   percentage_of_games
 SELECT 
 	estimated_owners, 
	CAST (count(*) as FLOAT) / (SELECT count(*) as total FROM games) * 100 as percentage 
 From games
 GROUP BY estimated_owners
 ORDER BY percentage DESC

-- ============================================================
-- 2. GENRE ANALYSIS
-- ============================================================

-- Q3. How many games are in each genre?
--
-- Goal:
-- Identify the largest genres in the dataset.
--
-- Output:
--   genre
--   number_of_games
SELECT genre_name, count(*) as num_games
FROM games G
JOIN game_genres GG ON G.appid = GG.appid
JOIN genres Gen ON GG.genre_id = Gen.genre_id
GROUP BY genre_name
ORDER BY num_games

-- Q5. How is estimated ownership distributed within each genre?
--
-- Example:
--
-- Genre       0-20K   20-50K   50-100K   100-200K   ...
-- Action       ...      ...       ...        ...
-- RPG          ...      ...       ...        ...
--
-- Goal:
-- Compare the popularity distribution of different genres.

SELECT genre_name, estimated_owners, count(*) as num_games
FROM games G
JOIN game_genres GG ON G.appid = GG.appid
JOIN genres Gen ON GG.genre_id = Gen.genre_id
GROUP BY genre_name, estimated_owners

-- Q6. Which genres have the highest percentage of games
-- with 1M+ estimated owners?
--
-- Goal:
-- Compare genres based on the proportion of highly owned games,
-- rather than simply the total number of popular games.
--
-- Output:
--   genre
--   total_games
--   games_1m_plus
--   percentage_1m_plus
SELECT 
    genre_name,
    COUNT(*) AS total_games,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    ) AS games_1m_plus,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    )::FLOAT / COUNT(*) * 100 AS percentage_1m_plus
FROM games G
JOIN game_genres GG ON G.appid = GG.appid
JOIN genres Gen ON GG.genre_id = Gen.genre_id
GROUP BY genre_name


-- Q7. Which genres have the most games with 1M+ estimated owners?
--
-- Goal:
-- Identify the genres that produce the largest number of
-- highly owned games.
--
-- Output:
--   genre
--   games_1m_plus

SELECT 
	genre_name, 
	count(*) as games_1m_plus
FROM games G 
JOIN game_genres GG ON G.appid = GG.appid 
JOIN genres Gen ON GG.genre_id = Gen.genre_id 
WHERE estimated_owners 
	IN ( '1M - 2M', 
		'2M - 5M', 
		'5M - 10M', 
		'10M - 20M', 
		'20M - 50M', 
		'50M - 100M' ) 
GROUP BY genre_name
ORDER BY games_1m_plus DESC

-- Q8. Which genres have the most games with 5M+ estimated owners?
--
-- Goal:
-- Identify genres associated with extremely successful games.

SELECT 
	genre_name, 
	count(*) as games_1m_plus
FROM games G 
JOIN game_genres GG ON G.appid = GG.appid 
JOIN genres Gen ON GG.genre_id = Gen.genre_id 
WHERE estimated_owners 
	IN (  '5M - 10M', 
		'10M - 20M', 
		'20M - 50M', 
		'50M - 100M' ) 
GROUP BY genre_name
ORDER BY games_1m_plus DESC

-- ============================================================
-- 3. PRICE ANALYSIS
-- ============================================================

-- Q8. How is estimated ownership distributed across
-- different price ranges?
--
-- Suggested price ranges:
--
--   Free
--   $0.01–$5
--   $5–$10
--   $10–$20
--   $20–$40
--   $40+
--
-- Goal:
-- Determine whether certain price ranges have different
-- popularity distributions.
--
-- Output:
--   price_range
--   estimated_owners
--   number_of_games

SELECT
    price_range,
    estimated_owners,
    COUNT(*) AS number_of_games
FROM (
    SELECT
        CASE
            WHEN price = 0 THEN 'Free'
            WHEN price > 0 AND price < 5 THEN '$0.01-$5'
            WHEN price >= 5 AND price < 10 THEN '$5-$10'
            WHEN price >= 10 AND price < 20 THEN '$10-$20'
            WHEN price >= 20 AND price < 40 THEN '$20-$40'
            WHEN price >= 40 THEN '$40+'
        END AS price_range,
        estimated_owners
    FROM games
) AS priced_games
GROUP BY price_range, estimated_owners
ORDER BY price_range, estimated_owners;


-- Q9. Which price ranges have the highest percentage
-- of games with 1M+ estimated owners?
--
-- Goal:
-- Determine whether certain price ranges are more likely
-- to contain highly owned games.
--
-- Output:
--   price_range
--   total_games
--   games_1m_plus
--   percentage_1m_plus

SELECT 
    price_range,
    COUNT(*) AS total_games,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    ) AS games_1m_plus,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    )::FLOAT / COUNT(*) * 100 AS percentage_1m_plus
FROM (
    SELECT
        CASE
            WHEN price = 0 THEN 'Free'
            WHEN price > 0 AND price < 5 THEN '$0.01-$5'
            WHEN price >= 5 AND price < 10 THEN '$5-$10'
            WHEN price >= 10 AND price < 20 THEN '$10-$20'
            WHEN price >= 20 AND price < 40 THEN '$20-$40'
            WHEN price >= 40 THEN '$40+'
        END AS price_range,
        estimated_owners
    FROM games
) AS priced_games
GROUP BY price_range
ORDER BY percentage_1m_plus

-- ============================================================
-- 4. REVIEWS AND POPULARITY
-- ============================================================

-- Q10. How does review score relate to estimated ownership?
--
-- Create review percentage categories such as:
--
--   <60%
--   60–70%
--   70–80%
--   80–90%
--   90%+
--
-- Goal:
-- Compare ownership distributions across review categories.

SELECT 
	review_percentage_range,
	estimated_owners,
	count(*) as num_games
FROM( 
	SELECT 
		CASE 
			WHEN review_percentage < 60 THEN '<60%'
			WHEN review_percentage >= 60 AND review_percentage < 70 THEN '60-70%'
			WHEN review_percentage >= 70 AND review_percentage < 80 THEN '70-80%'
			WHEN review_percentage >= 80 AND review_percentage < 90 THEN '80-90%'
			WHEN review_percentage >= 90 THEN '90%+'
		END AS review_percentage_range,
		estimated_owners
	FROM (
		SELECT 
			estimated_owners,
			CASE 
				WHEN (positive + negative) = 0 THEN 0
				WHEN (positive + negative) > 0 THEN (positive::float / (positive + negative)) * 100
			END AS review_percentage
		FROM games
	) AS percentage_calculated
) AS categorized_percent
GROUP BY estimated_owners, review_percentage_range

-- Q11. What percentage of games with 90%+ positive reviews
-- have 1M+ estimated owners?
--
-- Goal:
-- Determine whether highly reviewed games are also
-- highly owned.
SELECT 
    COUNT(*) AS total_games,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    ) AS games_1m_plus,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    )::FLOAT / COUNT(*) * 100 AS percentage_1m_plus
FROM (
    SELECT 
        estimated_owners,
        positive::FLOAT / (positive + negative) * 100 AS review_percentage
    FROM games
    WHERE positive + negative > 0
) AS percentage_calculated
WHERE review_percentage >= 90;


-- Q12. How does Metacritic score relate to estimated ownership?
--
-- Goal:
-- Determine whether higher Metacritic scores are associated
-- with higher ownership.
SELECT estimated_owners, metacritic_category, count(*) AS num_games
FROM (
	SELECT estimated_owners,
	CASE 
		WHEN metacritic_score = 0 THEN '0'
		WHEN metacritic_score > 0 AND metacritic_score < 20 THEN '0-20'
		WHEN metacritic_score > 20 AND metacritic_score < 40 THEN '20-40'
		WHEN metacritic_score > 40 AND metacritic_score < 60 THEN '40-60'
		WHEN metacritic_score > 60 AND metacritic_score < 80 THEN '60-80'
		WHEN metacritic_score > 80 AND metacritic_score < 100 THEN '80-100'
	END AS metacritic_category
	FROM games
	)
WHERE metacritic_category <> '0'
GROUP BY estimated_owners, metacritic_category;


-- ============================================================
-- 5. RELEASE YEAR ANALYSIS
-- ============================================================

-- Q13. How has the distribution of estimated ownership
-- changed by release year?
--
-- Goal:
-- Determine whether the popularity of games has changed
-- over time.
--
-- Output:
--   release_year
--   estimated_owners
--   number_of_games
--
-- This is another MAIN Power BI visualization.

SELECT 
	EXTRACT(YEAR FROM TO_DATE(release_date, 'mon DD, YYYY')) AS release_year,
	estimated_owners,
	count(*) as num_games
FROM games
GROUP BY estimated_owners, release_year
ORDER BY estimated_owners, release_year;

-- Q14. What percentage of games released each year
-- reached 1M+ estimated owners?
--
-- Goal:
-- Account for differences in the number of games released
-- each year.
--
-- Output:
--   release_year
--   total_games
--   games_1m_plus
--   percentage_1m_plus
SELECT 
	EXTRACT(YEAR FROM TO_DATE(release_date, 'mon DD, YYYY')) AS release_year,
	COUNT(*) AS total_games,
	COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    ) AS games_1m_plus,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    )::FLOAT / COUNT(*) * 100 AS percentage_1m_plus
FROM games
GROUP BY release_year
ORDER BY release_year;

-- ============================================================
-- 6. PLAYER ENGAGEMENT
-- ============================================================

-- Q15. How does peak CCU vary across estimated
-- ownership categories?
--
-- Goal:
-- Determine whether games with more estimated owners
-- tend to have higher peak concurrent players.

SELECT 
	estimated_owners,
	AVG(peak_ccu) AS avg_peak_ccu
FROM games
GROUP BY estimated_owners
ORDER BY estimated_owners;

-- Q16. How does average playtime vary across estimated
-- ownership categories?
--
-- Goal:
-- Determine whether highly owned games tend to have
-- higher player engagement.

SELECT 
	estimated_owners,
	AVG(average_playtime_forever) / 60 AS avg_playtime
FROM games
GROUP BY estimated_owners
ORDER BY estimated_owners;


-- ============================================================
-- 7. LANGUAGE ANALYSIS
-- ============================================================

-- Q17. How many games support each language?
--
-- Goal:
-- Identify the most commonly supported languages.
--
-- Output:
--   language
--   number_of_games

SELECT 
	languages_name,
	count(*) as num_games
FROM games G
JOIN game_languages GL ON G.appid = GL.appid
JOIN languages L ON GL.languages_id = L.languages_id
GROUP BY languages_name
ORDER BY num_games DESC;

-- Q18. How is estimated ownership distributed across
-- games supporting each language?
--
-- Goal:
-- Determine whether games supporting certain languages
-- have different popularity distributions.
--
-- Output:
--   language
--   estimated_owners
--   number_of_games
--
-- NOTE:
-- A game can support multiple languages, so the same game
-- can appear under multiple languages.

SELECT 
	languages_name,
	estimated_owners,
	count(*) as num_games
FROM games G
JOIN game_languages GL ON G.appid = GL.appid
JOIN languages L ON GL.languages_id = L.languages_id
GROUP BY languages_name, estimated_owners
ORDER BY languages_name, num_games DESC;

-- Q19. Which languages have the highest percentage of games
-- with 1M+ estimated owners?
--
-- Goal:
-- Compare languages based on the proportion of their games
-- that reach 1M+ estimated owners.
--
-- IMPORTANT:
-- Consider requiring a minimum number of games per language
-- so languages with very few games do not dominate the results.
--
-- Output:
--   language
--   total_games
--   games_1m_plus
--   percentage_1m_plus
SELECT
	languages_name, 
	COUNT(*) AS total_games,
	COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    ) AS games_1m_plus,
    COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    )::FLOAT / COUNT(*) * 100 AS percentage_1m_plus
FROM games G
JOIN game_languages GL ON G.appid = GL.appid
JOIN languages L ON GL.languages_id = L.languages_id
GROUP BY languages_name
HAVING count(*) > 1000
ORDER BY languages_name



-- ============================================================
-- 8. TAG ANALYSIS
-- ============================================================

-- Q20. Which tags are most common among games with
-- 1M+ estimated owners?
--
-- Goal:
-- Identify characteristics that are common among
-- highly owned games.
--
-- Output:
--   tag
--   games_1m_plus
--
-- NOTE:
-- A game can have multiple tags.

SELECT
	tag_name, 
	COUNT(*) FILTER (
        WHERE estimated_owners IN (
            '1M - 2M',
            '2M - 5M',
            '5M - 10M',
            '10M - 20M',
            '20M - 50M',
            '50M - 100M'
        )
    ) AS games_1m_plus
FROM games G
JOIN game_tags GT ON G.appid = GT.appid
JOIN tags T ON GT.tag_id = T.tag_id
GROUP BY tag_name
HAVING count(*) > 1000
ORDER BY games_1m_plus DESC