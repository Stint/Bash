#!/usr/bin/env bash
# Brent Shinn

## Define Colors for Text

RED='\033[0;31m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
PURPLE='\033[0:35m'
NC='\033[0m'

function function1
{
	echo ## define
}

function function2
{
	echo ## define
}

function function3
{
	echo ## define	
}

function function4
{
	echo ## define
}

function function5
{
	echo ## define
}

function press_enter
{
        clear
	printf "${RED} \n"
        echo -n "Press Enter to continue"
        read
}

while [ answer != "0" ]  
do
clear
printf "${RED} BASH Menu System \n" 
printf "${NC}  TEMPLATE Menu \n"
echo
printf "${RED}  Select an option:\n" 
printf "${NC}   >>  0 ${RED} Exit \n" 
printf "${NC}   >>  1 ${RED} TEXT \n" 
printf "${NC}   >>  2 ${RED} TEXT \n" 
printf "${NC}   >>  3 ${RED} TEXT \n"
printf "${NC}   >>  4 ${RED} TEXT \n"
printf "${NC}   >>  5 ${RED} TEXT ${NC}\n" 
echo
read -p "   Selection:  " answer 
    case $answer in 
        0) break ;; 
        1) function1
        ;; 
        2) function2
        ;; 
        3) function3
        ;; 
		4) function4
        ;;
		5) function5
		;;
		*) ;; 
    esac  
done 
exit 0
