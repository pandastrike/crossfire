{async} = require "fairmont"
http = require "http"
{promise} = require "when"
{liftAll} = require "when/node"
dns = liftAll require "dns"

dns.setServers [
  "8.8.8.8"
  "8.8.4.4"
]

parseHost = do (re=/^(\w+)(\.(\w+\.\w+))?(:(\d+))?$/) ->
  (host) ->
    if (match = host.match re)?
      [_, name, _, domain, _, port] = match
      {name, domain, port}
    else
      {}

Routes =
  find: (request) ->
    {name, domain} = parseHost request.headers.host
    if domain?
      console.log "_#{name}._http.#{domain}"
      promise (resolve, reject) ->
        dns.resolveSrv "_#{name}._http.#{domain}"
        .then (addresses) ->
          resolve addresses[Math.round(Math.random() * (addresses.length - 1))]

Proxy =

  start: (_port) ->
    http.createServer async (request, response) ->
      {url, method, headers} = request
      console.log headers.host, method, url
      try
        {name, port} = yield Routes.find request
        # not sure we need this, but we don't want to rely
        # on the OS to resolve these names since they may
        # be changing pretty frequently...
        [host] = yield dns.resolve name
        request.pipe http.request {host, port, url, method, headers},
          (_response) -> _response.pipe response
      catch error
        response.statusCode = 503
        response.end()
    .listen _port, ->
      console.log "Listening on port #{_port}"

Proxy.start (if process.argv[2]? then process.argv[2] else 80)
