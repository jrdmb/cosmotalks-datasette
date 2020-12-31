#!/bin/bash

DBFILE=cosmotalks.db

#========
# Step 1: 
#========
# Import new talks and series data from .cvs files; create db files if not existing
# The series.db is only needed temporarily during the build in order to add 2 extra
#   columns to the series table in the main DBFILE that are then imported into the
#   series.csv file. After that, series.db has no further usage and can be deleted
#   if desired.

echo Importing data into $DBFILE

# If an existing $DBFILE is present, move it to a backup copy. This avoids potential
#   issues with the load.
if [[  -f "$DBFILE" ]]; then
  echo Creating backup file $DBFILE.bkup from existing db as a safeguard in case of  
  echo any problems. It can be deleted if desired after the successfull new build.
  mv $DBFILE $DBFILE.bkup
fi

csvs-to-sqlite cosmotalks.csv --replace-tables -c series:series:series -t talks $DBFILE
csvs-to-sqlite series.csv --replace-tables -t series series.db

echo 'Checking for any nulls in talk column; if there are any, cosmotalks.csv needs to be updated'
sqlite3 $DBFILE "select talk from talks where talk is null"

# It's ok for talkdate to have some blank values, but make sure there are no nulls
sqlite3 $DBFILE "update talks set talkdate=\"\" where talkdate is null"

echo 'Checking for any nulls in series column of talks data; if any, cosmotalks.csv needs to be updated'
sqlite3 $DBFILE "select rowid, * from talks where series is null"

#========
# Step 2:
#========
# Populate series table with 2 extra columns not available in cosmotalks.csv file
# Extra column data is in series.csv: talks_list (markdown url), website (markdown url)
# There must be a row in series.csv for each unique series in cosmotalks.csv

echo Add columns talks_list and website to the $DBFILE series table
# Add columns talks_list and website to the $DBFILE series table
echo 'Creating 2 new columns in the series table'
sqlite3 $DBFILE "alter table series add column talks_list text default ''; alter table series add column website text default '';"

sqlite3 $DBFILE "attach database 'series.db' as db2; create table tempseries as select d.id, d.series, '[[link]](' || '/cosmotalks/talks?series=' || d.id || ')' as 'talks_list', '[[link]](' || d2.website || ')' as 'website' from series d join db2.series d2 on d.series = d2.series order by d.id;"

sqlite3 $DBFILE "update series set talks_list = (select talks_list from tempseries t where series.id = t.id), website = (select website from tempseries t where series.id = t.id) where id in (select id from tempseries);"

sqlite3 $DBFILE "drop table tempseries; VACUUM;"

#========
# Step 3:
#========
# Create the ytids table (youtube video snaphot images) 
# Execute php program to create youtube video ids used to create image urls 

if [[  -f "populate-ytids-table.php" ]]; then
  echo 'Creating the ytids table' 
  sqlite3 $DBFILE "CREATE TABLE IF NOT EXISTS 'ytids' (rowid integer primary key, ytid text);"
  php populate-ytids-table.php
fi

echo 'The database load is now completed with new talks, series, and youtube video id data'
 
