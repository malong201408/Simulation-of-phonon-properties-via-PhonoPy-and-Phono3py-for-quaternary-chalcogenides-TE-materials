#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub_Phonon6_SOCBand.sh $JobName
