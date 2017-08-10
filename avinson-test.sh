#!/bin/sh

docker build -t avinson/base-notebook -f docker/jupyter/docker-stacks/base-notebook/Dockerfile docker/jupyter/docker-stacks/base-notebook/
docker build -t avinson/minimal-notebook -f docker/jupyter/docker-stacks/minimal-notebook/Dockerfile docker/jupyter/docker-stacks/minimal-notebook/
docker build -t avinson/scipy-notebook -f docker/jupyter/docker-stacks/scipy-notebook/Dockerfile docker/jupyter/docker-stacks/scipy-notebook/
docker-compose build
docker-compose up
