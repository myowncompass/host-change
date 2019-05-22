#!/bin/bash
#Set some defaults for coloring text.
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[1;30m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

cfgdir=/usr/local/nagios/etc/Default_collector
echo "_________________________________________________________________________________________________ "
echo " "
echo -e "${WHITE}Welcome to the Nagios host change shell script.${NC}"
echo -e "${YELLOW}Remember to run this script as root (> sudo hostchange) or very little will happen.${NC}"

read -r -p "Do you wish to modify a Nagios host entry? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    echo " "
    read -r -p "What site needs modifications? [PNUM] " PNUM
    
    # We read the hosts associated with the given PNUM to an array. This allows a "choose by number" menu system.
    declare -a hostarray
    hw_quant=`ls $cfgdir/hosts*/$PNUM* | wc|awk '{print $1}'`
	if [ "$hw_quant" -gt 0 ]
	then
    		echo " "
    		echo -e "${WHITE}I've found the following hardware associated with $PNUM. Which would you like to modify?${NC}"
    		ls -1 $cfgdir/hosts*/$PNUM* | xargs -n 1 basename | sed -e "s/.cfg//" > xxx
    		readarray hostarray < xxx; rm xxx
    		ls -1 $cfgdir/hosts*/$PNUM* | xargs -n 1 basename | sed -e "s/.cfg//" | awk '{print NR ") " $1}'
	else
		echo -e "${RED}There are no hosts associated with $PNUM. Restarting script...${NC}"
		./$(basename $0) && exit
	fi
else
    echo -e "${RED}Exiting script...${NC}"
    exit
fi

read -r -p "Enter the number of the host or press [ENTER] to restart the script.
> " response
    if [ "$response" -gt $hw_quant ]
    then
	echo -e "${RED}That's not a valid response. Restarting script...${NC}"
        ./$(basename $0) && exit
    elif [ "$response" = 1 ]
    then
        host=${hostarray[0]}
    elif [ "$response" = 2 ]
    then
        host=${hostarray[1]}
    elif [ "$response" = 3 ]
    then
        host=${hostarray[2]}
    elif [ "$response" = 4 ]
    then
        host=${hostarray[3]}
    elif [ "$response" = 5 ]
    then
        host=${hostarray[4]}
    elif [ "$response" = 6 ]
    then
        host=${hostarray[5]}
    elif [ "$response" = 7 ]
    then
        host=${hostarray[6]}
    elif [ "$response" = 8 ]
    then
        host=${hostarray[7]}
    elif [ "$response" = 9 ]
    then
        host=${hostarray[8]}
    else 
	echo -e "${RED}That's not a valid response. Restarting script...${NC}"
	./$(basename $0) && exit
fi

# Turns the array variable into a string so as not to confuse our text editors.
host=`echo $host`

# Display the current entry
echo " "
echo -e "${WHITE}Here is the current host entry for ${YELLOW}$host${NC}"
cat $cfgdir/hosts*/$host.cfg

read -r -p "Would you like to modify this host? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
	hostpath=`ls $cfgdir/hosts*/$host.cfg` #Full path to cfg file
	hostdir=`dirname $hostpath` #Directory containing the cfg file
	cat $cfgdir/hosts*/$host.cfg > xxx #writes the host file in the current directory for modification
	# Here we create variables for the entries we might wish to modify
        address=`cat xxx | grep address | awk '{print $2}'`
        template=`cat xxx | sed -n 's/use//p' | sed -e 's/^[[:space:]]*//'`
        hostgroups=`cat xxx | sed -n 's/hostgroups//p' | sed -e 's/^[[:space:]]*//'`
    else
	echo -e "${RED}Sounds like that's not what you were looking for. Restarting script...${NC}"
        ./$(basename $0) && exit
fi

#Set a variable for the network group to construct our best guess hostgroups below.
network=`echo $hostgroups | awk -F "," '{print $3}'`

# Get the new hostname, if/then statements allow us to default to the current value
echo " "
echo -e "Convention: ${YELLOW}PNUM_[CX/DX]_[HARDWARE-CODE](_RADIO-ID)${NC}"
read -r -p "[1/4] What is the new hostname? [$host]
> " response
    if [ "$response" == "" ]
    then
        host_new=$host
	echo -e "Keeping old host name: $host_new"
    else
        host_new=$response
	echo -e "Using new host name: $host_new"
    fi

# Get the new address, if/then statements allow us to default to the current value
echo " "
echo -e "Convention: ${YELLOW}Receivers use FQDN, other hardware uses the IP address.${NC}"
read -r -p "[2/4] What is the new address? [$address]
> " response
    if [ "$response" == "" ]
    then
        address_new=$address
	echo -e "Keeping old address: $address_new"
    else
        address_new=$response
	echo -e "Using new address: $address_new"
    fi

# Get the new template, if/then statements allow us to default to the current value, array allows numerical selection
# Create a template array
template_array=("RV50 Modems" "LS300 Modems" "Rx_NetRS" "Rx_NetR9" "Rx_PolaRx5" "Ubiquiti Radios" "EB1 Radios" "EB3+ Radios" "EB6+ Radios" "VSAT_IDU" "LC2 Modems" "LC3 Modems" "ToughSwitch")
echo " "
echo -e "${WHITE}Which template should we use for this host?${NC}"
for index in ${!template_array[*]}
do
    printf "%4d: %s\n" $index "${template_array[$index]}"
done

read -r -p "[3/4] Select an index number or hit [ENTER] to use current value. [$template]
> " response

    if [ "$response" == "" ]
    then
        template_new=$template
    elif [ "$response" = 0 ]
    then
        template_new=${template_array[0]}
    elif [ "$response" = 1 ]
    then
        template_new=${template_array[1]}
    elif [ "$response" = 2 ]
    then
        template_new=${template_array[2]}
    elif [ "$response" = 3 ]
    then
        template_new=${template_array[3]}
    elif [ "$response" = 4 ]
    then
        template_new=${template_array[4]}
    elif [ "$response" = 5 ]
    then
        template_new=${template_array[5]}
    elif [ "$response" = 6 ]
    then
        template_new=${template_array[6]}
    elif [ "$response" = 7 ]
    then
        template_new=${template_array[7]}
    elif [ "$response" = 8 ]
    then
        template_new=${template_array[8]}
    elif [ "$response" = 9 ]
    then
        template_new=${template_array[9]}
    elif [ "$response" = 10 ]
    then
        template_new=${template_array[10]}
    elif [ "$response" = 11 ]
    then
        template_new=${template_array[11]}
    elif [ "$response" = 12 ]
    then
        template_new=${template_array[12]}
    elif [ "$response" = 13 ]
    then
        template_new=${template_array[13]}
    else
        exit 1
fi
echo "Using template: $template_new"

# Get the new hostgroups. Might modify this to choose multiple from menus but for now, manual entry
# Best guess = PNUM,template_new,[Radio Network]
if [ -z "$network" ]
then
      bestguess=$PNUM,$template_new
else
      bestguess=$PNUM,$template_new,$network
fi

echo " "
echo -e "${WHITE}Host Groups${NC}"
echo " "
echo -e "Convention: ${YELLOW}[PNUM],[Hardware Group],[Radio Network],[Other Groups]${NC}"
echo -e "Groups must be entered as defined in your region's hostgroups configuration file (typically hostgroups_[region].cfg)"
#echo " "
#echo -e "Options: RV50 Modems,LS300 Modems,Rx_NetRS,Rx_NetR9,Rx_PolaRx5,Ubiquiti Radios,EB1 Radios,EB3+ Radios,EB6+ Radios,VSAT_IDU,LC2 Modems,LC3 Modems,ToughSwitch"
echo -e "Enter new hostgroups separated only by a comma (no space)."
echo " "
echo -e "Current: ${YELLOW}$hostgroups${NC}"
echo -e "Best Guess: ${GREEN}$bestguess${NC}"
echo " "
read -r -p "
[4/4] What hostgroups should this hardware be associated with? [$bestguess]
> " response
    if [ "$response" == "" ]
    then
        hostgroups_new=$bestguess
	echo "Using the following groups: $hostgroups_new"
    else
        hostgroups_new=$response
	echo "Using the following groups: $hostgroups_new"
    fi

# Copy our local entry to a new file and make all substitutions, then display new entry
cp xxx yyy
sed -i -- "s/$host/$host_new/g" yyy
sed -i -- "s/$address/$address_new/g" yyy
sed -i -- "s/$template/$template_new/g" yyy
sed -i -- "s/$hostgroups/$hostgroups_new/g" yyy

echo " "
echo -e "${WHITE}Here is the modified host entry.${NC}"
cat yyy

echo -e "${YELLOW}CAUTION: 'Y'/'Yes' modifies the live files.${NC}"
echo -e "${YELLOW}Any other input restarts the script.${NC}"
read -r -p "Are these new settings correct? [y/N] 
> " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
        then
            dt=`date +"%Y-%m-%d_%H%M"`
            echo " "
            echo -e "${GRAY}Moving $host.cfg to old/$host.cfg.$dt...${NC}"
            mv $hostdir/$host.cfg $hostdir/old/$host.cfg.$dt
            echo " "
            echo -e "${GRAY}Replacing the old host entry with our new version...${NC}"
	    cp yyy $hostdir/$host_new.cfg 
            echo " "
	    echo -e "${GRAY}Finding/replacing $host with $host_new across all regional host files to update parent/child relationships...${NC}"
	    find $hostdir -maxdepth 1 -type f -exec sed -i "s/$host/$host_new/g" {} \;
            echo " "
            echo -e "${GRAY}Running the Nagios check script to make sure we didn't break anything.${NC}"
            echo -e "${GRAY}If an error is encountered here, it will need to be fixed manually.${NC}"
            echo -e "${GRAY}If you are unsure of how to do that, copy and paste this session into an email to an admin.${NC}"
            /etc/rc.d/init.d/nagios checkconfig /etc/httpd/conf.d/nagios.conf
	    echo " "
            echo -e "${GRAY}Done. Check for errors above and when you're finished making changes, ${YELLOW}don't forget to restart Nagios.${NC}"
    else
	echo -e "${RED}No modifications made. Restarting script...${NC}"
        ./$(basename $0) && exit
fi

rm xxx yyy

# Restart script from the beginning
./$(basename $0) && exit
