#!/bin/bash

echo "#######################################################"
# Ask user for the bucket name
echo "#######################################################"
read -p "Enter the name of the S3 bucket: " bucket_name

# Copy artifact from S3 bucket to /tmp directory
aws s3 cp s3://$bucket_name/vprofile-v2.war /tmp/

# Stop Tomcat service if running
echo "#######################################################"
echo "Stopping Tomcat service..."
echo "#######################################################"
sudo systemctl stop tomcat9

# Remove existing Tomcat ROOT directory if the service is stopped
if ! sudo systemctl is-active --quiet tomcat9; then
    echo "#######################################################"
    echo "Removing existing Tomcat ROOT directory..."
    echo "#######################################################"
    sudo rm -rf /var/lib/tomcat9/webapps/ROOT

    # Copy the artifact to Tomcat's webapps directory
    sudo cp /tmp/vprofile-v2.war /var/lib/tomcat9/webapps/ROOT.war

    # Start Tomcat service
    echo "#######################################################"
    echo "Starting Tomcat service..."
    echo "#######################################################"
    sudo systemctl start tomcat9

    # Display the content of application.properties file
    echo "#######################################################"
    echo "Checking if correct file was copied..."
    echo "#######################################################"
    sudo cat /var/lib/tomcat9/webapps/ROOT/WEB-INF/classes/application.properties
else
    echo "#######################################################"
    echo "Tomcat service is still running. Cannot remove directory."
    echo "#######################################################"
fi