#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub_Phonon1.sh $JobName
