#!/bin/bash

# docker build & push script for skaffold
# see skaffold.yaml & https://github.com/GoogleContainerTools/skaffold/blob/master/docs/content/en/docs/pipeline-stages/builders/custom.md

DOCKER_BUILDKIT=1 docker build . -f ./Dockerfile -t $IMAGE

if [ $PUSH_IMAGE ]; then
  docker push $IMAGE
fi