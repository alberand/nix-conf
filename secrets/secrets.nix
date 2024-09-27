let
  aalbersh = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMMuyusNaXCAFiYRDo3DdkVp1vvx6YF//ErfgQQ0sKA3DkkaDp6oU4GJ+ix69tBlZf2LSK3WduWm064XNFp75ppiOSRB0PRhwHR/rAgLyZkZJ5OPobaiaUhg5VNlET/MJ/q3/2zoyQg6tsLRpAABykvggIdC0q/QGIl3exp6WrC5Hk+YhayZhmHz3QflWmTSkl2jfCY3seauhaMFczGWnLnirF1RtQ33sPoVhG6kGr4RSnfXOMfi0qDA8eMt/Wart3o5ZiOAvs1tHcKFW7T2E3XwbxMKKFOzqupKcDnjorE15Wm/fGY5MEH+kNbnPpksQzZ+uhKg8jwRRHXKzLQcp/y+ihXRrZaGQjrvNbycd9kAk5uC6HVmcWXYQw039LjZsc+vBJLcYizJP+Iw/tLk0xdJmqWgNMgwKCdVgpIkAhAexc9/S28JNP6PvtVoEoKzTv1a9roUz5gLeXQes7gpMofY8UeiuHVtBeTbzOojj8WXKsQ25tfAj8MrXvnpXNLWs=";
  users = [ aalbersh ];

  thinky = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByn5I88HSu5WM3EIr8GVtbEbxHPpT+JB6m9Su0r3NLY";
  systems = [ thinky ];
in
{
  "root-ca.age".publicKeys = [ aalbersh thinky ];
}
