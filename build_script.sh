#!/usr/bin/env bash
source /usr/local/rvm/environments/ruby-1.9.3-p448
cd production.live
middleman build
now=$(date +"%I:%M:%S")
echo -n "script run at $now" > itworked.log