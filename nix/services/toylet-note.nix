{ config, lib, pkgs, ... }:

let
  cfg = config.services.toylet-notes;

  notesPackage = pkgs.runCommand "toylet-notes-content" {} ''
    mkdir -p $out
    cp -r ${../../notes} $out/notes
  '';
in {
  options.services.toylet-notes = {
    enable = lib.mkEnableOption "Toylet Notes server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.reading-desk;
      defaultText = lib.literalExpression "pkgs.reading-desk";
      description = "The Reading Desk package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Port to listen on.";
    };

    title = lib.mkOption {
      type = lib.types.str;
      default = "Toylet Notes";
      description = "Application title displayed in the frontend.";
    };

    domainName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Domain name for nginx virtual host. If set and nginx is enabled, configures HTTPS with ACME.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.domainName != null && config.services.nginx.enable) {
      services.nginx.virtualHosts.${cfg.domainName} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    })

    {
      systemd.services.toylet-note = {
      description = "Toylet Notes - Break's notes collection";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.escapeShellArgs [
          "${cfg.package}/bin/reading-desk"
          "--content-dir" "${notesPackage}"
          "--port" (toString cfg.port)
          "--title" cfg.title
          "--watch" "false"
        ];
        Restart = "on-failure";
        RestartSec = "5s";

        # Use systemd dynamic user
        DynamicUser = true;

        # Hardening
        CapabilityBoundingSet = [ "" ];
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  }
  ]);
}
