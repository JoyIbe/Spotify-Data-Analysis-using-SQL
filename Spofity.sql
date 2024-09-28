-- Create table 'spotify'

CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--EDA
SELECT * FROM spotify
LIMIT 100
SELECT artist, MAX(danceability) FROM spotify
GROUP BY 1 ORDER BY 2 DESC
SELECT * FROM spotify WHERE danceability = 0.975;
SELECT COUNT(*) FROM spotify;
SELECT DISTINCT  artist FROM spotify
SELECT COUNT(DISTINCT artist) FROM spotify
SELECT DISTINCT album_type FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min =  0;

SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;

-- Problem Statements & their Solution 

-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify 
WHERE stream > 1000000000;

-- 2.List all albums along with their respective artists.
SELECT DISTINCT album, artist
FROM spotify
ORDER BY 1 ; 

-- 3.Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) total_comments
FROM spotify 
WHERE licensed = 'true';

-- 4.Find all tracks that belong to the album type single.
SELECT * 
FROM spotify
WHERE album_type = 'single';

--5.Count the total number of tracks by each artist.
SELECT artist,
COUNT (*) total_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

--6.Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

--7.Find the top 5 tracks with the highest energy values.
SELECT energy
FROM spotify
ORDER BY 1 DESC;

SELECT track, energy
FROM spotify 
WHERE energy = 1 
GROUP BY 1,2
LIMIT ;

--8.List all tracks along with their views and likes where official_video = TRUE.
SELECT DISTINCT track, SUM(views) total_views, SUM(likes) total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC

--9.For each album, calculate the total views of all associated tracks.
SELECT album, track, SUM(views) total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

--10.Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(
SELECT track,
SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END)streamed_on_YT,
SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END) streamed_on_Spotify
FROM spotify
GROUP BY 1
) as t1
WHERE streamed_on_Spotify > streamed_on_YT
AND streamed_on_YT <> 0
ORDER BY 3 DESC;

--11.Find the top 3 most-viewed tracks for each artist using window functions.
-- Each artist and total views for each track in dense_rank 
-- In CTE,track the top 3 highest view for each artist 

WITH most_viewed_ranking AS
(
SELECT artist, track, SUM(views) total_views,
DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) rank
FROM spotify
GROUP BY 1,2
ORDER BY 1, 3 DESC
)
SELECT * FROM most_viewed_ranking
WHERE rank<= 3;

--12.Write a query to find tracks where the liveness score is above the average.
SELECT AVG(liveness) FROM spotify
SELECT * FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

--13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH calculation AS 
(
SELECT album, 
MAX(energy) highest_energy,
MIN(energy)lowest_energy
FROM spotify
GROUP BY 1
) 
SELECT album, 
highest_energy - lowest_energy AS energy_diference
FROM calculation
ORDER BY 2 DESC

--14.Find  where the energy-to-liveness ratio is greater than 1.2.
-- energy-to-liveness = energy / liveness > 1.2

SELECT track,energy,liveness,
(energy / liveness) energy_liveness_ratio
FROM spotify
WHERE  energy / liveness > 1.2
ORDER BY 4 DESC;


--15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT * FROM spotify
SELECT DISTINCT track,
SUM(likes) OVER (ORDER BY views) cummulative_sum
FROM spotify
ORDER BY cummulative_sum DESC;


