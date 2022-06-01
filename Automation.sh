#!/bin/sh
echo "Updating the Packages"
sudo apt update -y
sudo dpkg-query -l | grep apache
ap=`sudo dpkg-query -l | grep apache`
if [ -z $ap ]
then 
	sudo apt install apache2 -y
fi
aprun=`sudo systemctl status apache2 | grep Active |  awk '{print $3}'`
if [ "$aprun" -ne "(running)" ]
then 
	sudo systemctl start apache2
	sudo systemctl enable apache2
fi
cd /var/log
sudo tar -czf /tmp/ankit-http-log-`date '+%d%m%Y-%H%M%S'`.tar apache
apfile=`ls -lrth /tmp | grep ankit-http-log | tail -1 | awk '{print $9}'`

aws s3 \
cp /tmp/$apfile \
s3://${s3_bucket}/$apfile
### to check inventory.html

apinv=`ls -lrth /var/www/html/inventory.html`
if [ -z $apinv ]
then
echo "Log Type  Time Created    Type    Size" > /var/www/html/inventory.html
fi
typ=`echo $apfile | awk -F "." '{print $2}'`
sz=`du $apfile`
echo "httpd-logs    $dt    $typ   $sz" >> /var/www/html/inventory.html
