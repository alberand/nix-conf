{pkgs, ...}: {
  programs.noctalia = {
    enable = true;
    settings = {
      # configure noctalia here
      bar = {
        density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
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
          center = [
            {
              hideUnoccupied = true;
              id = "Workspace";
              labelMode = "none";
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
      colorSchemes.predefinedScheme = "Monochrome";
      colors = {
        # you must set ALL of these
        mPrimary = "#fff59b";
        mOnPrimary = "#0e0e43";
        mSecondary = "#a9aefe";
        mOnSecondary = "#0e0e43";
        mTertiary = "#9BFECE";
        mOnTertiary = "#0e0e43";
        mError = "#FD4663";
        mOnError = "#0e0e43";
        mSurface = "#070722";
        mOnSurface = "#f3edf7";
        mSurfaceVariant = "#11112d";
        mOnSurfaceVariant = "#7c80b4";
        mOutline = "#21215F";
        mShadow = "#070722";
        mHover = "#9BFECE";
        mOnHover = "#0e0e43";
      };
      general = {
        avatarImage = "/home/aalbersh/.face";
        radiusRatio = 0.2;
      };
      location = {
        monthBeforeDay = true;
        name = "Prague, Czechia";
      };
      dock = {
        enabled = false;
      };
      controlCenter.cards = [
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

      appLauncher = {
        enableClipboardHistory = true;
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        enableClipboardSmartIcons = true;
        enableClipboardChips = true;
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        position = "center";
        pinnedApps = [];
        sortByMostUsed = true;
        terminalCommand = "kitty";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
        viewMode = "list";
        showCategories = true;
        iconMode = "tabler";
        showIconBackground = false;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        enableSessionSearch = true;
        ignoreMouseInput = false;
        screenshotAnnotationTool = "";
        overviewLayer = false;
        density = "default";
      };

      nightLight = {
        enabled = true;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };
    };
    # this may also be a string or a path to a JSON file.
  };
}
