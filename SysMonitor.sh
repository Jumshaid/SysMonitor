#!/bin/bash

# Date: August 24, 2014
#
#
# This script assumes that you will run it in crontab
# crontab is linux task scheduler which will run scripts at their specified time
# if you put the following command in crontab -e the script will run every 5 mins
# * * * * * [the script file path]
#
#
# This script will send an email alert to cse mailing list when the system
# usage reaches 90% warn and 95% critical. The email will contain how many 
# percent are free of disk, memory, cpu etc.
#
#
# WARNING and CRITICAL global variable
WARNING=90 # 90%
CRITICAL=95 # 95%

# We will write the required information to a file first and then read from it
# when we're about to send an email
#
# SUBJECT of the email
SUBJECT1="WARNING: CPU USAGE HIGH"
SUBJECT2="CRITICAL: CPU USAGE HIGH"

# 'TO' email
TO="cselabs-team-group@nyu.edu"

# Temporary file for message to be stored and then will be read from it
MESSAGE="/tmp/message.txt"
#
# CPU USAGE USING 'TOP'
#
#
#
# We use 'top' for this purpose
# We utilize two options in 'top' -b and -n; -b is for bash mode and -n is for
# specifying the number of iterations
# Again we pass this information to awk and obtain the required values

# Obtaining the required information from 'top' command output
cpuInfo=$(top -b -n 1 | grep "%Cpu" | awk '{print $2+$4}')

# Converting it to integer value
cpuInfoInt=${cpuInfo/.*}

echo "PAY ATTENTION!!!" >> $MESSAGE
echo "The cpu usage is "$cpuInfoInt"%" >> $MESSAGE

#
#
# SYSTEM DISK USAGE AND CHECK USING df
#
# Using the df -h command to obtain the system disk space usage
# We are only concerned with 'Filesystem' beginning with '/dev/*'
# We filter the results by using the REGEXP in awk and printing the 
# important columns
# Note that we used the backslash before forward slash to escape it 
# because it is a special character

df -h | awk '/^\/dev\/sda[0123456789]/ {

        print "Percent disk space used for "$1" is "$5
 
}' >> $MESSAGE
#
# MEMORY USAGE 
#
# we'll use 'free -h' command and to send the output to awk and manipulate it

free -h | grep "Mem:" | awk '{
        
        print "Memory used: "($3/$2)*100"\nMemory free: "($4/$2)*100

}' >> $MESSAGE
#
#
#
#               
# If the usage is greater than 90% send a warning email to the
# group and if it is gretaer than 95% send a critical email to
# to the cselabsTeam group along with system usage and memory
# usage

if [ "$cpuInfoInt" -ge "$WARNING" ]; then
        # Send a warning email
        # Configure the 'sendmail' mail transfer agent so that it send an email
        # If it's in 'warning' state then we'll send an email with system
        # and memory usages

        mail -s "$SUBJECT1" "$TO" < $MESSAGE

elif [ $cpuInfoInt -ge $CRITICAL ]; then

        mail -s "$SUBJECT2" "$TO" < $MESSAGE

fi

# Deleting the file after it is run once so there are no previous data in it
rm $MESSAGE
