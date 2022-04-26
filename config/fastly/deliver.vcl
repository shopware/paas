# Remove the exact PHP Version from the response for more security (e.g. 404 pages)
unset resp.http.x-powered-by;

if (resp.http.sw-invalidation-states) {
  # invalidation headers are only for internal use
  unset resp.http.sw-invalidation-states;

  ## we don't want the client to cache
  set resp.http.Cache-Control = "max-age=0, private";
}
