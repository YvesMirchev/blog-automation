#!/bin/bash

# Hide all command outputs
# exec > /dev/null

echo "#######################################################"
# Ask user for the domain name
echo "#######################################################"
read -p "Enter the name of the domain: " domain_name

echo "#######################################################"
# Ask user for the bucket name
echo "#######################################################"
read -p "Enter the name of the S3 bucket: " bucket_name

echo "#######################################################"
echo "Executing: Cloning the repository..."
echo "#######################################################"
# Clone the repository silently
git clone -q https://github.com/devopshydclub/vprofile-project.git
cd vprofile-project

# Define variables for replacement
DB_HOST="db01.$domain_name"
MC_HOST="mc01.$domain_name"
RMQ_HOST="rmq01.$domain_name"

echo "#######################################################"
echo "Executing: Modifying application.properties..."
echo "#######################################################"
# Replace occurrences in the application.properties file silently
awk -v db_host="$DB_HOST" -v mc_host="$MC_HOST" -v rmq_host="$RMQ_HOST" '
{
    gsub(/jdbc:mysql:\/\/db01:3306\/accounts/, "jdbc:mysql://" db_host ":3306/accounts")
    gsub(/memcached.active.host=mc01/, "memcached.active.host=" mc_host)
    gsub(/memcached.standBy.host=127.0.0.2/, "memcached.standBy.host=" mc_host)
    gsub(/rabbitmq.address=rmq01/, "rabbitmq.address=" rmq_host)
    print
}' src/main/resources/application.properties > temp.properties && mv temp.properties src/main/resources/application.properties

echo "#######################################################"
echo "Executing: Building the artifact..."
echo "#######################################################"
# Build the artifact silently
mvn install -q

echo "#######################################################"
echo "Executing: Copying the artifact to S3 bucket..."
echo "#######################################################"
# Copy artifact to the specified S3 bucket
aws s3 cp target/vprofile-v2.war "s3://$bucket_name"

echo "#######################################################"
echo "Execution complete. Artifact copied to $bucket_name"
echo "#######################################################"