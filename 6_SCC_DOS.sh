#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub6_SCC_DOS.sh $JobName 
    

