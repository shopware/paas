# Mitigate httpoxy application vulnerability, see: https://httpoxy.org/
unset req.http.Proxy;

# Strip query strings only needed by browser javascript. Customize to used tags.
if (req.url != req.url.path) {
  set req.url = querystring.regfilter(req.url, "pk_campaign|piwik_campaign|pk_kwd|piwik_kwd|pk_keyword|pixelId|kwid|kw|adid|chl|dv|nk|pa|camid|adgid|cx|ie|cof|siteurl|utm_[a-z]+|_ga|gclid");
}

# Normalize query arguments
set req.url = querystring.sort(req.url);

# Make sure that the client ip is forward to the client.
if (req.http.x-forwarded-for) {
    set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
} else {
    set req.http.X-Forwarded-For = client.ip;
}

# Normally, you should consider requests other than GET and HEAD to be uncacheable
# (to this we add the special FASTLYPURGE method)
if (req.method != "HEAD" && req.method != "GET" && req.method != "FASTLYPURGE") {
  return(pass);
}

# Don't cache Authenticate & Authorization
if (req.http.Authenticate || req.http.Authorization) {
    return (pass);
}

# Always pass these paths directly to php without caching
# Note: virtual URLs might bypass this rule (e.g. /en/checkout)
if (req.url.path ~ "^/(checkout|account|admin|api)(/.*)?$") {
    return (pass);
}

return (lookup);
