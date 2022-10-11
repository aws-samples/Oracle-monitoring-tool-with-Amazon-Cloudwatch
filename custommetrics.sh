 #!/bin/bash
USEDMEMORY=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')

TCP_CONN_PORT_1521=$(netstat -an | grep 1521 | wc -l)

DataVolume=`df -kP|grep rdsdbdata|awk '{print $4/1048576}'|paste -sd+|bc`
BinVolume=`df -kP|grep rdsdbbin|awk '{print $4/1048576}'|paste -sd+|bc`
RootVolume=`df -kP|grep -w "/"|grep dev  |awk '{print $4/1048576}'|paste -sd+|bc`

aws cloudwatch put-metric-data --metric-name memory-usage --dimensions Instance=i-0ea2648c36a7c0574  --namespace "CWAgentCustom" --value $USEDMEMORY
aws cloudwatch put-metric-data --metric-name TCP_connection_on_port_1521 --dimensions Instance=i-0ea2648c36a7c0574  --namespace "CWAgentCustom" --value $TCP_CONN_PORT_1521
aws cloudwatch put-metric-data --metric-name Data_FreeSpace_GB --dimensions Instance=i-0ea2648c36a7c0574  --namespace "CWAgentCustom" --value $DataVolume
aws cloudwatch put-metric-data --metric-name Bin_FreeSpace_GB --dimensions Instance=i-0ea2648c36a7c0574  --namespace "CWAgentCustom" --value $BinVolume
aws cloudwatch put-metric-data --metric-name Root_FreeSpace_GB --dimensions Instance=i-0ea2648c36a7c0574  --namespace "CWAgentCustom" --value $RootVolume