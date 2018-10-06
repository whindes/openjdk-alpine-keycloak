FROM openjdk:8-jdk-alpine3.8
LABEL maintainer="William Hindes <bhindes@hotmail.com>" 

RUN apk update && \
    apk --no-cache add wget bash \
 && rm -rf /var/cache/apk/* 


ENV KEYCLOAK_VERSION 4.5.0.Final
ENV MSSQL_JDBC_VERSION 7.0.0.jre8
ENV SAXON_VERSION 9.9
ENV SAXON_ZIP_VERSION 9-9-0-1J

# Set the default JAVA_OPTS
ENV JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Djava.security.egd=file:/dev/./urandom

RUN wget -nv https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz && \
tar xfz keycloak-$KEYCLOAK_VERSION.tar.gz -C / && \
mv /keycloak-$KEYCLOAK_VERSION /keycloak && \
rm -rf /keycloak-$KEYCLOAK_VERSION.tar.gz && \
addgroup -g 1000 keycloak && \
adduser -u 1000 -D -h /keycloak -s /bin/bash -G keycloak keycloak && \
mkdir -p /keycloak/modules/system/layers/base/com/microsoft/sqlserver/jdbc/main && \
wget -nv http://central.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/$MSSQL_JDBC_VERSION/mssql-jdbc-$MSSQL_JDBC_VERSION.jar && \
mv mssql-jdbc-$MSSQL_JDBC_VERSION.jar /keycloak/modules/system/layers/base/com/microsoft/sqlserver/jdbc/main/mssql-jdbc.jar \
&& mkdir -p /usr/share/java/saxon \
&& wget -nv http://downloads.sourceforge.net/project/saxon/Saxon-HE/$SAXON_VERSION/SaxonHE$SAXON_ZIP_VERSION.zip \
&& mv SaxonHE$SAXON_ZIP_VERSION.zip /usr/share/java/saxon/saxon.zip \
&& unzip /usr/share/java/saxon/saxon.zip -d /usr/share/java/saxon \
&& rm -rf /usr/share/java/saxon/noticies /usr/share/java/saxon/doc \
/usr/share/java/saxon/saxon9-test.jar /usr/share/java/saxon/saxon9-unpack.jar /usr/share/java/saxon/saxon.zip

# Transform Database Connection parameters
ADD configuration/changeDatabase.xsl /keycloak/
RUN java -jar /usr/share/java/saxon/saxon9he.jar -s:/keycloak/standalone/configuration/standalone.xml \
-xsl:/keycloak/changeDatabase.xsl -o:/keycloak/standalone/configuration/standalone.xml && \
java -jar /usr/share/java/saxon/saxon9he.jar -s:/keycloak/standalone/configuration/standalone-ha.xml \
-xsl:/keycloak/changeDatabase.xsl -o:/keycloak/standalone/configuration/standalone-ha.xml && \
rm /keycloak/changeDatabase.xsl

ADD databases/mssql/module.xml /keycloak/modules/system/layers/base/com/microsoft/sqlserver/jdbc/main
ADD docker-entrypoint.sh /keycloak/

RUN chmod +x /keycloak/docker-entrypoint.sh && chmod -R 755 /keycloak

WORKDIR /keycloak
USER keycloak

EXPOSE 8080

HEALTHCHECK --interval=20s --timeout=5s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["/bin/bash", "/keycloak/docker-entrypoint.sh"]