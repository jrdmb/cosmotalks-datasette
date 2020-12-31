# cosmotalks-datasette

This is a work-in-progress on a database collection of links to research or academic talks by cosmologists intended for others in the field. The data is currently gathered from [155 diverse sources](https://jrdmb.netlify.app/crt-series.html) (called 'series') that have published talks from conferences, seminars, workshops, course lectures, summer schools, colloquia, etc. Currently 5,098 online talks are listed, and more are forthcoming. 

This collection was started out of personal interest as a service to the cosmology community because no one site was found that comprehensively compiles such data from a wide range of sources. There are many sources available so this represents only a fraction of the total that's out there; still, it's a starter attempt to extend beyond what's otherwise available in one place. 

The basic data structure is a talk title, including presenter(s), the series site hosting the talk video (e.g., [Cosmology Talks on YouTube](https://www.youtube.com/channel/UCstdttIo3HM6h3hDk_v2hug/videos)), and a talk date (`yyyy-mm-dd` format). Partial dates may exclude `dd` or `mm-dd` but any date entry should include `yyyy` as a minimum.

There are two database application versions available for querying the data (it's nice to have options with different features!). The [first version](https://jrdmb.netlify.app.crt.html) has the most up-to-date live data and is recommended for most purposes. The [second app](https://cosmotalks-cy6xkkbezq-uw.a.run.app/) is more full-featured but by nature of the Google Cloud Run service on which it's hosted, the database is static and thus does not have the very latest data updates until the app is periodically rebuilt and uploaded to Cloud Run. New data is published to it approximately every 2 weeks. A list of talks that have been collected (and are present in the first version) but are pending a periodic update into the Cloud Run app is available [here](https://jrdmb.netlify.app?fruo6fjhooe3ytfo).

The remaining info below has details about the second version of the app, its code, and how it's built.

[Datasette](https://datasette.io/) is the open-source tool used to publish the data. It was created by [Simon Willison](simonwillison.net) ([github repo](https://github.com/simonw/datasette), [@simonw](https://twitter.com/simonw) on twitter). Many thanks to Simon for making this excellent tool available - it's a great match for this project and also especially for projects utilizing SQLite database files. This app can be self-hosted locally or remotely using Datasette, and it can also be hosted as a Docker container - see the [Publishing Data](https://docs.datasette.io/en/latest/publish.html) section of the Datasette documentation. 

## Installation

This is an overview of the general procedure to build and run this locally or remotely, perhaps adding your own data to the .csv source files. The notes below are specific to a linux install. Simon's docs include instructions for a [Datasette installation on a Mac](https://docs.datasette.io/en/stable/installation.html#using-homebrew).

[SQLite3](https://www.sqlite.org/index.html) is required and assumed to be installed.

[Install Datasette](https://docs.datasette.io/en/stable/installation.html#basic-installation)

Install required Datasette plugins [csvs-to-sqlite](https://github.com/simonw/csvs-to-sqlite), [datasette-render-markdown](https://github.com/simonw/datasette-render-markdown), and [datasette-template-sql](https://github.com/simonw/datasette-template-sql).

Build the `cosmotalks.db` and `series.db` database files by executing bash shell script `build-db.sh`. If you wish to add your own data, first edit files `cosmotalks.csv` and `series.csv`.  Note the comments in the shell script.

An option for the db build: many of the videos are hosted on YouTube which has a feature providing a [link to a snapshot image file of the video](https://support.google.com/youtube/answer/72431?hl=en). An example of such an image is included at the bottom of this page*. (Thanks to Simon Willison for the tip about this feature.) To include references to these snapshots requires execution of PHP program `populate-ytids-table.php` during the build. If the snapshots are desired and your setup has the ability to execute PHP programs, the build script automatically runs the program.  If you don't want the images or you don't have PHP available, delete the `populate-ytids-table.php` php program before executing the build.

## Running the Cosmotalks app

After the build step, the basic command and optional parameters to execute the app are listed in the [documentation here](https://docs.datasette.io/en/stable/getting_started.html#datasette-serve-help). Also refer to the [Deploying Datasette](https://docs.datasette.io/en/stable/deploying.html#running-datasette-behind-a-proxy) section of the documentation. The command I use to start the app on a local linux server is:

`nohup datasette cosmotalks.db -m metadata.json --template-dir=templates/ --plugins-dir=plugins/ --setting suggest_facets off --setting default_facet_size 15 2>&1 &`

The app listens on port 8001 by default, a different port can be specified with the `-p` parameter.

The web app can then be accessed locally at `http://127.0.0.1:8001`. To run it behind a proxy for remote access, see [this doc section](https://docs.datasette.io/en/stable/deploying.html#deploying-datasette). See [this](https://docs.datasette.io/en/stable/deploying.html) for other deployment options.

--- 

\* **Example of the optional YouTube image feature:** 

![youtube snapshot image](https://github.com/jrdmb/cosmotalks-datasette/blob/main/static/row-view-with-yt-image.jpg)

