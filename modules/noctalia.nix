{pkgs, ...}: {
  programs.noctalia = {
    enable = true;
    # noctalia config export > noctalia.toml
    # nix run github:erooke/toml2nix -- ./noctalia.toml > noctalia.nix
    settings = {
      appLauncher = {
        autoPasteClipboard = false;
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        customLaunchPrefix = "";
        customLaunchPrefixEnabled = false;
        density = "default";
        enableClipPreview = true;
        enableClipboardChips = true;
        enableClipboardHistory = true;
        enableClipboardSmartIcons = true;
        enableSessionSearch = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "tabler";
        ignoreMouseInput = false;
        overviewLayer = false;
        pinnedApps = [];
        position = "center";
        screenshotAnnotationTool = "";
        showCategories = true;
        showIconBackground = false;
        sortByMostUsed = true;
        terminalCommand = "kitty";
        viewMode = "list";
      };
      bar = {
        density = "compact";
        marginHorizontal = 0;
        marginVertical = 0;
        position = "top";
        showCapsule = false;
        widgets = {
          end = [
            "tray"
            "notifications"
            "clipboard"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "session"
          ];
          margin_edge = 0;
          margin_ends = 0;
          radius = 0;
          start = [
            "launcher"
            "control-center"
            "workspaces"
          ];
          widget_spacing = 10;
          center = [
            {
              hideUnoccupied = true;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
          ];
          right = [
            {
              alwaysShowPercentage = true;
              id = "Battery";
              warningThreshold = 15;
            }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
      calendar = {
        enabled = true;
      };
      colorSchemes = {
        predefinedScheme = "Monochrome";
      };
      colors = {
        mError = "#FD4663";
        mHover = "#9BFECE";
        mOnError = "#0e0e43";
        mOnHover = "#0e0e43";
        mOnPrimary = "#0e0e43";
        mOnSecondary = "#0e0e43";
        mOnSurface = "#f3edf7";
        mOnSurfaceVariant = "#7c80b4";
        mOnTertiary = "#0e0e43";
        mOutline = "#21215F";
        mPrimary = "#fff59b";
        mSecondary = "#a9aefe";
        mShadow = "#070722";
        mSurface = "#070722";
        mSurfaceVariant = "#11112d";
        mTertiary = "#9BFECE";
      };
      controlCenter = {
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = false;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = false;
            id = "media-sysmon-card";
          }
        ];
      };
      dock = {
        enabled = false;
      };
      general = {
        avatarImage = "/home/aalbersh/.face";
        radiusRatio = 0.2;
      };
      location = {
        address = "Prague, Czechia";
        monthBeforeDay = true;
        name = "Prague, Czechia";
      };
      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = ["lockscreen-login-box@HDMI-A-1"];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget = {
          "lockscreen-login-box@HDMI-A-1" = {
            box_height = 70.0;
            box_width = 400.0;
            cx = 960.0;
            cy = 961.0;
            output = "HDMI-A-1";
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_password_hint = true;
            };
          };
        };
      };
      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = true;
        forced = false;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        nightTemp = "4000";
      };
      nightlight = {
        enabled = true;
      };
      shell = {
        avatar_path = "/home/alberand/Pictures/profile-pic-square.jpg";
        corner_radius_scale = 0.0;
        session = {
          actions = [
            {
              action = "lock";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "1";
              variant = "default";
            }
            {
              action = "logout";
              countdown_seconds = 0.0;
              enabled = false;
              shortcut = "2";
              variant = "default";
            }
            {
              action = "lock_and_suspend";
              countdown_seconds = 0.0;
              enabled = false;
              shortcut = "3";
              variant = "default";
            }
            {
              action = "reboot";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "4";
              variant = "default";
            }
            {
              action = "shutdown";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "5";
              variant = "destructive";
            }
          ];
        };
      };
      theme = {
        community_palette = "Doomed";
        source = "community";
      };
      wallpaper = {
        default = {
          path = "/home/alberand/Pictures/wallpaper.png";
        };
        last = {
          path = "/home/alberand/Pictures/wallpaper.png";
        };
      };
    };
  };
}
