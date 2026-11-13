#!/bin/bash

JobName=$(sed '1q;d' init)
bash Sub7_Band.sh $JobName
