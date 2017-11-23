# Equal Experts

## Introduction
This script is a Linux-shell monitoring tool that sends a notification every time a new gist is published from a given GitHub user.

Requirements:
As given:
"Using the Github API you should query a user’s publicly available github gists.
The script should then tell you when a new gist has been published."

***Assumptions***
- Scripting language: Bash (could run on any Linux host without any additional language/framework package)
- OS chosen for the POC (proof of concept): Linux RedHat Enterprise
- Notification: Simple notification output on the standard i/o stream
- Code Management System: GitHub
- Delivery Method: as suggested in the initial requirements, the script will be delivered in a zip file to the client

***How it works***

The script uses the GitHub REST API v.3 to pull the list of gists from the given user. An infinite loop compares gists creation times at a given frequency (by default every 30sec). If a gist creation is found more recent than the latest recorded, a notification is sent on the standard i/o stream. The script will die if the GitHub user cannot be found or the limit of REST API calls has been exceeded.

***Improvement Suggestions***
- Persistant Storage: it was written to be run as a background process but could be improved by using some persistent data mechanism to store the list of gists, hence allowing to compare its contents everytime the script is run. Such a strategy would allow the script to run intermittently, using a cron tab for instance or run from a scheduled job in any CI tool.
- Email Notification: the notification could be improved by sending an email to a distribution list so that the script i/o stream does not need to be monitored
- Error Management: the REST API may trigger errors that are not taken into consideration, at the moment the script will die only when the given user is not found, or when the limit of API calls has been esceeded.

## Getting Started

This section will run through the script usage.

### Prerequisites

The script provided runs in a Linux shell environment. As long as Bash is available (*/usr/bin/bash*), no pre-requisites are required.

### How-to Use

```
Usage: ./checkGists.sh [options]
   ./checkGists.sh <GITHUB_USERNAME>

Parameters:
    GITHUB_USERNAME: GitHub user monitored by the script

Extra Options:
    -h: Show the script usage help
    -v: Add debug traces
    -t: Time in seconds separating two GitHub API calls pulling gists data. By default, it is set to 30sec.
```

Example of Output (*non-verbose*):

```
[ec2-user@ip-xxx-xx-xx-xxx ~]$ ./checkGists.sh -t 30 tomeskenazi
NEW GIST PUBLISHED
NEW GIST PUBLISHED
```

Example of Output (*verbose*):

```
[ec2-user@ip-xxx-xx-xx-xxx ~]$ ./checkGists.sh -v -t 30 tomeskenazi
[DEBUG] USERNAME: tomeskenazi
[DEBUG] FREQUENCY: 30
[DEBUG] FUNC: Found Created at: 2017-11-22T10:27:11Z
[DEBUG] FUNC: Latest Created at: 2017-11-22T10:27:11Z
[DEBUG] FUNC: Found Created at: 2017-11-21T12:31:06Z
[DEBUG] Latest Created Gist: 1511346431
[DEBUG] FUNC: Found Created at: 2017-11-22T10:27:11Z
[DEBUG] FUNC: Latest Created at: 2017-11-22T10:27:11Z
[DEBUG] FUNC: Found Created at: 2017-11-21T12:31:06Z
[DEBUG] Latest Gist published at 1511346431
[DEBUG] FUNC: Found Created at: 2017-11-23T12:37:11Z
[DEBUG] FUNC: Latest Created at: 2017-11-23T12:37:11Z
[DEBUG] FUNC: Found Created at: 2017-11-22T10:27:11Z
[DEBUG] FUNC: Found Created at: 2017-11-21T12:31:06Z
NEW GIST PUBLISHED
[DEBUG] Latest Gist published at 1511440631
```

## Authors

* **Thomas Eskenazi** - *Initial work* - As part of an exercise requested by Equal Experts

## License

<Not specified>
