# ACServerManager
Web based server manager for Assetto Corsa directly manipulating the ini files on the server as an alternative to the windows app and having to copy files to your server.

Start and stop the server, and stracker directly from the application, meaning you can make changes to the server configuration and restart the server directly from your browser or mobile phone.

## ACServerManager on Windows
This is the installation guide for a Windows machine, to review the Linux installation guide go [here](https://github.com/jo3stevens/ACServerManager/blob/master/README_Linux.md).

## Updates
01/05/2018
* Dockerized! - Adding Docker build file to allow ACServer & ACServerManager run in a container.

25/12/2017
* Add support for uploading tracks (both single and multi-layout) and cars
* Add support for removing existing tracks and cars
* Bumping version of ACManager to 1.0.0!

21/12/2017
* Update for 1.16 AC patch
* Added local car / skins generation script for v1.16 AC original + DLC content

24/05/2017
* Update for 1.14 AC patch
* Fixed a number of saving issues
* Added local car & track content option

27/01/2017:
* Update to UI layout
* Added restart feature for ACServer & sTracker server

17/10/2015:
* Bug fix when switching between two tracks with multiple track configs
* Added Max Ballast and UDP Plugin fields to Advanced page
* Added new setting for contentPath allowing server and content folders to be seperated (this happens when using a manager package from the kunos tool). If this setting it left empty it will assume the content folder is inside the server folder

22/08/2015:
* Finished adding all the new settings from 1.2 including tyres and weather

## Installation Details
Note: If you've been using the new windows server manager that came with 1.2 then you may not need this step as when you package the server files it does the same thing.

The application needs some additional files added to the server/content/tracks and server/content/cars folders to be able to choose track configurations and car skins.

Copy acServerManager.bat to your root aessettocorsa folder and run it to copy the required folders into server/content/*. You'll then need to copy the content folder to your server.

For tracks it will copy the ui folder which will contain sub folders when there are multiple track configurations. It will also copy the contents of these directories which contains additional track information which is displayed when choosing a track.

For cars it will copy the skins/* folder structure but not the files; this is just to be able to choose the skin when setting up the entry list.

## Install Node.js
To install Node.js, follow the installation guide on its home page [here](https://nodejs.org).

## Install ACServerManager
Create a directory called 'acmanager', go into that directory and click [here](https://github.com/jo3stevens/ACServerManager/archive/master.zip) to download the latest version. Extract 
the contents of the zip file into the directory.

## ACServerManager Configuration
To configure your manager's settings, open the 'settings.js' file. You'll see a number of variables, point the 'serverPath'
to your Assetto Corsa Server directory. You can configure your username, password & port settings for ACServerManager, also 
if you use sTracker, point the 'sTrackerPath' variable to your installation.

* serverPath: The path to your Assetto Corsa server directory
* contentPath: The path to your Assetto Corsa content directory, use this if hosting on the same machine for gaming. Leave blank if hosting on Linux.
* useLocalContent: If set to true, then ACServerManager will look for local car / track content
* sTrackerPath: The path to your sTracker directory that contains stracker.exe (If you don't run stracker just leave this as an empty string ('') to disable it
* username/password: Set these values if you want basic authentication on the application
* port: The port that the application will listen on (Be sure to open up this port on your firewall)

Note: I've currently set the Assetto Corsa Server installation to one directory up in 'server', change if necessary.

## Firewall
If your machine has a firewall enabled (i.e) windows firewall, you'll need to open / allow the ACServerManager port defined in your settings.js file.

## Running ACServerManager
You first need to make sure you have the necessary Node.js dependencies, run the following command in the command prompt in the same directory as the 'server.js' file:
```
npm install
```
To run ACServerManager, execute the 'start.bat' file. If you see no errors, ACServerManager should now be running.

## Docker Image
You can use the docker image easily run the entire ACServer & ACServerManager inside a container. The build currently grabs the latest version of steamcmd & installs all the necessary files, dependencies & executables on top of a ubuntu:xenial (16.04) image. 

Pull the latest image:
```
docker pull pringlez/acserver-manager
```
To run the image directly:
```
docker run --restart unless-stopped --name acserver-manager --net=host -e PUID=<UID> -e PGID=<GID> -e TZ=<timezone> -v </path/to/acmanager>:/home/gsa/acmanager -v </path/to/acserver>:/home/gsa/server -t pringlez/acserver-manager
```

To create a container:
```
docker create --restart unless-stopped --name acserver-manager --net=host -e PUID=<UID> -e PGID=<GID> -e TZ=<timezone> -v </path/to/acmanager>:/home/gsa/acmanager -v </path/to/acserver>:/home/gsa/server -t pringlez/acserver-manager
```

Then just visit your server's address + ACServerManager port in your browser!

If you need to login to the running docker container:
```
docker exec -it acserver-manager /bin/bash
```

### Parameters
The parameters you need to include are the following:

* --net=host - Shares host networking with container, required.
* --restart unless-stopped - This will restart your container if it crashes
* -v /home/gsa/acmanager - Volume mount the ACServerManager installation directory (Optional)
* -v /home/gsa/server - Volume mount the ACServer installation directory (Optional)
* -e PGID for for GroupID - see below for explanation
* -e PUID for for UserID - see below for explanation
* -e TZ for timezone information, Europe/London

### User / Group Identifiers
Sometimes when using data volumes (-v flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user PUID and group PGID. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance PUID=1001 and PGID=1001. To find yours use id user as below:
```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

### Building an Image
You can however build a local image if want to include any new changes to ACServerManager.

You need to specify the ports you'll be using for the ACServer & ACServerManager. The docker build will expose the ports you specify.
You also need to specify a username & password for steamcmd to download the ACServer files, I recommend making a new separate account for download server files for security reasons.

Note: Having special characters in the provided password may produce errors in the image build process.

Build a local docker image by:
```
docker build --build-arg ACMANAGER_PORT=42555 --build-arg ACSERVER_PORT_1=9600 --build-arg ACSERVER_PORT_2=8081 --build-arg STEAM_USERNAME=<your-username> --build-arg STEAM_PASSWORD=<your-password> --build-arg VCS_REF=`git rev-parse --short HEAD` -t pringlez/acserver-manager .
```

## Using ACServerManager
* Browse to the application using your servers IP and the chosen port (or any DNS configured)
* Click the 'Start' button under Assetto Corsa Server section
* If using sTracker wait until the ACServer has started and then click 'Start' in the sTracker Server section

The server should now be running. You'll be able to see any server output in the command window and it will be logged to a file in the 'ACServerManager/log' folder.

You can change any of settings and it will be applied directly to server_cfg.ini and entry_list.ini on the server. After making a change just stop and start the server from the Server Status page to apply the changes to Assetto Corsa Server.

Note, the server may fail to start in some cases if the Assetto Corsa Server cannot connect to the master server. Make sure you portforward / open
the necessary ports for the server to function correctly.

## Screenshots
### Server Status
![Server Status](http://deltahosting.dyndns.org:8080/acmanager/screen-cap-1.JPG)

### Server Configuration
![Server Config](http://deltahosting.dyndns.org:8080/acmanager/screen-cap-2.JPG)

### Entry List
![Entry List](http://deltahosting.dyndns.org:8080/acmanager/screen-cap-3.JPG)

### Rules
![Rules](http://deltahosting.dyndns.org:8080/acmanager/screen-cap-4.JPG)

### Advanced
![Advanced](http://deltahosting.dyndns.org:8080/acmanager/screen-cap-5.JPG)
