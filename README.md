# PhotoSync

## Description

The PhotoSync is designed to automate the process of organizing and moving media files based on their metadata. It
utilizes a set of scripts to rename and relocate image and video files from source directories to a destination
directory, maintaining a structured folder layout based on the creation date of the media files. The image can be
configured to run these tasks either on demand or on a schedule using CRON expressions.

## Environment Variables

The behavior of the PhotoSync Docker container can be customized using the following environment variables:

| Variable           | Description                                                 |
|--------------------|-------------------------------------------------------------|
| `CRON_1`           | CRON schedule for the first job. Leave blank to run once.   |
| `CRON_2`           | CRON schedule for the second job. Leave blank to run once.  |
| `SOURCE_PATH_1`    | The first source directory to monitor and move files from.  |
| `SOURCE_PATH_2`    | The second source directory to monitor and move files from. |
| `DESTINATION_PATH` | The destination directory where files should be moved to.   |
| `USER_ID`          | The user ID that should own the process and output files.   |
| `GROUP_ID`         | The group ID that should own the process and output files.  |

## Running the Docker Image with Docker

To start a container with default settings, simply run:

```bash
docker run -d \
  -v /path/to/input1:/mnt/input_1 \
  -v /path/to/input2:/mnt/input_2 \
  -v /path/to/output:/mnt/output \
  ecw74/photosync
```

This command will start the PhotoSync process, watching /mnt/input_1 and /mnt/input_2 directories inside the container
and moving processed files to /mnt/output.

## Running the Docker Image with Docker Compose

To use Docker Compose, create a docker-compose.yml file with the following content:

```yaml
version: '3'

services:
  photosync:
    image: ecw74/photosync
    volumes:
      - /path/to/input1:/mnt/input_1
      - /path/to/input2:/mnt/input_2
      - /path/to/output:/mnt/output
    environment:
      - CRON_1=<cron-schedule-1>
      - CRON_2=<cron-schedule-2>
      - USER_ID=1000
      - GROUP_ID=1000
```

Replace <cron-schedule-1> and <cron-schedule-2> with your desired CRON schedules. After setting up the
docker-compose.yml file, run the following command to start the container:

```shell
docker-compose up -d
```

## Docker Hub Repository

The Docker image `ecw74/photosync` can be found on Docker Hub at the following URL:

https://hub.docker.com/repository/docker/ecw74/photosync/