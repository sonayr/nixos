{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    # =========================================================================
    # Globals (from lazy.lua / remaps.lua)
    # =========================================================================
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = false;
    };

    # =========================================================================
    # Options (from options.lua)
    # =========================================================================
    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;
      wrap = false;
      hlsearch = true; # hlsearch is true in remaps, but clear on <Esc>
      incsearch = true;
      termguicolors = true;
      showmode = false;
      clipboard = "unnamedplus";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      # listchars representation in nixvim is a bit specific; we might need to use string representation
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
    };

    # =========================================================================
    # Keymaps (from remaps.lua & opencode.lua)
    # =========================================================================
    keymaps = [
      { mode = "n"; key = "<leader>pv"; action = "<cmd>Oil<CR>"; }
      { mode = ["n" "t"]; key = "<C-h>"; action = "<C-\\><C-n><C-w>h"; options.desc = "Move focus to the left window"; }
      { mode = ["n" "t"]; key = "<C-l>"; action = "<C-\\><C-n><C-w>l"; options.desc = "Move focus to the right window"; }
      { mode = ["n" "t"]; key = "<C-j>"; action = "<C-\\><C-n><C-w>j"; options.desc = "Move focus to the lower window"; }
      { mode = ["n" "t"]; key = "<C-k>"; action = "<C-\\><C-n><C-w>k"; options.desc = "Move focus to the upper window"; }
      { mode = "i"; key = "jk"; action = "<Esc>"; }
      
      # Move text
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; }
      
      # Center pagedown/up
      { mode = "n"; key = "J"; action = "mzJ`z"; }
      { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
      
      # copy/paste buffer overrides
      { mode = "x"; key = "<leader>p"; action = "\"_dP"; }
      { mode = ["n" "v"]; key = "<leader>y"; action = "\"+y"; }
      { mode = "n"; key = "<leader>Y"; action = "\"+y"; }
      
      # tmux/format/source
      { mode = "n"; key = "<C-f>"; action = "<cmd>silent !tmux neww tmux-sessionizer<CR>"; }
      { mode = "n"; key = "<leader>fo"; action = "<cmd>lua vim.lsp.buf.format()<CR>"; }
      { mode = "n"; key = "<leader>so"; action = "<cmd>so<CR>"; options.desc = "Source current file"; }
      
      # Diagnostics
      { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; options.desc = "Go to previous [D]iagnostic message"; }
      { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; options.desc = "Go to next [D]iagnostic message"; }
      { mode = "n"; key = "<leader>em"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; options.desc = "Show diagnostic [E]rror messages"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>lua vim.diagnostic.setloclist()<CR>"; options.desc = "Open diagnostic [Q]uickfix list"; }
      
      # Clear search
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
      
      # Terminal
      { mode = "t"; key = "<Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }
      { mode = "n"; key = "<leader>ft"; action = ":split | terminal<CR>"; options.desc = "Open terminal in a split"; }

      # Opencode mappings
      { mode = "n"; key = "<leader>oA"; action = "<cmd>lua require('opencode').ask()<CR>"; options.desc = "Ask opencode"; }
      { mode = "n"; key = "<leader>oa"; action = "<cmd>lua require('opencode').ask('@cursor: ')<CR>"; options.desc = "Ask opencode about this"; }
      { mode = "v"; key = "<leader>oa"; action = "<cmd>lua require('opencode').ask('@selection: ')<CR>"; options.desc = "Ask opencode about selection"; }
      { mode = "n"; key = "<leader>ot"; action = "<cmd>lua require('opencode').toggle()<CR>"; options.desc = "Toggle embedded opencode"; }
      { mode = "n"; key = "<leader>on"; action = "<cmd>lua require('opencode').command('session_new')<CR>"; options.desc = "New session"; }
      { mode = "n"; key = "<leader>oy"; action = "<cmd>lua require('opencode').command('messages_copy')<CR>"; options.desc = "Copy last message"; }
      { mode = "n"; key = "<S-C-u>"; action = "<cmd>lua require('opencode').command('messages_half_page_up')<CR>"; options.desc = "Scroll messages up"; }
      { mode = "n"; key = "<S-C-d>"; action = "<cmd>lua require('opencode').command('messages_half_page_down')<CR>"; options.desc = "Scroll messages down"; }
      { mode = ["n" "v"]; key = "<leader>op"; action = "<cmd>lua require('opencode').select_prompt()<CR>"; options.desc = "Select prompt"; }
      { mode = "n"; key = "<leader>oe"; action = "<cmd>lua require('opencode').prompt('Explain @cursor and its context')<CR>"; options.desc = "Explain code near cursor"; }
    ];

    # =========================================================================
    # Native Plugins (Replaces lazy.nvim definitions)
    # =========================================================================
    plugins = {
      lualine.enable = true;
      telescope.enable = true;
      oil.enable = true;
      harpoon.enable = true;
      fugitive.enable = true;
      undotree.enable = true;
      
      # Treesitter
      treesitter = {
        enable = true;
      };

      # Completion (Replaces nvim-cmp and luasnip setup from lsp.lua)
      luasnip.enable = true;
      cmp = {
        enable = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          mapping = {
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<C-Space>" = "cmp.mapping.complete()";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      # LSP Integration (Replaces Mason and lspconfig from lsp.lua)
      lsp = {
        enable = true;
        keymaps = {
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
          lspBuf = {
            "gd" = "definition";
            "gr" = "references";
            "gD" = "declaration";
            "gT" = "type_definition";
            "K" = "hover";
            "<space>cr" = "rename";
            "<space>ca" = "code_action";
          };
        };
        servers = {
          nil_ls.enable = true; # Nix
          # NOTE: apex_ls requires custom JAR setup. See extraConfigLua below.
        };
      };
    };

    # =========================================================================
    # Custom/Unpackaged Plugins & Lua Configurations
    # =========================================================================
    
    # We include opencode and snacks here from nixpkgs. 
    # For salesforce.nvim we fetch it directly from github.
    extraPlugins = with pkgs.vimPlugins; [
      opencode-nvim
      snacks-nvim
      #(pkgs.vimUtils.buildVimPlugin {
        # name = "salesforce-nvim";
        # src = pkgs.fetchFromGitHub {
      #     owner = "jonathanmorris180";
      #     repo = "salesforce.nvim";
      #     rev = "d9646e731f980513ebe95b426830cf9b1ca609cc"; # Adjust to latest if needed
      #     hash = "sha256-a8KKCIh1DX1pFxIuelk3nCj/bRfe/+KfgIp6wu4jERc="; # Fake hash, will need update
      #   };
      # })
    ];

    extraConfigLua = ''
      -- Ensure listchars is configured correctly (NixVim handles tables slightly differently)
      vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

      -- ==========================================
      -- Salesforce Filetypes & LSP setup
      -- ==========================================
      vim.filetype.add({
          extension = { cls = 'apex', trigger = 'apex', apex = 'apex' },
          filename = { ['.cls'] = 'apex', ['.apex'] = 'apex', ['.trigger'] = 'apex' }
      })

      -- We manually configure apex_ls here because we have a custom JAR path requirement
      local lspconfig = require('lspconfig')
      vim.lsp.config('apex_ls', {
          apex_enable_semantic_errors = false,
          apex_enable_completion_statistics = false,
          apex_jar_path = vim.env.HOME .. '/apex-jorje-lsp.jar',
          filetypes = { 'apex' },
      })
      vim.lsp.enable('apex_ls')

      -- Telescope builtin LSP keymap (which wasn't directly available in nixvim lspBuf abstraction)
      vim.keymap.set("n", "<space>wd", require('telescope.builtin').lsp_document_symbols, { buffer = 0 })

      -- ==========================================
      -- Salesforce.nvim setup
      -- ==========================================
      require('salesforce').setup({
          debug = { to_file = false, to_command_line = false },
          popup = {
              width = 100, height = 20,
              borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          file_manager = { ignore_conflicts = true },
          org_manager = { default_org_indicator = "󰄬" },
      })

      -- ==========================================
      -- Opencode setup
      -- ==========================================
      require('snacks').setup({ input = { enabled = true } })
    '';
  };
}
