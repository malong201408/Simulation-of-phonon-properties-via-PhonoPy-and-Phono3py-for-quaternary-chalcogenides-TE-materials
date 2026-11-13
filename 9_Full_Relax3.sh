#!/bin/bash

JobName=$(sed '1q;d' init)
Mesh=('0.9980' '0.0002' '1.0020')
bash Sub9_Full_Relax3.sh $JobName "${Mesh[@]}"
