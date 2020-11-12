#!/bin/bash
set -e

################################################################################
# Install GAP
# echo -e "\nInstalling GAP..."
# if [ "$GAP" == "required" ]; then
#   GAP=v`grep "GAPVERS" $HOME/digraphs/PackageInfo.g | awk -F'"' '{print $2}'`
# fi

# Pull the docker container
docker pull gapsystem/gap-container:latest 

# Start the docker container detached
ID=$(docker run --rm -i -d -e SUITE -e PACKAGES -e DIGRAPHS_LIB gapsystem/gap-container)

GAP_HOME=$(docker exec $ID bash -c 'echo "$GAP_HOME"')

# Copy the digraphs directory into the container
docker cp . $ID:$GAP_HOME/pkg/digraphs

# Run the ci/docker-test.sh script in the running container
docker exec -i $ID "$GAP_HOME/pkg/digraphs/ci/docker-test.sh" ; exit

# Attach to the container
docker attach $ID
