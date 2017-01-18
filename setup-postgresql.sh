#!/bin/bash

. `dirname $0`/demo.conf

PUSHD ${WORK_DIR}
    echo "Install the database ..."
    sudo yum -y install postgresql postgresql-server postgresql-jdbc

    echo "Initialize the database ..."
    sudo postgresql-setup initdb

    echo "Enable password authentication to the database ..."
    sudo -u postgres sed -i 's/ident$/md5/g' /var/lib/pgsql/data/pg_hba.conf

    echo "Enable the database service ..."
    sudo systemctl enable postgresql

    echo "Start the service ..."
    sudo systemctl start postgresql

    echo "Create the BPMS user and set password to 'jbpm' ..."
    sudo -u postgres createuser -P jbpm

    echo "Create the BPMS database for business-central and dashbuilder ..."
    sudo -u postgres createdb -O jbpm jbpm

    echo "Create the BPMS database for kie-server ..."
    sudo -u postgres createdb -O jbpm jbpmkie

    echo "Extract the BPMS supplementary tools ..."
    unzip -q ${BIN_DIR}/jboss-bpmsuite-${VER_BPMS_DIST}-supplementary-tools.zip

    echo "Import the DDL scripts for business-central and dashbuilder (password is 'jbpm') ..."
    PUSHD jboss-brms-bpmsuite-6.4-supplementary-tools/ddl-scripts/postgresql
        psql -h 127.0.0.1 -U jbpm jbpm < postgresql-jbpm-schema.sql
        psql -h 127.0.0.1 -U jbpm jbpm < postgres-dashbuilder-schema.sql
    POPD

    echo "Import the DDL scripts for kie-server (password is 'jbpm') ..."
    PUSHD jboss-brms-bpmsuite-6.4-supplementary-tools/ddl-scripts/postgresql
        psql -h 127.0.0.1 -U jbpm jbpmkie < postgresql-jbpm-schema.sql
    POPD

    echo "Install the PostgreSQL module into EAP ..."
    mkdir -p ${JBOSS_HOME}/modules/org/postgresql/main
    PUSHD ${JBOSS_HOME}/modules/org/postgresql/main
        cp ${WORK_DIR}/use-pg-db/module.xml .
        ln -s /usr/share/java/postgresql-jdbc.jar .
    POPD
POPD
