#!/bin/bash

JobName=$(sed '1q;d' init)
Mesh=('0.90' '0.02' '1.10')
bash Sub2_Coarse_Mesh.sh $JobName "${Mesh[@]}"
    

