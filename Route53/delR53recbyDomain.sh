#!/bin/bash
#syntax "bash filename.sh hostedzone subdomain.domain.com."
#make sure  2nd arg ends with dot
clear
touch t1
touch t2
truncate -s 0 t1
truncate -s 0 t2
echo '{"ref": '>>t1; aws route53 list-resource-record-sets --hosted-zone-id $1 --query "ResourceRecordSets[?Name == '$2']" >>t1;echo '}'>>t1;
echo '{ "Comment": "Delete single record set", "Changes": [ { "Action": "DELETE", "ResourceRecordSet":'>>t2;cat t1 | jq '.[] |.[]'>>t2;echo '}]}'>>t2;
echo "Deleting DNS Record set"
aws route53 change-resource-record-sets --hosted-zone-id $1 --change-batch file://t2
echo "OPERATION COMPLETED for $2"

