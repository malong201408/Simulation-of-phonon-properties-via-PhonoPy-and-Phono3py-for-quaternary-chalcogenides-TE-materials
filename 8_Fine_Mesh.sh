#!/bin/bash

JobName=$(sed '1q;d' init)
Mesh=('0.9980' '0.0002' '1.0020')
bash Sub8_Fine_Mesh.sh $JobName "${Mesh[@]}"
    
