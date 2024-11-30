{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    mcrcon
  ];

  services.minecraft-server = {
    enable = true;
    eula = true; # https://account.mojang.com/documents/minecraft_eula
    declarative = true;
    whitelist = {
      alberand = "25aba768-3d02-4bd5-803d-e5aa23bdb9df";
      superbulka2704 = "955fc02f-894a-483d-9df2-f510e8fab8ae";
    };

    # https://minecraft.gamepedia.com/Server.properties#server.properties
    serverProperties = {
      server-port = 5555;
      gamemode = "survival";
      motd = "Andrey & Julia Minecraft server";
      max-players = 10;
      enable-rcon = true;
      difficulty = 3;
      allow-flight = true;
      allow-nether = true;
      # This password can be used to administer your minecraft server.
      # Exact details as to how will be explained later. If you want
      # you can replace this with another password.
      "rcon.password" = "andreyminecraft";
      level-name = "Our World";
      level-seed = "";
      white-list = true;
    };
  };
}
