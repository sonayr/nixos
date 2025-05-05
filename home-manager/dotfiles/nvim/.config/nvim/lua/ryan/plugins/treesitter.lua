return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query","apex","javascript","typescript" },
    config = function () 
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
          auto_install = true,
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })
    end,
}
