{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.telescope.extensions.project;
  helpers = import ../helpers.nix {inherit lib;};
in {
  options.plugins.telescope.extensions.project = {
    enable = mkEnableOption "Enable project extension for telescope";

    package = helpers.mkPackageOption "telescope extension project" pkgs.vimPlugins.telescope-project-nvim;

    baseDirs = mkOption {
      type = with types;
        nullOr (listOf (submodule {
          options = {
            path = mkOption {
              type = str;
              description = "Path to a project base directory configuration";
            };
            maxDepth = mkOption {
              type = nullOr int;
              description = "Max depth to find projects";
              default = null;
            };
          };
        }));
      description = "Array of project base directory configurations";
      default = null;
    };
    hiddenFiles = mkOption {
      type = with types; nullOr bool;
      description = "Show hidden files in selected project";
      default = null;
    };
    theme = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    orderBy = mkOption {
      type = with types; nullOr str;
      description = "Order projects by `asc`, `desc`, `recent`";
      default = null;
    };
    syncWithNvimTree = mkOption {
      type = with types; nullOr bool;
      description = "Sync projects with nvim tree plugin";
      default = null;
    };
    searchBy = mkOption {
      type = with types; nullOr str;
      description = "Telescope finder search by field (title/path)";
      default = null;
    };
    onProjectSelected = mkOption {
      type = with types; nullOr str;
      description = "Custom handler when project is selected";
      default = null;
    };
  };

  config = let
    configuration = {
      base_dirs = cfg.baseDirs;
      hidden_files = cfg.hiddenFiles;
      inherit (cfg) theme;
      order_by = cfg.orderBy;
      search_by = cfg.searchBy;
      sync_with_nvim_tree = cfg.syncWithNvimTree;
      on_project_selected =
        helpers.ifNonNull' cfg.onProjectSelected
        (
          helpers.mkRaw cfg.onProjectSelected
        );
    };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];

      plugins.telescope.enabledExtensions = ["project"];
      plugins.telescope.extensionConfig."project" = configuration;
    };
}
