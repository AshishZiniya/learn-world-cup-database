#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | tail -n +2 | cut -d, -f3,4 | sort | uniq | while IFS="," read winner opponent
do
  # Insert each team
  for team in "$winner" "$opponent"
  do
    # Check if team already exists
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$team'")
    if [[ -z $TEAM_ID ]]; then
      # Insert new team if it doesn't exist
      $PSQL "INSERT INTO teams(name) VALUES ('$team')"
    fi
  done
done

# Insert games
cat games.csv | tail -n +2 | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")
  # Insert each game
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
  VALUES ($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
done