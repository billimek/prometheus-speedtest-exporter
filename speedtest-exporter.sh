#!/bin/bash

# printMetric name description type value server_id
function printMetric {
    echo "# HELP $1 $2"
    echo "# TYPE $1 $3"
    if [ -z "$server_id" ]
    then
        echo "$1 $4"
    else
        echo "$1{server_id=\"$server_id\"} $4"
    fi
}

if [ -z "$server_ids" ]
then
        while IFS=$'\t' read -r servername serverid latency jitter packetloss download upload downloadedbytes uploadedbytes share_url; do
            printMetric "speedtest_latency_seconds" "Latency" "gauge" "$latency"
            printMetric "speedtest_jittter_seconds" "Jitter" "gauge" "$jitter"
            printMetric "speedtest_download_bytes" "Download Speed" "gauge" "$download"
            printMetric "speedtest_upload_bytes" "Upload Speed" "gauge" "$upload"
            printMetric "speedtest_downloadedbytes_bytes" "Downloaded Bytes" "gauge" "$downloadedbytes"
            printMetric "speedtest_uploadedbytes_bytes" "Uploaded Bytes" "gauge" "$uploadedbytes"
        done < <(/usr/local/bin/speedtest --accept-license --accept-gdpr -f tsv)
else
    IFS=',' read -ra server_id_array <<< "$server_ids"
    for server_id in "${server_id_array[@]}"
    do
        while IFS=$'\t' read -r servername serverid latency jitter packetloss download upload downloadedbytes uploadedbytes share_url; do
            printMetric "speedtest_latency_seconds" "Latency" "gauge" "$latency" "$server_id"
            printMetric "speedtest_jittter_seconds" "Jitter" "gauge" "$jitter" "$server_id"
            printMetric "speedtest_download_bytes" "Download Speed" "gauge" "$download" "$server_id"
            printMetric "speedtest_upload_bytes" "Upload Speed" "gauge" "$upload" "$server_id"
            printMetric "speedtest_downloadedbytes_bytes" "Downloaded Bytes" "gauge" "$downloadedbytes" "$server_id"
            printMetric "speedtest_uploadedbytes_bytes" "Uploaded Bytes" "gauge" "$uploadedbytes" "$server_id"
        done < <(/usr/local/bin/speedtest --accept-license --accept-gdpr -f tsv --server-id $server_id)
    done
fi
