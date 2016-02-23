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
  find: async (request) ->
    {name, domain} = parseHost request.headers.host
    console.log "finding routes with ", {name, domain}
    if domain?
      addresses = yield dns.resolveSrv "_#{name}._http.#{domain}"
      address = addresses[Math.round(Math.random() * (addresses.length - 1))]
      console.log "found route #{address.name}:#{address.port}"
      address

Proxy =

  log: do (n=0) ->
    (next) ->
      (request, response) ->
        {url, method, headers} = request
        host = if headers.host? then headers.host else "-"
        console.log "request #{n}: #{host} #{method} #{url}"
        do (n) ->
          response.on "finish", ->
            {statusCode} = response
            console.log "response #{n}: #{statusCode}"
        n++
        next request, response

  start: (_port) ->
    http.createServer Proxy.log async (request, response) ->
      {url, method, headers} = request
      try
        {name, port} = yield Routes.find request
        # not sure we need this, but we don't want to rely
        # on the OS to resolve these names since they may
        # be changing pretty frequently...
        [host] = yield dns.resolve name
        console.log "resolved #{name} to #{host}"
        console.log "proxying request", {host, port, path: url, method, headers}
        request.pipe http.request {host, port, path: url, method, headers},
          (_response) ->
            response.writeHead _response.statusCode, _response.headers
            _response.pipe response
      catch error
        response.statusCode = 503
        response.end()
    .listen _port, ->
      console.log "Listening on port #{_port}"

Proxy.start (if process.argv[2]? then process.argv[2] else 80)
