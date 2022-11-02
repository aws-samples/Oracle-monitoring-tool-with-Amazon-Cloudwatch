 #!/bin/bash
export PATH=$PATH:/usr/local/bin

USEDMEMORY=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')

TCP_CONN_PORT_1521=$(netstat -an | grep 1521 | wc -l)

DataVolume=`df -kP|grep rdsdbdata|awk '{print $4/1048576}'|paste -sd+|bc`
BinVolume=`df -kP|grep rdsdbbin|awk '{print $4/1048576}'|paste -sd+|bc`
RootVolume=`df -kP|grep -w "/"|grep dev  |awk '{print $4/1048576}'|paste -sd+|bc`
LOADAVG=`uptime | awk -F'[, ]*' '{print $11}'`
LOADROUND=`echo "${LOADAVG}" | awk '{printf("%d\n",$1 + 0.5)}'`
FLAGVAR=0
if ps -ef|grep ora_pmon_*|grep -v grep ; then
FLAGVAR=1
fi

aws cloudwatch put-metric-data --metric-name memory-usage --dimensions Instance=i-DDDDDD  --namespace "CWAgentCustom" --value $USEDMEMORY
aws cloudwatch put-metric-data --metric-name TCP_connection_on_port_1521 --dimensions Instance=i-DDDDDD  --namespace "CWAgentCustom" --value $TCP_CONN_PORT_1521
aws cloudwatch put-metric-data --metric-name Data_FreeSpace_GB --dimensions Instance=i-DDDDDD  --namespace "CWAgentCustom" --value $DataVolume
aws cloudwatch put-metric-data --metric-name Bin_FreeSpace_GB --dimensions Instance=i-DDDDDD --namespace "CWAgentCustom" --value $BinVolume
aws cloudwatch put-metric-data --metric-name Root_FreeSpace_GB --dimensions Instance=i-DDDDDD  --namespace "CWAgentCustom" --value $RootVolume
aws cloudwatch put-metric-data --metric-name Load_Average --dimensions Instance=i-DDDDDD  --namespace "CWAgentCustom" --value $LOADROUND
aws cloudwatch put-metric-data --metric-name PMON_Available --dimensions Instance=i-DDDDDD  --namespace "CWAgentCustom" --value $FLAGVAR

