#!/usr/bin/env fish

if ! test -n "$INVERTER_IP"
    echo 'The INVERTER_IP variable must be set'
    exit 1
end

if ! test -n "$DB_IP"
    echo 'The DB_IP variable must be set'
    exit 1
end

if ! test -n "$DB_PORT"
    echo 'The DB_PORT variable must be set'
    exit 1
end

while true
    set raw (
        curl --silent \
            --connect-timeout 5 \
            --max-time 5 \
            "http://$INVERTER_IP/home.cgi" \
        | tail -3 | head -1
    )

    if [ "$test" != "" ]
        # The raw data is in Kilowatt/hour.
        set produced (math "$raw * 1000")

        echo "inverter produced=$produced" | ncat --udp $DB_IP $DB_PORT
    else
        echo 'The inverter is offline'
    end

    sleep 1800
end
