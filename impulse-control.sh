#!/bin/bash

SYST_STATE=$1
ARG2=$2

cd /opt/impulse
NIDS_ENABLED=$(awk -F "=" '/NIDS_ENABLED/ {print $2}' impulse.conf | tr -d ' ')
AGENT_TYPE=$(awk -F "=" '/AGENT_TYPE/ {print $2}' impulse.conf | tr -d ' ')


if [[ $SYST_STATE == 'stop' ]]
then
	echo "Stop and deactivate Impulse..."
	#docker-compose down
	
	systemctl stop impulse-manager impulse-nids impulse-auxiliary osqueryd # impulse-main impulse-bgtasks
	systemctl disable osqueryd impulse-manager impulse-nids impulse-auxiliary # impulse-main impulse-bgtasks

	# check if nids caps enabled and only then start the impulse-nids service
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl stop impulse-nids
		systemctl disable impulse-nids
	else 
		echo "NIDS capabilities are disabled."
	fi

elif [[ $SYST_STATE == 'start' ]]
then
	echo "Start and enable Impulse..."
	systemctl start impulse-manager impulse-auxiliary osqueryd # impulse-main impulse-bgtasks
	systemctl enable osqueryd impulse-manager impulse-nids impulse-auxiliary # impulse-main impulse-bgtasks

	# check if nids caps enabled and only then start the impulse-nids service
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl start impulse-nids
		systemctl enable impulse-nids
	else 
		echo "NIDS caps are disabled."
	fi

elif [[ $SYST_STATE == 'restart' ]]
then
	echo "Restarting Impulse, please wait..."
	systemctl stop impulse-manager impulse-auxiliary osqueryd # impulse-main impulse-bgtasks
	systemctl disable osqueryd impulse-manager impulse-auxiliary # impulse-main impulse-bgtasks
	
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl stop impulse-nids
		systemctl disable impulse-nids
	else 
		echo "NIDS caps are disabled."
	fi

	sleep 1
	
	systemctl start impulse-manager impulse-auxiliary osqueryd # vimpulse-main impulse-bgtasks
	systemctl enable osqueryd impulse-manager impulse-auxiliary # impulse-main impulse-bgtasks
	
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl start impulse-nids
		systemctl enable impulse-nids
	else 
		echo "NIDS caps are disabled."
	fi

elif [[ $SYST_STATE == 'status' && -z "$2" ]]
then
	printf "\n\nImpulse X SIEM status check..."
	printf "\n\n "
	printf "Components "
	printf "\n\n "
	# printf "impulse-main: "$(systemctl is-active impulse-main)
	# printf "\n\n "
	printf "impulse-manager: "$(systemctl is-active impulse-manager)
	printf "\n\n "
	printf "impulse-nids: "$(systemctl is-active impulse-nids)
	printf "\n\n "	
	# printf "impulse-bgtasks: "$(systemctl is-active impulse-bgtasks)
	# printf "\n\n "
	printf "impulse-auxiliary: "$(systemctl is-active impulse-auxiliary)
	printf "\n\n "	
	printf "osqueryd: "$(systemctl is-active osqueryd)
	printf "\n\n "
	printf "Manager Services \n\n"
	docker ps -a 

elif [[ $SYST_STATE == 'status' && $ARG2 == 'verbose' ]]
then
	printf "\n\n Impulse X SIEM status check..."
	printf "\n\n "
	printf "Components "
	printf "\n\n "
	# printf "impulse-main: "$(systemctl is-active impulse-main)
	# printf "\n\n "
	printf "impulse-manager: "$(systemctl is-active impulse-manager)
	printf "\n\n "
	printf "impulse-nids: "$(systemctl is-active impulse-nids)
	printf "\n\n "	
	# printf "impulse-bgtasks: "$(systemctl is-active impulse-bgtasks)
	# printf "\n\n "
	printf "impulse-auxiliary: "$(systemctl is-active impulse-auxiliary)
	printf "\n\n "		
	printf "osqueryd: "$(systemctl is-active osqueryd)
	printf "\n\n "
	printf "Manager Services \n\n"
	
	
	printf "Logs: \n\n" 
	/usr/local/bin/docker-compose logs
	printf "\n\n "
	docker ps -a 
	systemctl status impulse-manager osqueryd # impulse-main impulse-bgtasks

else
    printf 'Unknown command. Please enter "start", "stop" or "status" to activate, deactivate or view Impulse system status.'
fi

