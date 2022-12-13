 #!/bin/bash
USEDMEMORY=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')

LISTENER_PORT=1521

TCP_CONN=$(netstat -na | awk '$4 ~ /:'${LISTENER_PORT}'/ {print $0}' | wc -l)

DataVolume=`df -kP|grep rdsdbdata|awk '{print $4/1048576}'|paste -sd+|bc`
BinVolume=`df -kP|grep rdsdbbin|awk '{print $4/1048576}'|paste -sd+|bc`
RootVolume=`df -kP|grep -w "/"|grep dev  |awk '{print $4/1048576}'|paste -sd+|bc`
LOADAVG=`uptime | awk -F'[, ]*' '{print $11}'`
LOADROUND=`echo "${LOADAVG}" | awk '{printf("%d\n",$1 + 0.5)}'`
FLAGVAR=0
if ps -ef|grep ora_pmon_*|grep -v grep ; then
FLAGVAR=1
fi

aws cloudwatch put-metric-data --metric-name memory-usage --dimensions Instance=i-0ea2648c36a7c0574  --namespace "custom19cname" --value $USEDMEMORY
aws cloudwatch put-metric-data --metric-name TCP_connection --dimensions Instance=i-0ea2648c36a7c0574  --namespace "custom19cname" --value $TCP_CONN
aws cloudwatch put-metric-data --metric-name Data_FreeSpace_GB --dimensions Instance=i-0ea2648c36a7c0574  --namespace "custom19cname" --value $DataVolume
aws cloudwatch put-metric-data --metric-name Bin_FreeSpace_GB --dimensions Instance=i-0ea2648c36a7c0574 --namespace "custom19cname" --value $BinVolume
aws cloudwatch put-metric-data --metric-name Root_FreeSpace_GB --dimensions Instance=i-0ea2648c36a7c0574  --namespace "custom19cname" --value $RootVolume
aws cloudwatch put-metric-data --metric-name Load_Average --dimensions Instance=i-0ea2648c36a7c0574  --namespace "custom19cname" --value $LOADROUND
aws cloudwatch put-metric-data --metric-name PMON_Available --dimensions Instance=i-0ea2648c36a7c0574  --namespace "custom19cname" --value $FLAGVAR