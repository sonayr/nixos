{ lib, pkgs, ... }:
{
  # home.packages = with pkgs; [
  #   obsidian
  # ];
  programs = {
    obsidian = {
      enable = true;
      defaultSettings = {
      app = {
        vimMode = true;
      };
      appearance = {
        theme = "obsidian";
      };
      hotkeys = {
        "file-explorer:move-file" = {
          modifiers = [
            "Mod"
            "Shift"
          ];
          key = "D";
        };
        "file-explorer:new-folder" = {
          modifiers = [
            "Mod"
          ];
          key = "D";
        };
        "editor:delete-paragraph" = [ ];
      };
      };
    };
  };
}
