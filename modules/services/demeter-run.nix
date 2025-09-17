{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.demeter-run;
in
{
  options.services.demeter-run = with lib; {
    enable = mkEnableOption "Demeter run tunnel";

    package = mkOption {
      type = types.package;
      description = "The demeter-run-cli package.";
      default = pkgs.demeter-run-cli;
    };

    user = mkOption {
      type = types.str;
      default = "demeter-run";
      description = "User account under which demeter-run is run";
    };

    group = mkOption {
      type = types.str;
      default = "demeter-run";
      description = "Group account under which demeter-run is run";
    };

    socket = mkOption {
      type = types.str;
      default = "${cfg.socketDir}/node.socket";
    };

    socketDir = mkOption {
      type = types.str;
      default = "/run/demeter-run";
    };

    instance = mkOption {
      type = types.str;
    };

    configFile = mkOption {
      type = types.path;
      description = ''
        Config file for demeter setup (contain secrets, use agenix or sops)
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.demeter-run-cli ];
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = { };
    systemd.tmpfiles.rules = [
      "d '${cfg.socketDir}' - ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.demeter-run = {
      enable = true;
      path = [ cfg.package ];
      wants = [
        "network-online.target"
      ];

      script = ''
        rm -f ${cfg.socket}
        ${cfg.package}/bin/dmtrctl ports tunnel --socket ${cfg.socket} ${cfg.instance}
      '';

      preStart = ''
        ${pkgs.coreutils}/bin/install -m 0700 -g ${cfg.group} -o ${cfg.user} ${cfg.configFile} ${cfg.socketDir}/config.toml
      '';

      # Prevent secret leaking
      postStop = ''
        rm ${cfg.socketDir}/config.toml
      '';

      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = 10;
        Group = cfg.group;
        User = cfg.user;
        Environment = [
          "DMTR_ROOT_DIR=${cfg.socketDir}"
        ];
        UMask = "006";
      };
    };
  };
}
