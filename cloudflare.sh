#!/bin/bash
Z=#your domain name goes here
DIR=#a temporary directory where the script can dump the JSON response from CloudFlare
TKN=#your CloudFlare API token. get one at https://www.cloudflare.com/my-account
NAME=#the host name you want DDNS service for
EMAIL=#your CloudFlare email address
TTL=1 #advanced, expiration in seconds for your DNS record. 1 is automatic, otherwise use something between 120 and 4,294,967,295
MODE=0 #advanced, 0 means do not use CloudFlare acceleration, 1 means do, only set to 1 if you ONLY use this host to run a website

#scrape current external IP from mattfreitag.com
MYIP=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=0"`

#use nslookup to get current IP listed on CloudFlare
CFIP=`/usr/bin/nslookup $NAME.$Z | /bin/grep "Address:" | /bin/grep -v "#53" | /bin/awk '{print $2}' | /usr/bin/tr -d '\n'`

#if the nslookup returns null, CloudFlare record doesn't exist. create one.
if [ -z "$CFIP" ]; then
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_new" -F "z=$Z" -F "type=A" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
fi

#if my external IP equals my CloudFlare IP...
if [ "$MYIP" == "$CFIP" ]; then
	#nothing to do. quit.
	exit
#if they're not equal...
else
	#get all of my CloudFlare records and dump the results to out.tmp in the temp directory set above
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_load_all" -F "z=$Z" > $DIR/out.tmp
	#upload the JSON to mattfreitag.com, as well as my desired host name to get the record ID. put the result in the $ID variable
	ID=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=1" -F "file=@$DIR/out.tmp" -F "host=$NAME"`
	#delete the JSON response since we got what we want
	rm -f $DIR/out.tmp
	#update the record on CloudFlare
	/usr/bin/curl -S https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_edit" -F "z=$Z" -F "type=A" -F "id=$ID" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
fi
