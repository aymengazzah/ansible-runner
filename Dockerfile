
ARG registry_default=docker.io
ARG parent_version_default=bookworm-slim


ARG parent_version_replace_with=1.0

ARG image_version
FROM ${registry_default}/debian:${parent_version_default}

# Add image information
LABEL \
    category="ansible" \
    scope="runner" \
    maintainers="GAZZAH Aymen"

# Set non interactive frontend for debian apt
ENV DEBIAN_FRONTEND=noninteractive

# Create a user for running Ansible
RUN useradd -u 2000 -m ansible

# Packages installation
COPY requirements_deb .
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends $(sed -e '/^#/d' requirements_deb) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm requirements_deb

# Copy ansible.cfg into the container
COPY --chown=ansible:ansible ansible.cfg /etc/ansible/

RUN mkdir /ansible-project /runner && \
    chown ansible:ansible /ansible-project /runner 

# Copy the entrypoint script into the container
COPY /runner/* /runner/
RUN chmod +x /runner/*

# Switch to the non-root user
USER ansible

# Set the working directory
WORKDIR /ansible-project

ENTRYPOINT ["python3", "/runner/entrypoint.py"]

