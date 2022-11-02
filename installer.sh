export PATH=$PATH:/usr/local/bin

echo "Enter First Volume ID (Format vol-xxxxxx)"
read vol1
echo "Enter Second Volume ID (Format vol-xxxxxx)"
read vol2
echo "Enter Third Volume ID (Format vol-xxxxxx)"
read vol3
echo "Enter Fourth Volume ID (Format vol-xxxxxx)"
read vol4
echo "Enter EC2 Instance ID (Format i-xxxxxx)"
read inst
echo "Enter the Name of CloudWatch Dashboard (Example - <RDS_Name>_Dashboard)"
read dash
echo "Enter the Name of Custom Namespace for propagating Host Level metrics (Example - <RDS_Name>_Agent)"
read agent
echo "Enter the Region of the Database Instance (Example - us-east-1)"
read region

sleep 5

echo "These are the following Volume ID and the EC2 instance ID"
echo $vol1
echo $vol2
echo $vol3
echo $vol4
echo $inst

sleep 5
echo "Preparing the shell Script custommetric.sh"

sed -i "s/i-DDDDDD/$inst/g" custommetrics.sh
sed -i "s/CWAgentCustom/$agent/g" custommetrics.sh

chmod +x custommetrics.sh

cp -rp ./custommetrics.sh /home/ec2-user/custommetrics.sh 

echo "Installing the Script in Crontab"

 
crontab -l >mycron
echo "* * * * * /home/ec2-user/custommetrics.sh" >>mycron
crontab mycron
rm mycron
. custommetrics.sh
sleep 5

echo "Custom Metric Shell Script is ready and installed in crontab at 60 seconds frequency."

echo "Preparing the dashboard.json file"

sed -i "s/vol-AAAAAA/$vol1/g" dash.json
sed -i "s/vol-BBBBBB/$vol2/g" dash.json
sed -i "s/vol-CCCCCC/$vol3/g" dash.json
sed -i "s/vol-XXXXXX/$vol4/g" dash.json
sed -i "s/i-DDDDDD/$inst/g"  dash.json
sed -i "s/awsregion/$region/g"  dash.json

sed -i "s/CWAgentCustom/$agent/g"  dash.json
sleep 5

echo "The Script is ready"
echo "Installing the Script in Amazon CloudWatch"

aws cloudwatch put-dashboard --dashboard-name $dash --dashboard-body file://dash.json --region $region 
sleep 5

echo "Installation Successful." 
sleep 3
echo  "Please login to AWS Console and check the dashboard.The metrics might take few minutes to populate in CloudWatch."