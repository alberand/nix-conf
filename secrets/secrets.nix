# Generating self-signing certificate
# openssl ecparam -name secp384r1 -genkey -out ecdsa.key
# openssl req -new -x509 -days 36524 -key "ecdsa.key" -sha384 -out ecdsa.crt
#
let
  aalbersh = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMMuyusNaXCAFiYRDo3DdkVp1vvx6YF//ErfgQQ0sKA3DkkaDp6oU4GJ+ix69tBlZf2LSK3WduWm064XNFp75ppiOSRB0PRhwHR/rAgLyZkZJ5OPobaiaUhg5VNlET/MJ/q3/2zoyQg6tsLRpAABykvggIdC0q/QGIl3exp6WrC5Hk+YhayZhmHz3QflWmTSkl2jfCY3seauhaMFczGWnLnirF1RtQ33sPoVhG6kGr4RSnfXOMfi0qDA8eMt/Wart3o5ZiOAvs1tHcKFW7T2E3XwbxMKKFOzqupKcDnjorE15Wm/fGY5MEH+kNbnPpksQzZ+uhKg8jwRRHXKzLQcp/y+ihXRrZaGQjrvNbycd9kAk5uC6HVmcWXYQw039LjZsc+vBJLcYizJP+Iw/tLk0xdJmqWgNMgwKCdVgpIkAhAexc9/S28JNP6PvtVoEoKzTv1a9roUz5gLeXQes7gpMofY8UeiuHVtBeTbzOojj8WXKsQ25tfAj8MrXvnpXNLWs=";
  alberand-rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrD5vBHHmwEAgwr7EwiF0WJO8vEJZwtsf/MyuwWoGOqxMZG+FXXomKm7ifaGSLpGoCHT4etNKbTPjShk9S4aSnnYfU9dc6k7Ke1Dt4KkKSVPA0ot3+46DeGu5TKl0PIRVOhlEyse81lWEVdDVg2xKqjYGsk5sOPWlV/V8/Jj1zlb0XiaQjPK9SoYeJLzH32EHoqns5s1WNWOTTnAYahESAi8qoL6ZVo9oBK0UU09YH3bVoIqZau+SXVoj9Ek8n1hf8/wnCJIaMqx1KTVO5S7TxGGNf4wjxcIwNi/XrqnyvlVZrX27gHfihSSMmauS0EuV3c6/Jf8gLl6/LfNs8VtpH";
  alberand = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsaaX1d/7zZHiZIsPFhtvmEChTB0p7sKECk7p6UcUqr";
  door = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDeXC/xh8VjiSFPLHG7ac1TeISsgp8Mw/9ShtXTtNOI";
  users = [aalbersh alberand alberand-rsa];

  nixxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrvWws1g7nmmEV0hff+49ufO4yM4GCUfHgzPVL5Raw+";
  thinky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByn5I88HSu5WM3EIr8GVtbEbxHPpT+JB6m9Su0r3NLY";
  quesada = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg+a+8SnLxBS/Dq1WiVQsMTy7iorO6xG9D1bIN5fW3S";
  systems = [thinky];
in {
  "thinky-env.age".publicKeys = [aalbersh thinky];
  "acme-env.age".publicKeys = [nixxy door alberand alberand-rsa];
  "paperless.age".publicKeys = [nixxy alberand alberand-rsa];
  "nextcloud.age".publicKeys = [nixxy alberand alberand-rsa];
  "binary-cache-key.age".publicKeys = [nixxy alberand];
  "nixbuilder_ed25519.age".publicKeys = [aalbersh alberand thinky];
  "quesada-tskey.age".publicKeys = [alberand quesada];
  "gatus.age".publicKeys = [alberand nixxy];
  "davfs.age".publicKeys = [alberand nixxy];
  "door-tskey.age".publicKeys = [alberand door];
  "door-cert.age".publicKeys = [alberand door];
  "door-key.age".publicKeys = [alberand door];
}
