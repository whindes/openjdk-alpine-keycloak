<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ds="urn:jboss:domain:datasources:5.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="//ds:subsystem/ds:datasources/ds:datasource[@jndi-name='java:jboss/datasources/KeycloakDS']">
        <ds:datasource jndi-name="java:jboss/datasources/KeycloakDS" enabled="true" use-java-context="true" pool-name="KeycloakDS" use-ccm="true">
            <ds:connection-url>jdbc:sqlserver://${env.MSSQL_HOST:host.docker.internal}:${env.MSSQL_PORT:1433};database=${env.MSSQL_DATABASE:keycloak};user=${env.MSSQL_USER:keycloak};password=${env.MSSQL_PASSWORD:P@ssw0rd!};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;</ds:connection-url>
            <ds:driver>sqlserver</ds:driver>
            <ds:security>
              <ds:user-name>${env.MSSQL_USER:keycloak}</ds:user-name>
              <ds:password>${env.MSSQL_PASSWORD:password}</ds:password>
            </ds:security>
            <ds:validation>
                <ds:check-valid-connection-sql>SELECT 1</ds:check-valid-connection-sql>
                <ds:background-validation>true</ds:background-validation>
                <ds:background-validation-millis>60000</ds:background-validation-millis>
            </ds:validation>
            <ds:pool>
                <ds:flush-strategy>IdleConnections</ds:flush-strategy>
                <ds:max-pool-size>20</ds:max-pool-size>
            </ds:pool>
        </ds:datasource>
    </xsl:template>

    <xsl:template match="//ds:subsystem/ds:datasources/ds:drivers">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
                <ds:driver name="sqlserver" module="com.microsoft.sqlserver.jdbc">
                    <ds:xa-datasource-class>com.microsoft.sqlserver.jdbc.SQLServerXADataSource</ds:xa-datasource-class>
                </ds:driver>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
