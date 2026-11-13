#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub6_BORN.sh $JobName
    

