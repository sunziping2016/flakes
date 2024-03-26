{
  # common settings
  services.nginx = {
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "me@szp.io";
      webroot = "/var/lib/acme/acme-challenge";
    };
  };
}
