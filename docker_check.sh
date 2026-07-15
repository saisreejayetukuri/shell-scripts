#!/bin/bash

if docker --version > /dev/null 2>&1
then
    echo "Docker is installed."
else
    echo "Docker is not installed."
fi