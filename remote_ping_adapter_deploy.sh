#!/usr/bin/env bash
PING_INSTALL=/usr/local/pingfederate-1/server/default
PING_TEMPLATE=${PING_INSTALL}/conf/template

#sync adapters
RSYNC_COMMAND=$(rsync -a /home/ec2-user/target/ ${PING_INSTALL}/deploy/)
if [[ $? -eq 0 ]]; then
    # Success do some more work!
    if [[ -n "${RSYNC_COMMAND}" ]]; then
        # Stuff to run, because rsync has changes
        chown pingfederate:pingfederate ${PING_INSTALL}/deploy/*
    else
        echo "No changes targets"
    fi
else
    # Something went wrong!
    echo "RSYNC returned errors"
    exit 1
fi



# sync html file
RSYNC_COMMAND=$(rsync -avz resources/*.html ${PING_TEMPLATE})
if [[ $? -eq 0 ]]; then
    # Success do some more work!
    if [[ -n "${RSYNC_COMMAND}" ]]; then
        # Stuff to run, because rsync has changes
        chown pingfederate:pingfederate ${PING_TEMPLATE}/html.form.login.template-behaviosec.html
    else
        echo "No changes on html template"
    fi
else
    # Something went wrong!
    echo "RSYNC returned errors"
    exit 1
fi


# sync java scripts
RSYNC_COMMAND=$(rsync -avz resources/*.js ${PING_TEMPLATE}/assets/scripts/)
if [[ $? -eq 0 ]]; then
    # Success do some more work!
    if [[ -n "${RSYNC_COMMAND}" ]]; then
        # Stuff to run, because rsync has changes
        chown pingfederate:pingfederate ${PING_TEMPLATE}/assets/scripts/*.js
    else
        echo "No changes on collector"
    fi
else
    # Something went wrong!
    echo "RSYNC returned errors"
    exit 1
fi



# sync images
RSYNC_COMMAND=$(rsync -avz resources/*.png ${PING_TEMPLATE}/assets/images/)
if [[ $? -eq 0 ]]; then
    # Success do some more work!
    if [[ -n "${RSYNC_COMMAND}" ]]; then
        # Stuff to run, because rsync has changes
        chown pingfederate:pingfederate ${PING_TEMPLATE}/assets/images/*.png
    else
        echo "No changes on collector"
    fi
else
    # Something went wrong!
    echo "RSYNC returned errors"
    exit 1
fi


# restart the service
service pingfederate-1 restart