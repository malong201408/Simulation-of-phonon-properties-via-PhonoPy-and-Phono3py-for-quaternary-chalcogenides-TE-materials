#!/bin/bash

JobName=$(sed '1q;d' init)
FC2_Mesh=$(sed '5q;d' init)

cp Sub_PhononSOC1.sh Sub_PhononSOC1_temp.sh

sed -i "s/FC2_Replace/$FC2_Mesh/g" Sub_PhononSOC1_temp.sh

bash Sub_PhononSOC1_temp.sh $JobName
rm Sub_PhononSOC1_temp.sh
