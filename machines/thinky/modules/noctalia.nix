{pkgs, ...}: {
  programs.noctalia-shell = {
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
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            {
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
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
    };
    # this may also be a string or a path to a JSON file.
  };
}
