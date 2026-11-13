#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub_Phonon4_Gruneissen.sh $JobName
