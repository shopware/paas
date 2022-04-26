if (req.http.cookie ~ "sw-states=") {
   set req.http.states = regsub(req.http.cookie, "^.*?sw-states=([^;]*);*.*$", "\1");

   if (req.http.states ~ "logged-in" && obj.http.sw-invalidation-states ~ "logged-in" ) {
      return (pass);
   }

   if (req.http.states ~ "cart-filled" && obj.http.sw-invalidation-states ~ "cart-filled" ) {
      return (pass);
   }
}
