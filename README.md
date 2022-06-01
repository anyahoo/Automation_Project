# Automation_Project
#!/bin/sh
#Updating the packages.
echo "Updating the Packages"
sudo apt update -y
# Checking if apache is installed
sudo dpkg-query -l | grep apache
ap=`sudo dpkg-query -l | grep apache`
# If apache is not found installing it. 
if [ -z $ap ]
then 
	sudo apt install apache2 -y
fi
aprun=`sudo systemctl status apache2 | grep Active |  awk '{print $3}'`
if [ "$aprun" -ne "(running)" ]
then 
# Starting the Apache and enabeling Apache
	sudo systemctl start apache2
	sudo systemctl enable apache2
fi
# Creating .tar file
cd /var/log
sudo tar -czf /tmp/ankit-http-log-`date '+%d%m%Y-%H%M%S'`.tar apache
apfile=`ls -lrth /tmp | grep ankit-http-log | tail -1 | awk '{print $9}'`

aws s3 \
cp /tmp/$apfile \
s3://${s3_bucket}/$apfile
