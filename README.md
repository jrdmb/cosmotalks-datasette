# cosmotalks-datasette

This is a work-in-progress on a database collection of links to research or academic talks by cosmologists intended for others in the field. The data is currently gathered from [206 diverse sources](https://jrdmb.netlify.app/crt-series.html) (called 'series') that have published talks from conferences, seminars, workshops, course lectures, summer schools, colloquia, etc. Currently 7,182 online talks are listed, and more are forthcoming. 

This collection was started out of personal interest as a service to the cosmology community because no one site was found that comprehensively compiles such data from a wide range of sources. There are many sources available so this represents only a fraction of the total that's out there; still, it's a starter attempt to extend beyond what's otherwise available in one place. 

The basic data structure is a talk title, including presenter(s), a link to the site hosting the talk video (e.g., [Cosmology Talks on YouTube](https://www.youtube.com/channel/UCstdttIo3HM6h3hDk_v2hug/videos)), a talk date (`yyyy-mm-dd` format), and any related info. 

Originally, there were two database apps available for querying this data. The original version used the 
[Datasette](https://datasette.io/) open-source tool created by [Simon Willison](simonwillison.net) ([github repo](https://github.com/simonw/datasette), [@simonw](https://twitter.com/simonw) on twitter). Datasette is an excellent tool to quickly and easily create applications using Sqlite3 database files that can either be hosted remotely or self-hosted locally - see the [Publishing Data](https://docs.datasette.io/en/latest/publish.html) section of the Datasette documentation. The Datasette version of the app was hosted on the Google Cloud Run service. However, there were certain complications using the Cloud Run service and the decision was made to go forward with only the app that is available at [https://jrdmb.netlify.app/crt.html](https://jrdmb.netlify.app/crt.html).

The following info has details for those wishing to build the Datasette version of the app for their own purposes.

## Installation

This is an overview of the general procedure to build and run the Datasette app locally or remotely, perhaps adding your own data to the .csv source files. The notes below are specific to a linux install. Simon's docs also include instructions for a [Datasette installation on a Mac](https://docs.datasette.io/en/stable/installation.html#using-homebrew).

[SQLite3](https://www.sqlite.org/index.html) is required and assumed to be installed.

[Install Datasette](https://docs.datasette.io/en/stable/installation.html#basic-installation)

Install required Datasette plugins [csvs-to-sqlite](https://github.com/simonw/csvs-to-sqlite), [datasette-render-markdown](https://github.com/simonw/datasette-render-markdown), and [datasette-template-sql](https://github.com/simonw/datasette-template-sql).

Build the `cosmotalks.db` database file from source .csv files (cosmotalks.csv and series.csv) by executing bash shell script `build-db.sh`. If you wish to add your own data, first edit files `cosmotalks.csv` and `series.csv`.  Note the comments in the shell script.

An option for the db build: many of the videos are hosted on YouTube which has a feature providing a [link to a snapshot image file of the video](https://support.google.com/youtube/answer/72431?hl=en). An example of such an image is included at the bottom of this page*. (Thanks to Simon Willison for the tip about this feature.) To include references to these snapshots requires execution of PHP program `populate-ytids-table.php` during the build. If the snapshots are desired and your setup has the ability to execute PHP programs, the build script automatically runs the program.  If you don't want the images or you don't have PHP available, delete the `populate-ytids-table.php` php program before executing the build.

## Running the Cosmotalks app

After the build step, the basic command and optional parameters to execute the app are listed in the [documentation here](https://docs.datasette.io/en/stable/getting_started.html#datasette-serve-help). Also refer to the [Deploying Datasette](https://docs.datasette.io/en/stable/deploying.html#running-datasette-behind-a-proxy) section of the documentation. The command I use to start the app on a local linux server is:

`nohup datasette cosmotalks.db -m metadata.json --template-dir=templates/ --plugins-dir=plugins/ --setting suggest_facets off --setting default_facet_size 15 2>&1 &`

The app listens on port 8001 by default, a different port can be specified with the `-p` parameter.

The web app can then be accessed locally at `http://127.0.0.1:8001`. To run it behind a proxy for remote access, see [this doc section](https://docs.datasette.io/en/stable/deploying.html#deploying-datasette). See [this](https://docs.datasette.io/en/stable/deploying.html) for other deployment options.

## Cosmology Resource Materials page

Users of this database may also find useful the [Cosmology Resource Materials](https://github.com/jrdmb/cosmology-resource-materials) page.

--- 

\* **Example of the optional YouTube image feature:** 

![youtube snapshot image](https://github.com/jrdmb/cosmotalks-datasette/blob/main/static/row-view-with-yt-image.jpg)

