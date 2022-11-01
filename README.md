## Monitoring Solution using Amazon CloudWatch

## Scope ##
This monitoring solution can used for Self-Managed Oracle installation on EC2 and RDS Custom for Oracle environment. In both the cases, you have access to the underlying instances/servers.

Monitoring is an important part of maintaining the reliability, availability, and performance of any infrastructure environment. This solution can be extended to monitor self-managed Oracle installations on Amazon Elastic Compute Cloud (Amazon EC2). This will enable you to monitor the health of Oracle instances (both RDS Custom and Self-Managed) and observe changes to the infrastructure and databases workloads. You can monitor metrics over a specific time period and set CloudWatch alarms to receive notifications.

In this post, we will integrate this tool with RDS Custom for Oracle environment. 



## Metrics collected by this method ##

**1. Infrastructure** - CPUUtilization, FreeableMemory, FreeStorageSpace , Load Average

| **Console Name**       | **Description**                                                                     | **Units** |
|------------------------|-------------------------------------------------------------------------------------|-----------|
| **Data_FreeSpace_GB**  | The amount of available storage space in the Data Volume.                           | GB        |
| **Bin_FreeSpace_GB**   | The amount of available storage space in the Binary Volume (Oracle_Home)            | GB        |
| **Root_FreeSpace_GB**  | The amount of available storage space in the Root Volume                            | GB        |
| **CPUUtilization**     | The percentage of CPU utilization.                                                  | Percent   |
| **FreeableMemory**     | The amount of available random access memory.                                       | GB        |
| **Database_available** | PMON Process checker. It will return 1 if the process in available and 0 otherwise. |           |
| **Load_Average**       | Publish the server Load Average                                                     |


 **2. Workload** - ReadIOPS, WriteIOPS, ReadThroughput, WriteThroughput and DatabaseConnections

| **Console Name**         | **Description**                                                                             | **Units**    |
|--------------------------|---------------------------------------------------------------------------------------------|--------------|
| **Read IOPS**            | The average number of disk read I/O operations per second.                                  | Count/Second |
| **Write IOPS**           | The average number of disk write I/O operations per second.                                 | Count/Second |
| **Write Throughput**     | The average number of bytes written to disk per second.                                     | MB/Second    |
| **Read Throughput**      | The average number of bytes read from disk per second.                                      | MB/Second    |
| **Database_Connections** | The number of client network connections to the database instance via Oracle listener port. | Count        |


**3. Performance** - ReadLatency, WriteLatency, DiskQueueDepth

This will indicate the performance metrics of the database workload and you’ll can make more informed decisions about performance of your RDS Custom environment. 

| **Console Name**      | **Description**                                                                  | **Units**    |
|-----------------------|----------------------------------------------------------------------------------|--------------|
| **Avg Read Latency**  | The average amount of time taken per disk Read I/O operation.                    | Milliseconds |
| **Avg Write Latency** | The average amount of time taken per disk Write I/O operation.                   | Milliseconds |
| **Avg Queue Length**  | The number of outstanding I/Os (read/write requests) waiting to access the disk. | Count        |

