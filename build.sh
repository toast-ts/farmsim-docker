#!/bin/bash

REGISTRY_TAG=sandbox

docker build -t ghcr.io/toast-ts/farmsim-docker:$REGISTRY_TAG .
