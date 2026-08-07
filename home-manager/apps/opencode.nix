{ config, lib, pkgs, ... }:

let
  hasStylix = config ? lib && config.lib ? stylix && config.lib.stylix ? colors;
  baseConfig = builtins.fromJSON (builtins.readFile ../../opencode/config.json);

  colors = if hasStylix then config.lib.stylix.colors.withHashtag else {
    base00 = "#1a1b26";
    base01 = "#24283b";
    base02 = "#414868";
    base03 = "#565f89";
    base04 = "#c0caf5";
    base05 = "#c0caf5";
    base06 = "#d4dcf8";
    base07 = "#e9f1fc";
    base08 = "#f7768e";
    base09 = "#ff9e64";
    base0A = "#e0af68";
    base0B = "#9ece6a";
    base0C = "#7dcfff";
    base0D = "#7aa2f7";
    base0E = "#bb9af7";
    base0F = "#db4b4b";
  };
in
{
  xdg.configFile."opencode/agent" = {
    source = ../../opencode/agent;
    recursive = true;
  };

  xdg.configFile."opencode/skill" = {
    source = ../../opencode/skill;
    recursive = true;
  };

  xdg.configFile."opencode/config.json".text = builtins.toJSON baseConfig;

  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    theme = "stylix";
  };

  xdg.configFile."opencode/themes/stylix.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/theme.json";
    defs = {
      inherit (colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
    };
    theme = {
      primary = "base0D";
      secondary = "base09";
      accent = "base0E";
      error = "base08";
      warning = "base0A";
      success = "base0B";
      info = "base0C";
      text = "base05";
      textMuted = "base03";
      background = "base00";
      backgroundPanel = "base01";
      backgroundElement = "base02";
      border = "base02";
      borderActive = "base03";
      borderSubtle = "base01";
      diffAdded = "base0B";
      diffRemoved = "base08";
      diffContext = "base03";
      diffHunkHeader = "base03";
      diffHighlightAdded = "base0B";
      diffHighlightRemoved = "base08";
      diffAddedBg = "base01";
      diffRemovedBg = "base01";
      diffContextBg = "base01";
      diffLineNumber = "base03";
      diffAddedLineNumberBg = "base01";
      diffRemovedLineNumberBg = "base01";
      markdownText = "base05";
      markdownHeading = "base0D";
      markdownLink = "base09";
      markdownLinkText = "base08";
      markdownCode = "base0B";
      markdownBlockQuote = "base03";
      markdownEmph = "base0E";
      markdownStrong = "base0A";
      markdownHorizontalRule = "base03";
      markdownListItem = "base0D";
      markdownListEnumeration = "base0E";
      markdownImage = "base09";
      markdownImageText = "base08";
      markdownCodeBlock = "base05";
      syntaxComment = "base03";
      syntaxKeyword = "base0E";
      syntaxFunction = "base0D";
      syntaxVariable = "base08";
      syntaxString = "base0B";
      syntaxNumber = "base09";
      syntaxType = "base0A";
      syntaxOperator = "base05";
      syntaxPunctuation = "base04";
    };
  };
}
