# Test with:
# -> ldapwhoami
# -> ldapsearch uid=<username>
{ lib, config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openldap
  ];

  users.ldap = {
    enable = true;
    base = "dc=ipa,dc=redhat,dc=com";
    server = "ldaps://s1.idm-001.prod.iad2.dc.redhat.com";
    extraConfig = ''
      SASL_NOCANON	on
      SASL_MECH GSSAPI
      TLS_REQCERT demand
    '';
  };

  # evil, horrifying hack for dysfunctional nss_override_attribute_value
  systemd.tmpfiles.rules = [
    "L /bin/bash - - - - /run/current-system/sw/bin/bash"
  ];
}
