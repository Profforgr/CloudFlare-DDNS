#!/bin/bash
Z=#your domain name goes here
DIR=#a temporary directory where the script can dump the JSON response from CloudFlare and the record ID files, make sure to not put a / at the end
TKN=#your CloudFlare API token. get one at https://www.cloudflare.com/my-account
NAME=#the host name you want DDNS service for
EMAIL=#your CloudFlare email address
TTL=1 #advanced, expiration in seconds for your DNS record. 1 is automatic, otherwise use something between 120 and 4,294,967,295
MODE=0 #advanced, 0 means do not use CloudFlare acceleration, 1 means do, only set to 1 if you ONLY use this host to run a website

MYIP=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=0"`
CFIP=`/usr/bin/nslookup $NAME.$Z | /bin/grep "Address:" | /bin/grep -v "#53" | /bin/awk '{print $2}' | /usr/bin/tr -d '\n'`

if [ -z "$CFIP" ]; then
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_new" -F "z=$Z" -F "type=A" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE" > $DIR/out.tmp
	ID=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=2" -F "file=@$DIR/out.tmp"`
	rm -f $DIR/out.tmp
	echo $ID > $DIR/$NAME.rec_id

elif [ "$MYIP" == "$CFIP" ]; then
	exit

elif [ -e $DIR/$NAME.rec_id ]; then
	ID=`/bin/cat $DIR/$NAME.rec_id | /usr/bin/tr -d '\n'`
	/usr/bin/curl -S https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_edit" -F "z=$Z" -F "type=A" -F "id=$ID" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"

else
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_load_all" -F "z=$Z" > $DIR/out.tmp
	ID=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=1" -F "file=@$DIR/out.tmp" -F "host=$NAME"`
	rm -f $DIR/out.tmp
	echo $ID > $DIR/$NAME.rec_id
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_edit" -F "z=$Z" -F "type=A" -F "id=$ID" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
fi
