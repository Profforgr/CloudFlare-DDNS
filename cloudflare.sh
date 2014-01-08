#!/bin/bash
Z=mattfreitag.com
DIR=/temp
TKN=663e5650909fb6d404e8ec31ef113b015fa53
NAME=thh
EMAIL=matt@mattfreitag.com
TTL=1
MODE=0

MYIP=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=0"`
CFIP=`/usr/bin/nslookup $NAME.$Z | /bin/grep "Address:" | /bin/grep -v "#53" | /bin/awk '{print $2}' | /usr/bin/tr -d '\n'`

if [ -z "$CFIP" ]; then
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_new" -F "z=$Z" -F "type=A" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
fi

if [ "$MYIP" == "$CFIP" ]; then
	exit
else
	/usr/bin/curl -s https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_load_all" -F "z=$Z" > $DIR/out.tmp
	ID=`/usr/bin/curl -s http://www.mattfreitag.com/ip/ -F "option=1" -F "file=@$DIR/out.tmp" -F "host=$NAME"`
	rm -f $DIR/out.tmp
	/usr/bin/curl -S https://www.cloudflare.com/api_json.html -F "tkn=$TKN" -F "email=$EMAIL" -F "a=rec_edit" -F "z=$Z" -F "type=A" -F "id=$ID" -F "name=$NAME" -F "content=$MYIP" -F "ttl=$TTL" -F "service_mode=$MODE"
fi
