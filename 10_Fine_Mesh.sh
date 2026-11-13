#!/bin/bash

JobName=$(sed '1q;d' init)
Mesh=('0.9990' '0.0001' '1.0010')
bash Sub10_Fine_Mesh.sh $JobName "${Mesh[@]}"
    
