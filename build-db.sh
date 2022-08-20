#!/bin/bash

DBFILE=cosmotalks.db

#===========
# IMPORTANT
#===========
# The cosmotalks.csv header line must be: rowid,talk,series,talkdate,related_info
# The series.csv header line must be: id,series,talks_list,website,series_info

#========
# Step 1: 
#========
# Import new talks and series data from .csv files; create db files if not existing

echo Importing data into $DBFILE

# If an existing $DBFILE is present, move it to a backup copy. This avoids potential
#   issues with the load.
if [[  -f "$DBFILE" ]]; then
  echo Creating backup file $DBFILE.bkup from existing db as a safeguard in case of  
  echo any problems. It can be deleted if desired after the successfull new build.
  mv $DBFILE $DBFILE.bkup
fi

sqlite3 $DBFILE 'CREATE TABLE IF NOT EXISTS "series" ("id" INTEGER PRIMARY KEY, "series" TEXT default "", "talks_list" TEXT default "", "website" TEXT default "", "series_info" TEXT default "");'
sqlite3 $DBFILE 'CREATE TABLE IF NOT EXISTS "talks" ("rowid" INTEGER PRIMARY KEY, "talk" TEXT default "", "series" INTEGER default 0, "talkdate" TEXT default "", "related_info" TEXT default "", FOREIGN KEY ("series") REFERENCES [series](id));'
sqlite3 $DBFILE 'CREATE INDEX ["talks_series"] ON [talks]("series");'
sqlite3 $DBFILE "CREATE TABLE IF NOT EXISTS 'ytids' (rowid integer primary key, ytid text);"

# Import the csv data into the series and talks tables 
sqlite-utils insert cosmotalks.db series series.csv --csv
sqlite-utils insert cosmotalks.db talks cosmotalks.csv --csv

echo 'Checking for any blank values in talk column; if there are any, cosmotalks.csv needs to be updated'
sqlite3 $DBFILE "select talk from talks where talk=''"
echo 'Checking for any nulls in talk column; if there are any, cosmotalks.csv needs to be updated'

echo 'Checking for any uninitalized values in series column of talks data; if any, cosmotalks.csv needs to be updated'
sqlite3 $DBFILE "select rowid, * from talks where series = 0"
#echo 'Checking for any nulls in series column of talks data; if any, cosmotalks.csv needs to be updated'

#========
# Step 2:
#========
# Create the ytids table (youtube video snaphot images) 
# Execute php program to create youtube video ids used to create image urls 

if [[  -f "populate-ytids-table.php" ]]; then
  echo 'Creating the ytids table' 
  sqlite3 $DBFILE "CREATE TABLE IF NOT EXISTS 'ytids' (rowid integer primary key, ytid text);"
  php populate-ytids-table.php
fi

sqlite3 $DBFILE VACUUM;

echo 'The database load is now completed with new talks, series, and youtube video id data'
 
