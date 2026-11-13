#!/bin/bash

JobName=$(sed '1q;d' init)
Mesh=('0.990' '0.001' '1.010')
bash Sub5_Full_Relax2.sh $JobName "${Mesh[@]}"
    

