#FROM python:3.11-slim
FROM ubuntu

# Set the timezone of the Docker image by creating a symbolic link to the timezone
# information file and updating the /etc/timezone file with the specified timezone.
ENV TZ=America/Halifax
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ansible \
    openssh-server \
    python3-paramiko \
    python3-pip \
    sshpass && \
    rm -rf /var/lib/apt/lists/*

RUN pip install ansible-pylibssh
#RUN apt-get remove python3-pip
RUN apt-get autoremove
RUN ansible-galaxy collection install frr.frr nvidia.nvue

# Set working directory
WORKDIR /home/user

EXPOSE 22

# Define a build-time argument
ARG KEY_CHECKING=False

# Set an environment variable with the value from the build-time argument
ENV ANSIBLE_HOST_KEY_CHECKING=${KEY_CHECKING}

# Start SSH service
CMD service ssh start && /bin/bash
