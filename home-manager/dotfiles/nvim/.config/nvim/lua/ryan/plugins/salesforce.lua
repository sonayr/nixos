return {
    "jonathanmorris180/salesforce.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require('salesforce').setup({
            debug = {
                to_file = false, -- Can also be toggled with :SalesforceToggleLogFileDebug
                to_command_line = false, -- Can also be toggled with :SalesforceToggleCommandLineDebug
            },
            popup = {
                -- The width of the popup window.
                width = 100,
                -- The height of the popup window.
                height = 20,
                -- The border characters to use for the popup window
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            },
            file_manager = {
                ignore_conflicts = true, -- ignores conflicts on "sf project retrieve/deploy"
            },
            org_manager = {
                default_org_indicator = "󰄬",
            },
        })
    end
}
