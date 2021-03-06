get_next_cron_string() {
    # Parsing config
    curr_str=$(grep "JOB=" $V_USERS/$user/crontab.conf|cut -f 2 -d \'|\
             sort -n|tail -n1)

    # Print result
    echo "$((curr_str +1))"
}

is_cron_job_free() {
    # Checking record id
    check_job=$(grep "JOB='$job'" $V_USERS/$user/crontab.conf)

    if [ ! -z "$check_job" ]; then
        echo "Error: job exist"
        log_event 'debug' "$E_JOB_EXIST $V_EVENT"
        exit $E_JOB_EXIST
    fi
}

sort_cron_jobs() {
    # Defining conf
    conf="$V_USERS/$user/crontab.conf"
    cat $conf |sort -n -k 2 -t \' >$conf.tmp
    mv -f $conf.tmp $conf
}

sync_cron_jobs() {
    conf="/var/spool/cron/$user"

    # Deleting old data
    rm -f $conf

    # Checking reporting system
    rep=$(grep 'REPORTS=' $V_USERS/$user/user.conf | cut -f 2 -d \')
    if [ "$rep" = 'yes' ]; then
        email=$(grep 'CONTACT=' $V_USERS/$user/user.conf | cut -f 2 -d \')
        echo "MAILTO=$email" >$conf
    fi

    # Reading user crontab.conf
    while read line ; do
        # Defining new delimeter
        IFS=$'\n'

        # Parsing key=value
        for key in $(echo $line|sed -e "s/' /'\n/g"); do
            eval ${key%%=*}="${key#*=}"
        done

        if [ "$SUSPEND" = 'no' ] ; then
            # Adding line to system cron
            echo "$MIN $HOUR $DAY $MONTH $WDAY $CMD" |\
            sed -e "s/%quote%/'/g" -e "s/%dots%/:/g" >> $conf
        fi
    done <$V_USERS/$user/crontab.conf
}


is_job_valid() {
    result=$(grep "JOB='$job'" $V_USERS/$user/crontab.conf)

    if [ -z "$result" ]; then
        echo "Error: job not exists"
        log_event 'debug' "$E_JOB_NOTEXIST $V_EVENT"
        exit $E_JOB_NOTEXIST
    fi
}

del_cron_job() {
    str=$(grep -n "JOB='$job'" $V_USERS/$user/crontab.conf|cut -f 1 -d :)
    sed -i "$str d" $V_USERS/$user/crontab.conf
}

crn_json_list() {
    i='1'                       # iterator
    end=$(($limit + $offset))   # last string

    # Print top bracket
    echo '{'

    # Reading file line by line
    while read line ; do
        # Checking offset and limit
        if [ "$i" -ge "$offset" ] && [ "$i" -lt "$end" ] && [ "$offset" -gt 0 ]
        then
            # Defining new delimeter
            IFS=$'\n'
            # Parsing key=value
            for key in $(echo $line|sed -e "s/' /'\n/g"); do
                eval ${key%%=*}="${key#*=}"
            done

            # Checking !first line to print bracket
            if [ "$i" -ne "$offset" ]; then
                echo -e "\t},"
            fi

            j=1                 # local loop iterator
            last_word=$(echo "$fields" | wc -w)

            # Restoring old delimeter
            IFS=' '
            # Print data
            for field in $fields; do
                eval value=\"$field\"
                value=$(echo "$value"|sed -e 's/"/\\"/g' -e "s/%quote%/'/g")

                # Checking parrent key
                if [ "$j" -eq 1 ]; then
                    echo -e "\t\"$value\": {"
                else
                    if [ "$j" -eq "$last_word" ]; then
                        echo -e "\t\t\"${field//$/}\": \"${value//,/, }\""
                    else
                        echo -e "\t\t\"${field//$/}\": \"${value//,/, }\","
                    fi
                fi
                j=$(($j + 1))
            done
        fi
        i=$(($i + 1))
    done < $conf

    # If there was any output
    if [ -n "$value" ]; then
        echo -e "\t}"
    fi

    # Printing bottom json bracket
    echo -e "}"
}

crn_shell_list() {
    i='1'                       # iterator
    end=$(($limit + $offset))   # last string

    # Print brief info
    echo "${fields//$/}"
    for a in $(echo ${fields//\~/ /}); do
        echo -e "-----~\c"
    done
    echo


    # Reading file line by line
    while read line ; do
        # Checking offset and limit
        if [ "$i" -ge "$offset" ] && [ "$i" -lt "$end" ] && [ "$offset" -gt 0 ]
        then
            # Defining new delimeter
            IFS=$'\n'
            # Parsing key=value
            for key in $(echo $line|sed -e "s/' /'\n/g"); do
                eval ${key%%=*}="${key#*=}"
            done
            # Print result line
            eval echo "\"$fields\""|sed -e "s/%quote%/'/g"
        fi
        i=$(($i + 1))
    done < $conf
}

is_job_suspended() {
    # Parsing jobs
    str=$(grep "JOB='$job'" $V_USERS/$user/crontab.conf|grep "SUSPEND='yes'" )

    # Checkng key
    if [ ! -z "$str" ]; then
        echo "Error: job suspended"
        log_event 'debug' "$E_JOB_SUSPENDED $V_EVENT"
        exit $E_JOB_SUSPENDED
    fi
}

is_job_unsuspended() {
    # Parsing jobs
    str=$(grep "JOB='$job'" $V_USERS/$user/crontab.conf|grep "SUSPEND='no'" )

    # Checkng key
    if [ ! -z "$str" ]; then
        echo "Error: job unsuspended"
        log_event 'debug' "$E_JOB_UNSUSPENDED $V_EVENT"
        exit $E_JOB_UNSUSPENDED
    fi
}

update_cron_job_value() {
    key="$1"
    value="$2"

    # Defining conf
    conf="$V_USERS/$user/crontab.conf"

    # Parsing conf
    job_str=$(grep -n "JOB='$job'" $conf)
    str_number=$(echo $job_str | cut -f 1 -d ':')
    str=$(echo $job_str | cut -f 2 -d ':')

    # Parsing key=value
    IFS=$'\n'
    for keys in $(echo $str|sed -e "s/' /'\n/g"); do
        eval ${keys%%=*}=${keys#*=}
    done

    # Defining clean key
    c_key=$(echo "${key//$/}")

    eval old="${key}"

    # Escaping slashes
    old=$(echo "$old" | sed -e 's/\\/\\\\/g' -e 's/&/\\&/g' -e 's/\//\\\//g')
    new=$(echo "$value" | sed -e 's/\\/\\\\/g' -e 's/&/\\&/g' -e 's/\//\\\//g')

    # Updating conf
    sed -i "$str_number s/$c_key='${old//\*/\\*}'/$c_key='${new//\*/\\*}'/g" \
            $conf
}

cron_clear_search() {
    # Defining delimeter
    IFS=$'\n'

    # Reading file line by line
    for line in $(grep $search_string $conf); do

        # Defining new delimeter
        IFS=$'\n'
        # Parsing key=value
        for key in $(echo $line|sed -e "s/' /'\n/g"); do
            eval ${key%%=*}=${key#*=}
        done

        # Print result line
        eval echo "$field"
    done
}
