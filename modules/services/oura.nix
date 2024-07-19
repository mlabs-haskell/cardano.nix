{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.oura;
  settingsFormat = pkgs.formats.toml {};
in {
  options = {
    services.oura = {
      enable = lib.mkEnableOption "oura";

      package = lib.mkPackageOption pkgs "oura" {};

      stateDir = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.baseWorkDir}oura";
      };

      user = lib.mkOption {
        description = "User to run oura service as";
        type = lib.types.str;
        default = "root";
      };

      group = lib.mkOption {
        description = "Group to run oura service as";
        type = lib.types.str;
        default = "root";
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
          options = {};
        };
        default = {};
        description = ''
          Freeform attrset that generates the TOML configuration file used by Oura.
        '';
      };
      baseWorkDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/";
        internal = true;
      };
      configFile = lib.mkOption {
        type = lib.types.path;
        default = settingsFormat.generate "oura-settings.toml" cfg.settings;
        internal = true;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.oura = lib.mkIf (cfg.user == "oura") {
      isSystemUser = true;
      inherit (cfg) group;
      home = cfg.stateDir;
    };
    users.groups.oura = lib.mkIf (cfg.group == "oura") {};

    systemd.services.oura = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/oura daemon --config ${cfg.configFile}";
        Group = cfg.group;
        User = cfg.user;
        StateDirectory = lib.removePrefix cfg.baseWorkDir cfg.stateDir;
        WorkingDirectory = cfg.stateDir;
      };
    };
  };
}