The solution will fetch data from the AWS/EBS, AWS/EC2 and CWAgentCustom namespace in CloudWatch for the Infrastructure and performance related information. This data will be transformed into Graphs in the Amazon EC2 console (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using_cloudwatch_ebs.html#graphs-in-the-aws-management-console-2) by using mathematical expressions and publishing those into AWS CloudWatch. The data related to Database Connections and Memory will be collected via a shell script installed in the host and it will be pushed into custom namespace. These data will be populated in the Custom CloudWatch Dashboard for visualization. Additionally, we will demonstrate AWS CloudWatch Alarms creation on few metrics widgets to receive alerts over email. 


## Pre - Requisites ##
Familiarity with the following AWS services:

    * Amazon RDS Custom for Oracle
    * Amazon CloudWatch
    * Amazon EC2
    * AWS Command Line Interface

Required Permissions :

To access CloudWatch dashboards, you need one of the following IAM permissions :
The *AdministratorAccess* policy
The *CloudWatchFullAccess* policy

Due to security reason, you can follow the principle of least privilege and add custom policy that includes one or more of these specific permissions:
*cloudwatch:GetDashboard* and *cloudwatch:ListDashboards* ** to view dashboards
*cloudwatch:PutDashboard* to create or modify dashboards
*cloudwatch:DeleteDashboards* to delete dashboards


## Installation Process ##

1. Identify the EC2 Instance ID from the AWS Console
2. Identify the EBS Volumes <rdsdbdata> attached to the instance using 

Check for /rdsdbdata as it is the mount point for the data volumes for the custom environment. Use below command to get the volumeIds:

lsblk -o +SERIAL

3. Download and install the custom monitoring scripts

Download the 3 Scripts from this URL in a directory.  For example, I created a directory called “automate” under /home/ec2-user and placed all the 3 files.

``` bash
 pwd
home/ec2-user/automate
$ ls -ltrh
-rwxrwxr-x 1 ec2-user ec2-user 3.2K Oct 12 06:47 custommetrics.sh
-rw-rw-r— 1 ec2-user ec2-user 23K Oct 16 06:29 dash.json
-rwxrwxr-x 1 ec2-user ec2-user 1.7K Oct 16 06:39 installer.sh
$
```

* custommetrics.sh : This script collects memory, TCP connections at port 1521 (Oracle listener port), to publish in the custom CloudWatch namespace. 

* dash.json : This is the dashboard configuration file. It fetches raw data from the AWS/EC2 , AWS/EBS, and Custom namespaces and performs mathematical calculations to display CloudWatch metrics on the dashboard.

* installer.sh : This script will automate the installation process. WE WILL WORK WITH THIS SCRIPT ONLY.

Make the below script executable. 

``` bash
chmod +x installer.sh
```

Run this Script and it will ask for the 4 Volume ID attached to the RDS instance, the EC2 instance ID, the preferred name of the dashboard and the preferred name of the CloudWatch Namespace to hold the Data from EC2 instance.  
This script will perform the following:

* Update the EC2 instance ID in the custommetric.sh and dash.json
* Update the EC2 instance ID and volume ID in the respective files. 
* Install the custommetric.sh in Crontab 
* Install the dashboard in CloudWatch 

. installer.sh

``` bash
. installer.sh 
Enter First Volume ID (Format vol-xxxxxx)
vol-12345a
Enter Second Volume ID (Format vol-xxxxxx)
vol-67890b
Enter Third Volume ID (Format vol-xxxxxx)
vol-12345c
Enter Fourth Volume ID (Format vol-xxxxxx)
vol-67890d
Enter EC2 Instance ID (Format i-xxxxxx)
i-abcde
Enter the Name of CloudWatch Dashboard (Example - <RDS_Name>_Dashboard)
custom19_dashboard
Enter the Name of Custom Namespace for propagating Host Level metrics (Example - <RDS_Name>_Agent)
custom19c_namespace
Enter the Region of the Database Instance (Example - us-east-1)
us-east-1
These are the following Volume ID and the EC2 instance ID
vol-12345a
vol-67890b
vol-12345c
vol-67890d
i-abcde
Preparing the shell Script custommetric.sh
Installing the Script in Crontab
rdsdb     1750     1  0 Oct08 ?        00:01:02 ora_pmon_ORCL
Custom Metric Shell Script is ready and installed in crontab at 60 seconds frequency.
Preparing the dashboard.json file
The Script is ready
Installing the Script in Amazon CloudWatch
{
    "DashboardValidationMessages": []
}
Installation Successful. Please login to AWS Console and check the dashboard. The metrics might take few minutes to populate in CloudWatch
$ 
```

The final graphs will look like as below:

![image description](dashboard_example.png)





## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

