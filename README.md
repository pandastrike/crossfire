# Crossfire

A simple proxy that uses DNS SRV records to dynamically update its routing table.

## Set Up SRV Records

To map `web.blurb9.com:80` to `swarm-0.blurb9.com:32777`, define an SRV record like this:

```
_web._http. 10 IN SRV 0 0 32777 swarm-0.blurb9.com.
```

## Run Crossfire

Just run `npm start` to run the server. You can pass a port if you want.

You can also run on a Docker host:

```
bin/crossfire build
bin/crossfire run
```

You can clean up a Docker deployment with `clean`:

```
bin/crossfire clean
```

To load balance across crossfire instances, just run multiple instances and add them to your load balancer.

## Test It Out

Provided your DNS entries are set up correctly and you should be able to test with `curl` or a Web browser.

You may run into problems with stale DNS entries. Be sure to set low TTLs and use a DNS service that updates itself frequently.
