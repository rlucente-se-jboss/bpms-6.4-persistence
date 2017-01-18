#!/bin/bash

. `dirname $0`/demo.conf

PUSHD ${WORK_DIR}
    echo
    echo -n "Cleaning existing installation ... "
    ./clean.sh
    cmdok

    echo -n "Installing EAP ... "
    java -jar ${BIN_DIR}/jboss-eap-${VER_EAP_DIST}-installer.jar eap-auto.xml -variablefile eap-auto.xml.variables &> /dev/null
    cmdok

    echo -n "Applying EAP 6.4.9 patch ... "
    PATCH_FILE=${BIN_DIR}/jboss-eap-6.4.9-patch.zip
    CMD_CLI="patch apply --override-all $PATCH_FILE"
    $JBOSS_HOME/bin/jboss-cli.sh --command="$CMD_CLI" &> /dev/null
    cmdok

    echo -n "Applying EAP ${VER_EAP_PATCH} patch ... "
    PATCH_FILE=${BIN_DIR}/jboss-eap-${VER_EAP_PATCH}-patch.zip
    CMD_CLI="patch apply --override-all $PATCH_FILE"
    $JBOSS_HOME/bin/jboss-cli.sh --command="$CMD_CLI" &> /dev/null
    cmdok

    echo -n "Installing BPMS ... "
    java -jar ${BIN_DIR}/jboss-bpmsuite-${VER_BPMS_DIST}-installer.jar bpms-auto.xml -variablefile bpms-auto.xml.variables &> /dev/null
    cmdok

    # create users with other roles
    $JBOSS_HOME/bin/add-user.sh -a -p 'admin1jboss!' -u bpmsUser -s -ro user,kie-server
    $JBOSS_HOME/bin/add-user.sh -a -p 'kieserver1!' -u kieserver -s -ro user,kie-server
    echo
POPD
