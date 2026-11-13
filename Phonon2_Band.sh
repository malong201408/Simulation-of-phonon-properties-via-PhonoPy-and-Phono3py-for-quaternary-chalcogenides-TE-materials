#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub_Phonon2_Band.sh $JobName
