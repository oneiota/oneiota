#!/bin/bash
cd production.live
middleman build
now=$(date +"%I:%M:%S")
echo -n "script run at $now" > itworked.log