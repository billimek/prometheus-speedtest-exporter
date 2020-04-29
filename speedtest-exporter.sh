#!/bin/bash
# printMetric name description type value
function printMetric {
    echo "# HELP $1 $2"
    echo "# TYPE $1 $3"
    echo "$1 $4"
}

while IFS=$'\t' read -r servername serverid latency jitter packetloss download upload downloadedbytes uploadedbytes share_url; do
    printMetric "speedtest_latency_seconds" "Latency" "gauge" "$latency"
    printMetric "speedtest_jittter_seconds" "Jitter" "gauge" "$jitter"
    printMetric "speedtest_download_bytes" "Download Speed" "gauge" "$download"
    printMetric "speedtest_upload_bytes" "Upload Speed" "gauge" "$upload"
    printMetric "speedtest_downloadedbytes_bytes" "Downloaded Bytes" "gauge" "$downloadedbytes"
    printMetric "speedtest_uploadedbytes_bytes" "Uploaded Bytes" "gauge" "$uploadedbytes"
done < <(/usr/local/bin/speedtest --accept-license --accept-gdpr -f tsv)
