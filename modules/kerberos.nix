{
  config,
  pkgs,
  ...
}: {
  security.krb5 = {
    enable = true;

    settings = {
      libdefaults = {
        default_realm = "IPA.REDHAT.COM";
        dns_lookup_realm = true;
        dns_lookup_kdc = true;
        rdns = false;
        dns_canonicalize_hostname = false;
        ticket_lifetime = "24h";
        forwardable = true;
        udp_preference_limit = 0;
        default_ccache_name = "KEYRING:persistent:%{uid}";
      };

      realms = {
        "REDHAT.COM" = {
          default_domain = "redhat.com";
          dns_lookup_kdc = true;
          master_kdc = "kerberos.corp.redhat.com";
          admin_server = "kerberos.corp.redhat.com";
        };

        "IPA.REDHAT.COM" = {
          default_domain = "ipa.redhat.com";
          dns_lookup_kdc = true;
        };
      };
    };
  };
}
