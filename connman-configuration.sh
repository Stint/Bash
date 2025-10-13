#!/usr/bin/env bash
# Author: Brent Shinn
# Configure network with connmanctl 

RED='\033[0;31m'
BLUE='\033[0;34m'
LBLUE='\033[0;36m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
PURPLE='\033[0:35m'
LGRAY='\033[0;37m'
DGRAY='\033[1;30m'
NC='\033[0m'

current_configuration () {
    clear 
    printf "${YELLOW}Configure k3os with connmanctl ${DGRAY}\n"
    echo "gathering information..."
    printf "${YELLOW} Current configuration: ${NC}\n"   
    echo
    CURRENT_CONFIG=$(connmanctl services | cut -d " " -f18)
    connmanctl services $CURRENT_CONFIG | grep "IPv4.Configuration"
    connmanctl services $CURRENT_CONFIG | grep "Nameservers "
    connmanctl services $CURRENT_CONFIG | grep "Timeservers "
    LOOK_FOR_DHCP=$(connmanctl services $CURRENT_CONFIG | grep "Method=dhcp")
    if echo $CURRENT_CONFIG | grep -q "Method=dhcp"; then 
    echo printf "${LGREEN} DHCP Enabled"
    echo

    printf "${YELLOW}Current connman configuration file: ${LGRAY} /var/lib/connman/default.config ${NC}\n"
    cat /var/lib/connman/default.config 
    echo 
    printf "${YELLOW}\n"
    read -p "Continue? [ Y/y or anything else to exit ]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Continuing network configuration..."
    else
            printf "${YELLOW}Exiting... ${NC}\n"
            exit 1
    fi
}

apply_configuration () {
    printf "${YELLOW}\n"
    read -p "Continue? [ Y/y or anything else to exit ]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Applying network configuration..."
            connmanctl config $CURRENT_CONFIG ipv4 manual $NEW_IPADDR $NEW_SUBNET $NEW_GATEWAY --nameservers $NEW_DNS --timeservers $NEW_NTP
            service connman restart 
    else
            printf "${YELLOW}Exiting... ${NC}\n"
            exit 1
    fi
}

new_configuration () {
echo 
printf "${YELLOW}Please enter the new networking configuration: ${NC}\n"
echo 
read -p "Enter new IP Address: " NEW_IPADDR
echo "New IP Address: $NEW_IPADDR"
echo
read -p "Enter new subnet: " NEW_SUBNET 
echo "New subnet: $NEW_SUBNET"
echo 
read -p "Enter new gateway: " NEW_GATEWAY
echo "New gateway: $NEW_GATEWAY"
echo 
read -p "Enter new DNS, seperate multiple entries with a comma and no spaces: " NEW_DNS
echo "New DNS: $NEW_DNS"
echo 
read -p "Enter new NTP: separate multiple entries with a comma and no spaces: " NEW_NTP
echo "New NTP: $NEW_NTP"
echo 

printf "${YELLOW} New IP Address:${LGREEN} $NEW_IPADDR ${NC}\n"
printf "${YELLOW} New Subnet:${LGREEN} $NEW_SUBNET ${NC}\n"
printf "${YELLOW} New Gateway:${LGREEN} $NEW_GATEWAY ${NC}\n"
printf "${YELLOW} New DNS:${LGREEN} $NEW_DNS ${NC}\n"
printf "${YELLOW} New NTP:${LGREEN} $NEW_NTP ${NC}\n"

printf "${YELLOW}Generating new config... ${NC}\n"

cat <<EOF > /var/lib/connman/default.config 
[service_eth]
Type = ethernet
IPv4 = off
IPv6 = off
DeviceName = eth0
IPv4 = "${NEW_IPADDR}/${NEW_SUBNET}/${NEW_GATEWAY}"
IPv6 = off
Nameservers = "${NEW_DNS}"
Timeservers = "${NEW_NTP}"
Domain = origin.dmn
SearchDomains = localhub.origin.dmn,origin.dmn
EOF

}

current_configuration
new_configuration
apply_configuration 

  
