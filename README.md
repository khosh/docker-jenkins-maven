docker-jenkins-maven
===================================
Docker Container for Jenkins Plugin Development
includes Ubuntu 16.04 LTS, OpenJDK 8, Jenkins 2.176.2, and Maven 3.3.9.
https://hub.docker.com/r/kiyostar/jenkins-maven

## Run the container
To run the container, type like the following:

    docker run -it \
      -u root \
      --rm \
      -p 8080:8080 \
      -p 50000:50000 \
      -v /etc/localtime:/etc/localtime:ro \
      -v /etc/group:/etc/group:ro \
      -v /etc/passwd:/etc/passwd:ro \
      -v /var/lib/jenkins:/var/lib/jenkins \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /root/.m2:/root/.m2 \
      --name jenkins-service \
      kiyostar/jenkins-maven bash

## Start Jenkins Server
To start Jenkins, type the following commands on the container's command prompt:

    su jenkins
    java -jar /usr/share/jenkins/jenkins.war

## Stop Jenkins Server
To stop Jenkins, use the Jenkins POST:

    http://<jenkins.server>/exit

## Maven Setup
1) Setup plugin and proxy in /root/.m2/settings.xml .
   See detail on https://wiki.jenkins.io/display/JENKINS/Plugin+tutorial

2) archetype-catalog.xml (optional)

       cd /root/.m2/repository/
       wget http://repo1.maven.org/maven2/archetype-catalog.xml
    
## Develop Jenkins Plugin
1) simple-java-maven-app build.
   See detail on https://jenkins.io/doc/tutorials/build-a-java-app-with-maven/
       
       git clone https://github.com/jenkins-docs/simple-java-maven-app.git
       cd simple-java-maven-app
       mvn -B -DskipTests clean package

2) hello-world-plugin generate and verify and install.
   See detail on https://jenkins.io/doc/developer/tutorial/create/

       mvn -U archetype:generate -Dfilter=io.jenkins.archetypes:
       # Select 4. hello-world-plugin 
       # Select 5. version 1.5
       # Enter "demo" for artifactId
       # Type just ENTER for 1.0-SNAPSHOT and io.jenkins.plugins.sample
       # Type "y" for confirmation
       mv demo demo-plugin
       cd demo-plugin/
       mvn verify
       mvn install
    
3) hello-world-plugin generate and verify and install.
   See detail on https://jenkins.io/doc/developer/tutorial/run/

       mvn hpi:run
       # Go to http://<jenkins.server>/jenkins
       # Create a new freestyle job
       # Build with "Say hello world" step
