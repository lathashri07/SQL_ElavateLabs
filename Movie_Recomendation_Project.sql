-- #### STEP 1: DEFINE SCHEMA (MySQL Version) ####
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Users;

-- Users table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Movies table
CREATE TABLE Movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    release_year INT
);

-- Reviews table (Combines "Ratings" and "Reviews")
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    user_id INT NOT NULL,
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 0.5 AND rating <= 10.0), -- e.g., 8.5
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign key constraints
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,

    -- A user can only review a movie once
    UNIQUE(movie_id, user_id)
);

-- Create indexes for faster joins
CREATE INDEX idx_movie_id ON Reviews (movie_id);
CREATE INDEX idx_user_id ON Reviews (user_id);

---
-- #### STEP 2: INSERT SAMPLE IMDB-STYLE DATA ####
-- (This data is standard SQL and remains unchanged)

-- Insert Users
INSERT INTO Users (username) VALUES
('alice_movieFan'),
('bob_critic'),
('charlie_sciFi'),
('diana_drama');

-- Insert Movies
INSERT INTO Movies (title, genre, release_year) VALUES
('The Shawshank Redemption', 'Drama', 1994),
('The Godfather', 'Crime', 1972),
('The Dark Knight', 'Action', 2008),
('Inception', 'Sci-Fi', 2010),
('Forrest Gump', 'Drama', 1994),
('The Matrix', 'Sci-Fi', 1999),
('Pulp Fiction', 'Crime', 1994),
('Interstellar', 'Sci-Fi', 2014);

-- Insert Reviews
INSERT INTO Reviews (user_id, movie_id, rating, review_text) VALUES
-- Alice (Likes Sci-Fi and Drama)
(1, 4, 9.5, 'Mind-bending! A masterpiece of sci-fi.'),
(1, 6, 9.0, 'A classic that redefined the genre.'),
(1, 1, 8.0, 'Perfect movie. Cried at the end.'),
(1, 8, 8.5, 'Visually stunning, great story.'),
(1, 5, 7.0, 'A bit cheesy, but a good story.'),

-- Bob (Likes Crime)
(2, 2, 9.0, 'The greatest movie ever made. Period.'),
(2, 7, 9.0, 'Tarantino at his best.'),
(2, 3, 8.0, 'Great villain, but a bit long.'),
(2, 1, 8.5, 'Very solid drama.'),

-- Charlie (Likes Action and Sci-Fi)
(3, 3, 9.5, 'Heath Ledger was incredible.'),
(3, 6, 7.0, 'Whoa.'),
(3, 4, 9.0, 'Confusing but brilliant.'),
(3, 8, 9.5, 'My new favorite movie.'),
(3, 2, 7.0, 'Too slow for me.'),

-- Diana (Likes Drama)
(4, 1, 9.5, 'A truly moving story of hope.'),
(4, 5, 9.0, 'Tom Hanks is amazing.'),
(4, 2, 8.0, 'A classic, but very male-dominated.'),
(4, 8, 8.5, 'Loved the father-daughter story.');

---
-- #### STEP 3: AVERAGE RATING AND RANKING QUERIES ####

-- Query 1: Get average rating and number of ratings for all movies
SELECT
    m.title,
    m.genre,
    COUNT(r.rating) AS num_ratings,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM Movies m
JOIN Reviews r ON m.movie_id = r.movie_id
GROUP BY m.movie_id -- Group by ID for accuracy
ORDER BY average_rating DESC, num_ratings DESC;

---
-- #### STEP 4: CREATE VIEWS FOR RECOMMENDED MOVIES ####

CREATE OR REPLACE VIEW v_movie_ratings AS
WITH MovieStats AS (
    SELECT
        m.movie_id,
        m.title,
        m.genre,
        m.release_year,
        COUNT(r.rating) AS num_ratings,
        AVG(r.rating) AS avg_rating
    FROM Movies m
    LEFT JOIN Reviews r ON m.movie_id = r.movie_id
    GROUP BY m.movie_id
),
GlobalStats AS (
    -- C = The mean rating across all movies
    SELECT AVG(avg_rating) AS all_movies_avg FROM MovieStats WHERE num_ratings > 0
),
WeightedStats AS (
    -- m = Minimum votes required (let's use 2 for our small dataset)
    SELECT
        *,
        (SELECT all_movies_avg FROM GlobalStats) AS C,
        2 AS m
    FROM MovieStats
)
SELECT
    s.title,
    s.genre,
    s.release_year,
    s.num_ratings,
    ROUND(s.avg_rating, 2) AS average_rating,
    -- The Weighted Rating formula (MySQL version)
    ROUND(
        ( (s.num_ratings / (s.num_ratings + m)) * s.avg_rating ) +
        ( (m / (s.num_ratings + m)) * C ),
        2
    ) AS weighted_rating
FROM WeightedStats s
WHERE s.num_ratings >= m -- Only include movies that meet the minimum review count
ORDER BY weighted_rating DESC;

-- Now you can just query the view!
SELECT * FROM v_movie_ratings;

-- View 2: Top Action Movies
CREATE OR REPLACE VIEW v_top_action_movies AS
SELECT *
FROM v_movie_ratings
WHERE genre = 'Action'
ORDER BY weighted_rating DESC;

SELECT * FROM v_top_action_movies;

---
-- #### STEP 5: USE WINDOW FUNCTIONS TO TRACK TOP-RATED CONTENT ####

-- This query finds the Top 2 highest-rated movies *within each genre*
SELECT *
FROM (
    SELECT
        title,
        genre,
        weighted_rating,
        -- This window function partitions the data by genre,
        -- orders by rating, and assigns a rank.
        RANK() OVER (
            PARTITION BY genre
            ORDER BY weighted_rating DESC
        ) AS genre_rank
    FROM v_movie_ratings -- We re-use our view!
) AS RankedMovies
WHERE genre_rank <= 2; -- Filter for only the top 2 in each genre

---
-- #### STEP 6: EXPORT MOVIE RECOMMENDATION RESULTS ####
-- (This is the "Recommendation Report" deliverable)

SELECT * FROM v_movie_ratings WHERE weighted_rating > 8.0;