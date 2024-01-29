# Use the official Jenkins image as a parent image
FROM jenkins/jenkins:lts

# Switch to root to install Java
USER root

# Install OpenJDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk git && \
    apt-get clean;

# Set JAVA_HOME environment variable to point to the Java 17 installation
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64

# Switch back to the Jenkins user
USER jenkins
