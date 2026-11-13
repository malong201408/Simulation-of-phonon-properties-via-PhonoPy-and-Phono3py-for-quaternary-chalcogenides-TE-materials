#!/bin/bash

JobName=$(sed '1q;d' init)
FC2_Mesh=$(sed '5q;d' init)
FC3_Mesh=$(sed '6q;d' init)

cp Sub_Phono3py1.sh Sub_Phono3py1_temp.sh

sed -i "s/FC2_Replace/$FC2_Mesh/g" Sub_Phono3py1_temp.sh
sed -i "s/FC3_Replace/$FC3_Mesh/g" Sub_Phono3py1_temp.sh


bash Sub_Phono3py1_temp.sh $JobName
