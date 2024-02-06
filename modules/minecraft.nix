{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    mcrcon
  ];

  services.minecraft-server = {
    enable = false;
    eula = true; # https://account.mojang.com/documents/minecraft_eula
    declarative = true;

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
    };
  };
}
