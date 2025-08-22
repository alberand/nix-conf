let
  # Users
  aalbersh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTyoIDtgjlNfutIx2mL1rcJgTgy2xPtBE658NMuEKxy";
  alberand-rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrD5vBHHmwEAgwr7EwiF0WJO8vEJZwtsf/MyuwWoGOqxMZG+FXXomKm7ifaGSLpGoCHT4etNKbTPjShk9S4aSnnYfU9dc6k7Ke1Dt4KkKSVPA0ot3+46DeGu5TKl0PIRVOhlEyse81lWEVdDVg2xKqjYGsk5sOPWlV/V8/Jj1zlb0XiaQjPK9SoYeJLzH32EHoqns5s1WNWOTTnAYahESAi8qoL6ZVo9oBK0UU09YH3bVoIqZau+SXVoj9Ek8n1hf8/wnCJIaMqx1KTVO5S7TxGGNf4wjxcIwNi/XrqnyvlVZrX27gHfihSSMmauS0EuV3c6/Jf8gLl6/LfNs8VtpH";
  alberand = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsaaX1d/7zZHiZIsPFhtvmEChTB0p7sKECk7p6UcUqr";
  door = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDeXC/xh8VjiSFPLHG7ac1TeISsgp8Mw/9ShtXTtNOI";

  # Systems
  nixxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrvWws1g7nmmEV0hff+49ufO4yM4GCUfHgzPVL5Raw+";
  thinky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByn5I88HSu5WM3EIr8GVtbEbxHPpT+JB6m9Su0r3NLY";
  quesada = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg+a+8SnLxBS/Dq1WiVQsMTy7iorO6xG9D1bIN5fW3S";
in {
  "thinky-neomutt.age".publicKeys = [aalbersh thinky];
  "acme-env.age".publicKeys = [nixxy door alberand alberand-rsa];
  "paperless.age".publicKeys = [nixxy alberand alberand-rsa];
  "nextcloud.age".publicKeys = [nixxy alberand alberand-rsa];
  "binary-cache-key.age".publicKeys = [nixxy alberand];
  "nixbuilder_ed25519.age".publicKeys = [aalbersh alberand thinky];
  "quesada-tskey.age".publicKeys = [alberand quesada];
  "gatus.age".publicKeys = [alberand nixxy];
  "davfs.age".publicKeys = [alberand nixxy];
  "hskey.age".publicKeys = [alberand door nixxy];
  "door-cert.age".publicKeys = [alberand door];
  "door-key.age".publicKeys = [alberand door];
  "door-pocket-id-env.age".publicKeys = [alberand door];
  "door-pocket-id-cert.age".publicKeys = [alberand door];
  "door-pocket-id-key.age".publicKeys = [alberand door];
  "door-headscale-pocket-id.age".publicKeys = [alberand door];
  "door-mullvad-key.age".publicKeys = [alberand door];
  "nixxy-mealie.age".publicKeys = [alberand nixxy];
  "nixxy-copyparty.age".publicKeys = [alberand nixxy];
  "jellyfin-wg-server.age".publicKeys = [alberand door];
  "jellyfin-wg-client.age".publicKeys = [alberand nixxy];
  "nixxy-rclone-key.age".publicKeys = [alberand nixxy];
  "restic-hetzner-key.age".publicKeys = [alberand nixxy];
  "restic-password.age".publicKeys = [alberand nixxy];
}
