#!/bin/bash
l=$(cat r53records)
touch r1
state="stopped"
s=""
hz="Z1UFFBKG22RQQ8"
unset InsID
unset InsState
for i in $l
do 
	echo "record $i"	
	aws route53 list-resource-record-sets --hosted-zone-id $1 --query "ResourceRecordSets[?Name == '$i']" >> r1
	if [ `wc -l <r1` == 1 ]
	then 
		truncate -s 0 r1
		echo " Record NOTFOUND"
	else 	
		value=$(cat r1 | jq '.[] |"\(.ResourceRecords[])"' | tr -d '"{}\\\\'  | sed -e 's/\:/ /g' | awk '{print $2}')
		id=$(aws ec2 describe-instances --filters Name=dns-name,Values="$value" | jq '.[]|.[]|.Instances[]|"\(.InstanceId),\(.State.Name)"' | tr -d '"' |sed -e 's/,/ /g')
		if [ -z "$id" ];
		then 
		id=$(aws ec2 describe-instances --filters Name=private-dns-name,Values="$value" | jq '.[]|.[]|.Instances[]|"\(.InstanceId),\(.State.Name)"' | tr -d '"' |sed -e 's/,/ /g'
	);
		fi
		if [ ! -z "$id" ];
		then
			InsID=$(echo $id | awk '{print $1}');
			InsState=$(echo $id | awk '{print $2}');
		fi
		if [[ "$InsState" == "$state" ]] || [[ "$InsState" == "$s" ]]
		then
			bash delR53recbyDomain.sh $1 $i
			echo $i $value $InsID $InsState 
		else
			echo "cannot delete $i $value $InsID $InsState"
		fi
		truncate -s 0 r1
		unset InsID
		unset InsState
	fi
done
rm r1
