{pkgs, config, ...}: {
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "met"
      "radio_browser"
      "backup"
      "jellyfin"
      "google_assistant"
      "openweathermap"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };
}
