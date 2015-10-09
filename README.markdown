# Hydra

Hydra is a Docker image containing Tor, and upon startup it will spawn as many
tor connections as desired. It also includes a JSON API for port discovery
and connection management.

# Installation

```
docker pull docker-dev.ops.tune.com/mdhq/hydra:latest
```

# Usage

Just start it up:

```
docker run -it -p 3000:9292 -P docker-dev.ops.tune.com/mdhq/hydra:latest
```

Once it's up, you can access the API on port 3000 (if you followed the above example).

## Endpoints

```
GET /
```

Redirects to `/status`.

```
GET /status
```

Returns a summary of the state of all the Tor connections and their regions.

```
GET /heartbeat
```

Verifies that the container/API is alive.

```
GET /regions
```

Lists connected regions by ISO code, along with their SOCKS ports.

```
GET /regions/:iso_code
```

Displays a single region with its SOCKS ports.

```
GET /ports
```

Lists all open ports, with their region and PID in the container.

```
GET /ports/:port
```

Displays a single port with its associated info.

```
GET /ports/:port/test
```

Makes a curl request to `http://google.com` and parses the redirect. It then returns
the result of the redirect, along with the region that we expect.

```
GET /ports/:port/restart
```

Kills the Tor connection on the specified port, which will cause supervisord to
start a new one, thereby refreshing the connection to the Tor network. Primarily
useful if an exit IP has gone bad, or is in the wrong region.

