return {
    'neovim/nvim-lspconfig',
    dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            -- "j-hui/fidget.nvim",
    },
    config = function ()

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({select = true}),
                ['<C-Space>'] = cmp.mapping.complete()
            }),
            sources = cmp.config.sources(
            {
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
                { name = 'nivm_lua' },
            }, 
            {
                { name = 'buffer' },
            })
        })

        -- lsp.on_attach(function(client, bufnr)
        --     -- see :help lsp-zero-keybindings
        --     -- to learn the available actions
        --     lsp.default_keymaps({
        --         buffer = bufnr,
        --         preserve_mappings = false
        --     })
        -- end)
        require('mason').setup({})
        -- setup Salesforce lsp
        vim.filetype.add({
            extension = {
                cls = 'apex',
                trigger = 'apex',
                apex = 'apex'
            },
            filename = {
                ['.cls'] = 'apex',
                ['.apex'] = 'apex',
                ['.trigger'] = 'apex'
            }
        })

        -- local lspconfig = require('mason-lspconfig')
        local lspconfig = require'lspconfig'

        lspconfig.apex_ls.setup {
            apex_enable_semantic_errors = false,
            apex_enable_completion_statistics = false,
            apex_jar_path = vim.env.HOME .. '/apex-jorje-lsp.jar',
            filetypes = { 'apex' },
            root_dir = lspconfig.util.root_pattern('sfdx-project.json'),

            on_attach = on_attach,
            capabilities = capabilities,
        }
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local bufnr = args.buf
              local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

              local builtin = require "telescope.builtin"

              vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 ,desc = 'Go to Symbol Defintion'})
              vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = 0,desc = 'Symbol References' })
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
              vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
              vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

              vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
              vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })
              vim.keymap.set("n", "<space>wd", builtin.lsp_document_symbols, { buffer = 0 })

              local filetype = vim.bo[bufnr].filetype

              -- Override server capabilities
            end,
          })
        require('mason-lspconfig').setup({
            handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup({})
                end,
            },
        })
    end
}
