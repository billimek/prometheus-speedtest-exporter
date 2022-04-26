# Speedtest CLI Prometheus Exporter

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/billimek/prometheus-speedtest-exporter)](https://hub.docker.com/r/billimek/prometheus-speedtest-exporter/tags)

![](https://i.imgur.com/iIzWUre.png)

This is a docker container which runs a prometheus exporter to collect speedtest data using the official [Speedtest CLI](https://www.speedtest.net/apps/cli) and [script_exporter](https://github.com/ricoberger/script_exporter).  The [billimek/prometheus-speedtest-exporter](https://hub.docker.com/repository/docker/billimek/prometheus-speedtest-exporter) docker image is multi-arch supporting amd64, arm7, and arm64.

## Testing the Exporter

For a simple initial test, run the container as follows:

```bash
sudo docker run --rm -p 9469:9469 billimek/prometheus-speedtest-exporter:latest
```

Then invoke the `/probe` endpoint:

```bash
curl http://localhost:9469/probe?script=speedtest
```

After about 15 to 30 seconds or so you should see a result like this:

```bash
# HELP script_success Script exit status (0 = error, 1 = success).
# TYPE script_success gauge
script_success{} 1
# HELP script_duration_seconds Script execution time, in seconds.
# TYPE script_duration_seconds gauge
script_duration_seconds{} 99.714076
# HELP speedtest_latency_seconds Latency
# TYPE speedtest_latency_seconds gauge
speedtest_latency_seconds 17.363
# HELP speedtest_jittter_seconds Jitter
# TYPE speedtest_jittter_seconds gauge
speedtest_jittter_seconds 1.023
# HELP speedtest_download_bytes Download Speed
# TYPE speedtest_download_bytes gauge
speedtest_download_bytes 5852661
# HELP speedtest_upload_bytes Upload Speed
# TYPE speedtest_upload_bytes gauge
speedtest_upload_bytes 2433723
# HELP speedtest_downloadedbytes_bytes Downloaded Bytes
# TYPE speedtest_downloadedbytes_bytes gauge
speedtest_downloadedbytes_bytes 43619764
# HELP speedtest_uploadedbytes_bytes Uploaded Bytes
# TYPE speedtest_uploadedbytes_bytes gauge
speedtest_uploadedbytes_bytes 23199680
```

## Prometheus configuration

The script_exporter needs to be passed the script name as a parameter (script). It is advised to use a long `scrape_interval` to avoid excessive bandwidth use.

Example config:

```yaml
scrape_configs:
  - job_name: 'speedtest'
    metrics_path: /probe
    params:
      script: [speedtest]
    static_configs:
      - targets:
        - 127.0.0.1:9469
    scrape_interval: 60m
    scrape_timeout: 90s
  - job_name: 'script_exporter'
    metrics_path: /metrics
    static_configs:
      - targets:
        - 127.0.0.1:9469
```

## helm chart

If running in kubernetes, there is a helm chart leveraging this with a built-in `ServiceMonitor` for an autoconfigured solution: https://github.com/billimek/billimek-charts/tree/master/charts/speedtest-prometheus

## Grafana Dashboard

Included is an [example grafana dashboard](speedtest-exporter.json) as shown in the screenshot above.

## Speed Testing Against Multiple Target Servers

By default speedtest will automatically choose a server close to you.  You may override this choice and specify one or more Speedtest servers to test against by setting the `server_ids` environment variable.  For example in Docker Compose:

```yaml
  speedtest:
    image: "billimek/prometheus-speedtest-exporter:latest"
    restart: "on-failure"
    ports:
      - 9469:9469
    environment:
      - server_ids=3855,1782,2225 # 3855 => DTAC Bangkok; 1782 => Comcast Seattle; 2225 => Telstra Melbourne
```

The exporter will now run speedtest for each server that you specify one-by-one.  Generated metrics will also be labeled with the server ID - for example:

```
speedtest_latency_seconds{server_id="3855"} 17.363
...
speedtest_latency_seconds{server_id="1782"} 251.393
...
speedtest_latency_seconds{server_id="2225"} 292.73
```

As you add more servers you may need to extend the scrape_timeout for the Prometheus job so it doesn't get killed before it completes:

```yml
  - job_name: "speedtest"
    metrics_path: /probe
    params:
      script: [speedtest]
    static_configs:
      - targets:
        - 127.0.0.1:9469
    scrape_interval: 60m
    scrape_timeout: 10m
```

Use this [searchable list](https://williamyaps.github.io/wlmjavascript/servercli.html) to find server ID's.

## Inspired by

* https://github.com/h2xtreme/prometheus-speedtest-exporter
* https://github.com/ricoberger/script_exporter
* https://github.com/pschmitt/docker-ookla-speedtest-cli