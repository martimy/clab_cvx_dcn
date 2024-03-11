#!/bin/bash

docker run -it -v $(pwd)/:/home/user \
           -e HISTFILE=/home/user/.bash_history \
           --rm --net clab \
           martimy/ansible:1.0
