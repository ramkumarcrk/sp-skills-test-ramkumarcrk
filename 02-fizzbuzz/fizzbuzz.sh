#!/bin/bash

consul_server_url="$1"

if [ -z "$consul_server_url" ]; then
    echo "Consul server URL not provided. Usage: ./fizzbuzz.sh <consul_server_url>"
    exit 1
fi

for ((i=1; i<=200; i++)); do
    if ((i % 3 == 0)) && ((i % 5 == 0)); then
        value="FizzBuzz"
    elif ((i % 3 == 0)); then
        value="Fizz"
    elif ((i % 5 == 0)); then
        value="Buzz"
    else
        value=$i
    fi

    curl -X PUT -H "Content-Type: application/json" -d "{\"value\": \"$value\"}" "$consul_server_url/$i"
done
