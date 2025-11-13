--15 Practice Questions

-- ### Easy Level
--1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT 
* 
FROM Spotify.spotify S 
WHERE S.Stream > 1000000000;

--2. List all albums along with their respective artists.
SELECT 
	DISTINCT S.Album,
	S.Artist
FROM Spotify.spotify S
ORDER BY 1;

-- 3. Get the total number of comments for tracks where `licensed = TRUE`.
SELECT SUM(S.Comments) TOTAL_COMMENTS
FROM Spotify.spotify S
WHERE S.Licensed = 'TRUE';


--4. Find all tracks that belong to the album type `single`.
SELECT *
FROM Spotify.spotify S
WHERE S.Album_type = 'single';

---5. Count the total number of tracks by each artist.
SELECT S.Artist,
COUNT(*)
FROM Spotify.spotify S
GROUP BY 1
ORDER BY 2;

-- ### Medium Level
-- 1. Calculate the average danceability of tracks in each album.
SELECT 
S.Album,
AVG(S.Danceability) dance_total
FROM Spotify.spotify S
GROUP BY S.Album
ORDER BY 1;

-- 2. Find the top 5 tracks with the highest energy values.
SELECT 
S.Track,
MAX(S.Energy)
FROM Spotify.spotify S
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 3. List all tracks along with their views and likes where `official_video = TRUE`.
SELECT 
S.Track,
SUM(S.Views) TOTAL_VIEWS,
SUM(S.Likes) TOTAL_LIKES
FROM Spotify.spotify S
WHERE S.official_video = 'TRUE'
GROUP BY 1
ORDER BY 2 DESC;

-- 4. For each album, calculate the total views of all associated tracks.
SELECT 
S.Album,
S.Track, 
SUM(S.Views) TOTAL_VIEWS
FROM Spotify.spotify S
WHERE S.Album_type = 'album'
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM
(SELECT 
S.Track,
COALESCE(SUM(CASE WHEN S.most_playedon = 'Youtube' then S.Stream END), 0) as stream_on_youtube,
COALESCE(SUM(CASE WHEN S.MOST_PLAYEDON = 'Spotify' then S.Stream END), 0) as stream_on_spotify,
FROM Spotify.spotify S
GROUP BY 1) TEMP
WHERE stream_on_spotify > stream_on_youtube
AND stream_on_youtube <> 0;

-- ### Advanced Level
-- 1. Find the top 3 most-viewed tracks for each artist using window functions.
WITH rank_artist AS
(SELECT 
S.Artist,
S.Track,
SUM(S.Views) TOTAL_VIEWS,
DENSE_RANK() OVER(PARTITION BY S.Artist ORDER BY SUM(S.Views) DESC) AS RANK
FROM Spotify.spotify S
GROUP BY 1,2
ORDER BY 1,3 DESC)

SELECT * FROM rank_artist
where rank <= 3;

-- 2. Write a query to find tracks where the liveness score is above the average.
SELECT AVG(S.Liveness) FROM Spotify.spotify S; --0.1936

SELECT 
S.Artist,
S.Track,
S.Liveness  
FROM Spotify.spotify S 
WHERE S.Liveness > (SELECT AVG(S.Liveness) FROM Spotify.spotify S);


-- 3. Use a `WITH` clause to calculate the difference between 
--the highest and lowest energy values for tracks in each album.

WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM Spotify.spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC;

   
-- 4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT S.Artist,
S.Track,
S.Energy,
S.Liveness,
COALESCE((S.Energy/S.Liveness),0) AS el_ratio 
FROM Spotify.spotify S
WHERE S.Energy <> 0
AND S.Energy/S.Liveness > 1.2;


-- 5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT S.Track,
SUM(S.Views) Total_views, 
SUM(S.Likes) Total_likes,
DENSE_RANK() OVER(PARTITION BY SUM(S.Likes) ORDER BY SUM(S.Views) DESC) AS rank
FROM Spotify.spotify S
GROUP BY 1;




