# Use a base image with Maven to build the Java web application
FROM maven:latest AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven project's pom.xml to the container
COPY pom.xml .

# Download the dependencies (this step is cached unless the pom.xml changes)
RUN mvn dependency:go-offline

# Copy the rest of the application code to the container
COPY src/ ./src/

# Build the Java web application using Maven
RUN mvn clean package

# Use a base image with a Java servlet container (Tomcat, for example) to run the Java web application
FROM tomcat:latest

# Remove the default ROOT folder and ROOT.war from Tomcat's webapps directory
RUN rm -rf /usr/local/tomcat/webapps/ROOT*

# Copy your own WAR file to the container's webapps directory and name it ROOT.war
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose the port used by your Java web application (if needed)
EXPOSE 8080

# Start Tomcat using catalina.sh when the container starts
CMD ["catalina.sh", "run"]
