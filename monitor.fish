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

    if test "$raw" = ""
        echo 'The inverter is offline'
    else if test $raw -eq 0
        # Every now and then the inverter will randomly report the value to be
        # zero in the middle of the day. Such values mess up with any
        # dashboards, so we ignore them. It's also just a waste to log zero
        # values.
        echo 'The reported usage is zero, ignoring'
    else
        # The raw data is in Kilowatt/hour.
        set produced (math "$raw * 1000")

        echo "inverter produced=$produced" | ncat --udp $DB_IP $DB_PORT
        echo "$produced Watts (raw: $raw kW)"
    end

    sleep 1800
end
