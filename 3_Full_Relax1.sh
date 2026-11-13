#!/bin/bash

JobName=$(sed '1q;d' init)
Mesh=('0.90' '0.02' '1.10')
bash Sub3_Full_Relax1.sh $JobName "${Mesh[@]}"
    

