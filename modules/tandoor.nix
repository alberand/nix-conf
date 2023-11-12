{ pkgs, ...}:
{
  services.tandoor-recipes = {
    enable = true;
    address = "127.0.0.1";
    port = 8114;
  };
}
