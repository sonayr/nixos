return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function ()
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>en', function ()
            builtin.find_files({
                cwd = vim.fn.stdpath("config"),
                follow  = true,
                hidden = false,
            })
        end, {desc = 'Edit neovim config'})

        require('telescope').setup{
            defaults = {
                path_display={"truncate"} 
            },
            pickers = {
                find_files = {
                    hidden = true
                }
            }
        }
    end
}
