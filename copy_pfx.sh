#!/bin/bash

docker cp `docker-compose ps -q web`:/home/dev/rootCA.pfx ./
