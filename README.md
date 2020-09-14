# Prometheus Crystal Client

A suite of instrumentation metric primitives for Crystal that can be exposed through a HTTP interface. Intended to be used together with a [Prometheus server][prometheus].

Note: This repository has been forked from https://github.com/inkel/crystal-prometheus-client.
It is close to the original work, but took some liberties with the API and added some missing functionality.

[![Build Status](https://travis-ci.org/philipp-classen/crystal-prometheus-client.svg?branch=master)](https://travis-ci.org/philipp-classen/crystal-prometheus-client)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  prometheus:
    github:  philipp-classen/crystal-prometheus-client
```

## Usage

### Overview

```crystal
require "prometheus/client"

# returns a default registry
prometheus = Prometheus::Client.registry

# create a new counter metric
http_requests = Prometheus::Client::Counter.new(:http_requests, "A counter of HTTP requests made")
# register the metric
prometheus.register(http_requests)

# start using the counter
http_requests.inc
```
## Metrics

The following metric types are currently supported.

### Counter

Counter is a metric that exposes merely a sum or tally of things.

```crystal
counter = Prometheus::Client::Counter.new(:service_requests_total, "...")

# increment counter
counter.inc

# increment counter by a given value
counter.inc(7)

# increment the counter for a given label set
counter.inc({ :service => "foo" })

# increment by a given value for a given label
counter.inc(5, { :service => "bar" })

# get current value for a given label set
counter.get({ :service => "bar" })
# => 5
```

### Gauge

Gauge is a metric that exposes merely an instantaneous value or some snapshot
thereof.

```crystal
gauge = Prometheus::Client::Gauge.new(:room_temperature_celsius, "...")

# set a value
gauge.set(21.534, { :room => "kitchen" })

# retrieve the current value for a given label set
gauge.get({ :room => "kitchen" })
# => 21.534
```

Also you can use gauge as the bi-directional counter:

```crystal
gauge = Prometheus::Client::Gauge.new(:concurrent_requests_total, "...")

gauge.inc({ :service => "foo" })
# => 1.0

gauge.dec({ :service => "foo" })
# => 0.0
```

### Histogram

A histogram samples observations (usually things like request durations or
response sizes) and counts them in configurable buckets. It also provides a sum
of all observed values.

```crystal
histogram = Prometheus::Client::Histogram.new(:service_latency_seconds, "...")

# record a value
histogram.observe(Benchmark.realtime { service.call(arg) }, { :service => "users" })

# retrieve the current bucket values
histogram.get({ :service => "users" })
# => { 0.005 => 3, 0.01 => 15, 0.025 => 18, ..., 2.5 => 42, 5 => 42, 10 = >42 }
```

### Exporting Metrics

To expose the metrics, the
[text-based format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format)
is supported. To generate the text, use `Prometheus::Client.to_text` and setup an HTTP endpoint.

For example, if you are already using [Kemel](https://github.com/kemalcr/kemal), you can
setup the metrics endpoints like that:

```crystal
get "/metrics" do
  Prometheus::Client.to_text
end
```

## Caveats
* No `HTTP::Handler` middleware
* No [`Pushgateway`][pushgateway] support

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

This repository has been forked. The original can be found here:

- [inkel](https://github.com/inkel) Leandro López - creator, maintainer

[prometheus]: https://prometheus.io/
[pushgateway]: https://github.com/prometheus/pushgateway
