# Data

The dataset used for this project was obtained from Kaggle and
contains information on Steam games, including estimated ownership,
price, reviews, genres, tags, languages, and player engagement.

The raw CSV files are not included in this repository due to
dataset size and distribution considerations.

The data was cleaned and prepared using Python/Pandas before
being imported into PostgreSQL.

## Dataset Structure

The analysis uses the following normalized tables:

- `games`
- `genres`
- `game_genres`
- `tags`
- `game_tags`
- `languages`
- `game_languages`
