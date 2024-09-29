#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read usr
tries=0

NUMBER=$(( (RANDOM % 1000) + 1 ))
echo "spy--$RANDOM"
old_user=$($PSQL "select username from users where username='$usr'")

echo "$old_user"
if [[ -z $old_user ]] # if the old_user is null/ add the new usr to the users table
  then # greet and add the usr to the users table
    # greeting the new user
    echo "Welcome, $usr! It looks like this is your first time here."
    # add new user
    add_usr=$($PSQL "insert into users(username) values('$usr');")
    u_id=$($PSQL "select user_id from users where username='$usr'")

  else
    u_id=$($PSQL "select user_id from users where username='$usr'")
    games_played=$($PSQL "select count(*) from games where user_id='$u_id'")
    best_game=$($PSQL "select min(guesses) from games where user_id='$u_id'")
    echo "Welcome back, $usr! You have played $games_played games, and your best game took $best_game guesses."    
fi

# Guess the number
echo "Guess the secret number between 1 and 1000:"
read guess

until [[ $guess == $NUMBER ]]
do
  while [[ ! $guess =~ ^[0-9]+$ ]]
  do 
  echo "That is not an integer, guess again:"
  (( tries++ ))
  read guess
  done

  if [[ $guess > $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    (( tries++ ))
    read guess
  elif [[ $guess < $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    (( tries++ ))
    read guess
  fi
done

(( tries++ ))

# add to games (user_id and n of guesses)
add_usr_id_tries=$($PSQL "insert into games(user_id,guesses) values('$u_id','$tries');")

echo "You guessed it in $tries tries. The secret number was $NUMBER. Nice job!"
