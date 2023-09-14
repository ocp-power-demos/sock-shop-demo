#!/usr/bin/env bash

# mongo mongodb://user-db:27017 <file> after update

for FILE in $(find /docker-entrypoint-initdb.d/ -type f -iname '*.js')
do
printf '%s' "db = db.getSiblingDB('users');
" | cat - ${FILE} > tmpfile && mv -f tmpfile ${FILE}
done
