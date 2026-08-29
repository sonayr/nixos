## Question

What shell script and Home Manager configuration structure will best enable `wofi` to dynamically list scripts from a dedicated directory and launch them inside an interactive terminal window?

## Resolution

- **Directory Layout**: Scripts stored in `nixos/scripts/`.
- **Launcher**: A bash script using `find` / `basename` to populate `wofi --dmenu`, piping the selected script path to `ghostty -e`.
- **Home Manager Module**: Declaratively provisions the scripts and menu launcher via Home Manager.
