#!/bin/bash
Z=#your domain name (Zone) goes here
DIR=#a temporary directory where the script can dump the JSON response from CloudFlare and the record ID files, make sure to not put a / at the end
TKN=#your CloudFlare API token. get one at https://www.cloudflare.com/my-account
NAME=#the host name you want DDNS service for
EMAIL=#your CloudFlare email address
TTL=1 #advanced, expiration in seconds for your DNS record. 1 is automatic, otherwise use something between 120 and 4,294,967,295
MODE=0 #advanced, 0 means do not use CloudFlare acceleration, 1 means do, set to 1 if you ONLY use this host to run a website

#scrape your current external IP
MYIP=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=0"`

#if a file exists containing the CloudFlare IP of the record you're working with
#read that file into $CFIP
#otherwise, get it with nslookup and write it to file
if [ -e $DIR/ip.$Z.$NAME ]; then
	CFIP=`/bin/cat $DIR/ip.$Z.$NAME | /usr/bin/tr -d '\n'`
else
	CFIP=`/usr/bin/nslookup $NAME.$Z | /bin/grep "Address:" | /bin/grep -v "#53" | /bin/awk '{print $2}' | /usr/bin/tr -d '\n'`
	echo $CFIP > $DIR/ip.$Z.$NAME
fi

#if my external IP equals my IP listed in CloudFlare, quit
if [ "$MYIP" == "$CFIP" ]; then
	exit

#if my CloudFlare IP was null, create a new record
#upload the returned JSON for the rec_id
#remove the temporary file containing the JSON data
#write the record ID and CloudFlare IP to file
elif [ -z "$CFIP" ]; then
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_new" -F "z=$Z" -F "type=A" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE" > $DIR/json.$Z.$NAME
	ID=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=2" -F "file=@$DIR/json.$Z.$NAME"`
	rm -f $DIR/json.$Z.$NAME
	echo $ID > $DIR/rec_id.$Z.$NAME
	echo $CFIP > $DIR/ip.$Z.$NAME

#if a file exists with my CloudFlare ID, read it into $ID
#update the CloudFlare record
#write the CloudFlare IP to file
elif [ -e $DIR/rec_id.$Z.$NAME ]; then
	ID=`/bin/cat $DIR/rec_id.$Z.$NAME | /usr/bin/tr -d '\n'`
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_edit" -F "z=$Z" -F "type=A" -F "id=$ID" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
	echo $MYIP > $DIR/ip.$Z.$NAME

#finally, get all records from CloudFlare
#upload the JSON file and desired hostname. put the resulting record id in $ID
#upload changes to CloudFlare
#remove JSON data from CloudFlare
#write CloudFlare record ID and listed IP to file
else
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_load_all" -F "z=$Z" > $DIR/json.$Z.$NAME
	ID=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=1" -F "file=@$DIR/out.tmp" -F "host=$NAME"`
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_edit" -F "z=$Z" -F "type=A" -F "id=$ID" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
	rm -f $DIR/json.$Z.$NAME
	echo $ID > $DIR/rec_id.$Z.$NAME
	echo $MYIP > $DIR/ip.$Z.$NAME
fi
