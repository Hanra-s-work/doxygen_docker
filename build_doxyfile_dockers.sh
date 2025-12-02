#!/bin/bash
##
## EPITECH PROJECT, 2024
## terarea
## File description:
## build_doxyfile_dockers.sh
##


# Basic constants
YES="YES"
NO="NO"

# Global status
ERROR=1
SUCCESS=0
STATUS=$SUCCESS

# Global booleans
TRUE=1
FALSE=0

# Global admin stuff
SUDO=/bin/sudo

# Publish control
PUBLISH=$NO

# Docker container stuff
CONTAINER_NAME="doxygen"
CONTAINER_TAG="v$(date +"%Y-%m-%d")"
CONTAINER_PATH_NAME="hanralatalliard/${CONTAINER_NAME}"
CONTAINER_FINAL_NAME="${CONTAINER_PATH_NAME}:${CONTAINER_TAG}"
DOCKERFILE_PATH="."

function build_and_publish {
    local folder_name=$1
    local container_final_name=$2
    local dockerfile_path=$3
    local final_folder_name=$(echo "${folder_name}" | cut -d '/' -f 2)
    local container_name="${container_final_name}-fedora${final_folder_name}"
    local container_path="$dockerfile_path/$final_folder_name"
    echo "Building container $container_name located in $container_path"
    time $SUDO docker build -t $container_name $container_path
    if [ $? -ne 0 ]; then
        status=$?
        echo "Failed to build container: $container_name, exit status: $status"
        return $status
    fi
    if [ $PUBLISH == $NO ]; then
        echo "Publishing is disabled, skipping build for folder: $folder"
        return $SUCCESS
    fi
    echo "Pushing  container $container_name"
    time $SUDO docker push $container_name
    if [ $? -ne 0 ]; then
        status=$?
        echo "Failed to push container: $container_name, exit status: $status"
        return $status
    fi
    return $?
}

$SUDO docker container stop $CONTAINER_NAME
$SUDO docker container rm -f $CONTAINER_NAME
$SUDO docker volume prune -f

FOLDERS=$(find . -maxdepth 1 -type d -not -name "." -not -name ".." | sort)
for folder in $FOLDERS; do
    build_and_publish "$folder" "$CONTAINER_FINAL_NAME" "$DOCKERFILE_PATH"
    if [ $? -ne 0 ]; then
        status=$?
        echo "A container process failed to succeed, aborting build"
        exit $status
    fi
done
