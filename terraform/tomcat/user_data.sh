#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -e

echo "Starting user data script..."

# Update the system and install Java
echo "Updating the system..."
if sudo yum update -y; then
    echo "System updated successfully."
else
    echo "Failed to update the system."
fi

echo "Installing Java..."
if sudo dnf install java-17-amazon-corretto -y; then
    echo "Java installed successfully."
else
    echo "Failed to install Java."
fi

# Download and extract Tomcat
echo "Downloading Tomcat..."
if cd /home/ec2-user && sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.31/bin/apache-tomcat-10.1.31.tar.gz; then
    echo "Tomcat downloaded successfully."
else
    echo "Failed to download Tomcat."
fi

echo "Extracting Tomcat..."
if sudo tar -xvf apache-tomcat-10.1.31.tar.gz; then
    echo "Tomcat extracted successfully."
else
    echo "Failed to extract Tomcat."
fi

sudo rm -f apache-tomcat-10.1.31.tar.gz  # Clean up

# Set permissions for webapps directory
echo "Setting permissions for webapps directory..."
if sudo chmod 700 /home/ec2-user/apache-tomcat-10.1.31/webapps; then
    echo "Permissions set successfully."
else
    echo "Failed to set permissions."
fi

sudo mkdir -p /home/ec2-user/apache-tomcat-10.1.31/webapps/manager/META-INF

# Create context.xml
echo "Creating context.xml..."
if cat <<EOT | sudo tee /home/ec2-user/apache-tomcat-10.1.31/webapps/manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true">
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor" sameSiteCookies="strict" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOT
then
    echo "context.xml created successfully."
else
    echo "Failed to create context.xml."
fi

# Set permissions on context.xml
echo "Setting permissions on context.xml..."
if sudo chmod 600 /home/ec2-user/apache-tomcat-10.1.31/webapps/manager/META-INF/context.xml; then
    echo "Permissions on context.xml set successfully."
else
    echo "Failed to set permissions on context.xml."
fi

# Create tomcat-users.xml
echo "Creating tomcat-users.xml..."
if cat <<EOT | sudo tee /home/ec2-user/apache-tomcat-10.1.31/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="rao" password="rao" roles="manager-gui,manager-script"/>
</tomcat-users>
EOT
then
    echo "tomcat-users.xml created successfully."
else
    echo "Failed to create tomcat-users.xml."
fi

# Set permissions on tomcat-users.xml
echo "Setting permissions on tomcat-users.xml..."
if sudo chmod 600 /home/ec2-user/apache-tomcat-10.1.31/conf/tomcat-users.xml; then
    echo "Permissions on tomcat-users.xml set successfully."
else
    echo "Failed to set permissions on tomcat-users.xml."
fi

# Start Tomcat
echo "Starting Tomcat..."
if sudo /home/ec2-user/apache-tomcat-10.1.31/bin/shutdown.sh || true; then
    echo "Tomcat shutdown command executed."
else
    echo "Failed to execute shutdown command."
fi

if sudo /home/ec2-user/apache-tomcat-10.1.31/bin/startup.sh; then
    echo "Tomcat started successfully."
else
    echo "Failed to start Tomcat."
fi

echo "User data script completed."
