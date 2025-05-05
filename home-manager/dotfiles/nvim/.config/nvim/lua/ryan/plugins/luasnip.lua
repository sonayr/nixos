return {
    'L3MON4D3/LuaSnip',
    lazy = false,
    config = function ()
        local ls = require "luasnip"
        ls.config.set_config {
            history = false,
            updateevents = 'TextChanged,TextChangedI',
            enable_autosnippets = false
        }
        
        vim.keymap.set({"i","s"}, "<c-k>", function ()
            if ls.expand_or_jumpable() then
                ls.expand_or_jump()
            end
        end, {silent = true})
    end
}

