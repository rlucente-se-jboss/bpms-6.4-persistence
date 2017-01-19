INSTALL BPMS
============
These scripts simplify creating a clean, never-been-run installation
of BPMS 6.4.  This has been tested and confirmed to work on RHEL
using the PostgreSQL packages provided by RHEL.

Initial Install of BPMS
-----------------------
Make sure to populate the dist directory with the files listed in
its README.md.

The eap-auto.xml and bpms-auto.xml scripts will be automatically
set so that so that the ~~~~<installpath/>~~~~ element matches the intended
installation location.  This script will install BPMS 6.4 in the
same directory as these scripts.  These scripts will install the
software in:

    $HOME/demo/bpms-6.4/bpms/jboss-eap-6.4

If you change that location, also edit demo.conf and make sure that
~~~~JBOSS_HOME~~~~ matches the new location.

To remove an installation, simply type:

    ./clean.sh

And to install the software, simply type:

    ./install.sh

The install.sh script adds additional users for BPMS.  You can add
additional users to support your use cases as needed.  Passwords
for administrative users, admin and bpmsAdmin, are set in their
respective *.variables file.

Setting Up Persistence with PostgreSQL
--------------------------------------
The following steps are also documented in chapter 3 of the JBoss
BPM Suite Installation Guide.  These instructions and scripts follow
the best practice of having separate databases:  one for business-central
and dashbuilder and another for kie-server.

Run the following script to install, initialize, and setup the
PostgreSQL databases.  The user running this *MUST* have sudo
privileges for this work.

    ./setup-postgresql.sh

When prompted for a password, please enter 'jbpm' so that it matches
the other configuration settings.  Once this script has completed
successfully, start the BPMS server in the background:

    ./start.sh &

After the server has fully started, use the CLI to setup the
PostgreSQL datasources and then shutdown the server:

    ./bpms/jboss-eap-6.4/bin/jboss-cli.sh -c \
        --file=use-pg-db/setup-datasource.cli
    ./bpms/jboss-eap-6.4/bin/jboss-cli.sh -c --command=":shutdown"

Edit the persistence.xml file within the exploded business-central.war
to use the PostgreSQLDS data source.  Specifically, edit the file:

    ./bpms/jboss-eap-6.4/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml

and make the following changes within the file (shown in unified
diff format):

    -    <jta-data-source>java:jboss/datasources/ExampleDS</jta-data-source>
    +    <jta-data-source>java:jboss/datasources/PostgreSQLDS</jta-data-source>
    
    -      <property name="hibernate.dialect" value="org.hibernate.dialect.H2Dialect" />
    +      <property name="hibernate.dialect" value="org.hibernate.dialect.PostgreSQLDialect" />

Next, edit the file:

    bpms/jboss-eap-6.4/standalone/deployments/dashbuilder.war/WEB-INF/jboss-web.xml

and make the following changes (shown in unified diff format):

    -        <jndi-name>java:jboss/datasources/ExampleDS</jndi-name>
    +        <jndi-name>java:jboss/datasources/PostgreSQLDS</jndi-name>

To configure the kie-server persistence, edit the file:

    ./bpms/jboss-eap-6.4/standalone/configuration/standalone.xml

and modify the system-properties element to contain the following:

    <system-properties>
        <property name="org.kie.server.repo" value="${jboss.server.data.dir}"/>
        <property name="org.kie.example" value="true"/>
        <property name="org.jbpm.designer.perspective" value="full"/>
        <property name="designerdataobjects" value="false"/>
        <property name="org.kie.server.user" value="bpmsUser"/>
        <property name="org.kie.server.pwd" value="admin1jboss!"/>
        <property name="org.kie.server.location" value="http://localhost:8080/kie-server/services/rest/server"/>
        <property name="org.kie.server.controller" value="http://localhost:8080/business-central/rest/controller"/>
        <property name="org.kie.server.controller.user" value="kieserver"/>
        <property name="org.kie.server.controller.pwd" value="kieserver1!"/>
        <property name="org.kie.server.id" value="local-server-123"/>
    
        <!-- Data source properties. -->
        <property name="org.kie.server.persistence.ds" value="java:jboss/datasources/PostgreSQLKIEDS"/>
        <property name="org.kie.server.persistence.dialect" value="org.hibernate.dialect.PostgreSQLDialect"/>
    </system-properties>

Running BPMS
------------
Make sure to start the server using the script:

    ./start.sh

The reason for this is that BPMS creates its own git and maven
repositories based on the current directory where the server was
launched.  To make sure that repositories aren't created in multiple
locations, the server should be started from a consistent location.

