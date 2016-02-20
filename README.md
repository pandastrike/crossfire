# Crossfire

A simple proxy that uses DNS SRV records to dynamically update its routing table.

## Set Up SRV Records

To map `web.blurb9.com:80` to `swarm-0.blurb9.com:32777`, define an SRV record like this:

```
_web._http. 10 IN SRV 0 0 32777 swarm-0.blurb9.com.
```

## Run Crossfire

In Docker, you can deploy this to the same swarm you're running your other endpoints. Or you can do it on a separate swarm. Or not use Docker at all, of course. But, using Docker:

```
docker run -p 80:80 -d crossfire:latest
```

## Build Crossfire

You may need to build an image, which you can do by cloning and running:

```
docker build -t crossfire .
```

## Test It Out

```
curl web.blurb9.com
```

Because we're dealing with DNS, you may run into problems with stale DNS entries. Be sure to set low TTLs and use a DNS service that updates itself frequently.
