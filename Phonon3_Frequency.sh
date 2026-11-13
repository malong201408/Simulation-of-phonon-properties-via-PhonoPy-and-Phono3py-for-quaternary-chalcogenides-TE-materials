#!/bin/bash

JobName=$(sed '1q;d' init)

input="./$JobName/Phonon/Phonon_Sep/band.yaml"

count=0

while IFS= read -r line
do
    Fre=$(echo "$line" | awk '{print $1;}')
    
    if [ $Fre == "frequency:" ];then

	count=$((count+1))
	THz=$(echo "$line" | awk '{print $2;}')
	cm=`echo "$THz*33.35641" | bc`
	echo "$count" ":" "$THz" " THz = " "$cm" " cm^-1"
	echo "$count" ":" "$THz" " THz = " "$cm" " cm^-1" >> "$JobName"_Phonon.dat
    fi
    
    if [ -z "$line" ];then
	break
    fi
done < "$input"
