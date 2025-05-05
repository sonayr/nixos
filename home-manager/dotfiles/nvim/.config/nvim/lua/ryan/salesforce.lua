-- vim.keymap.set('n', '<leader>ga', ':silent !sf apex generate class -d  fh 
-- vim.keymap.set('n', '<leader>ga', ':silent !sf apex generate class -d  fh 
defaultBrowser = 'firefox';
vim.keymap.set('n', '<leader>sfo', ':SFOpen<CR>',{desc = 'Open current file in default org'})
vim.keymap.set('n', '<leader>sfd', ':SalesforcePushToOrg<CR>',{desc = 'Deploy current file to default org'})
vim.keymap.set('n', '<leader>sfp', ':SalesforceRetrieveFromOrg<CR>',{desc = 'Retrieve current file from default org'})
vim.keymap.set('n', '<leader>sfa', ':SalesforceCreateApex<CR>',{desc = 'Create a new apex class'})
vim.keymap.set('n', '<leader>sfl', ':SalesforceCreateLightningComponent<CR>',{desc = 'Create a new Lightning Component'})
vim.keymap.set('n', '<leader>sfrt', ':SalesforceExecuteCurrentClass<CR>',{desc = 'Run current test class'})
vim.keymap.set('n', '<leader>sfrm', ':SalesforceExecuteCurrentMethod<CR>',{desc = 'Run current test method'})
vim.keymap.set('n', '<leader>sfrf', ':SalesforceExecuteFile<CR>',{desc = 'Run current anonymous apex'})
vim.keymap.set('n', '<leader>sfso', ':SalesforceSetDefaultOrg<CR>',{desc = 'Set default Salesforce org'})


local stdout = function(err,data)
   if err then
       print(err)
   elseif data then
       print(data)
   end
end
--
local mapOutput = {stdout = stdout, stderr = stdout}
vim.api.nvim_create_user_command('SFOpen',
    function ()
       local dir = vim.fn.expand('%')
       vim.system({'sf','org','open','--browser',defaultBrowser,'--source-file',dir,},mapOutput)
    end,
    {}
)
vim.api.nvim_create_user_command('SFDeleteFile',
    function ()
       local dir = vim.fn.expand('%')
       if string.find(dir,'/flows/') then
          local deleteFlows = function ()
              vim.system({'deleteFlows.sh',dir},mapOutput)
          end
          -- This is a flow, ensure it's deactivated and then delete all versions
          print('Flow found, deactivating then deleting')
          vim.system({'deactivateFlows.sh',dir},mapOutput,deleteFlows)
       else 
           vim.system({'sf','project','delete','source','-p',dir,'-r'},mapOutput)
       end
       print(dir)
    end,
    {}
)
--
-- vim.api.nvim_create_user_command('SFDeploy',
--     function ()
--         local dir = vim.fn.expand('%')
--         vim.system({'sf','project','deploy','start','-d',dir,'-c'},mapOutput)
--     end,
--     {}
-- )
-- vim.api.nvim_create_user_command('SFTest',
--     function ()
--         local fileName = vim.fn.expand('%:t:r')
--         vim.system({'sf','apex','run','test','-w','50','-l','RunSpecifiedTests','-t',fileName},mapOutput)
--     end,
--     {}
-- )
-- vim.api.nvim_create_user_command('SFRetrieve',
--     function ()
--         local dir = vim.fn.expand('%')
--         vim.system({'sf','project','retrieve','start','-d',dir,'-c'},mapOutput)
--     end,
--     {}
-- )
--
-- vim.api.nvim_create_user_command('SFLWCNew',
--     function ()
--         vim.system({'read','fileName'})
--         vim.cmd('!read fileName')
--         vim.cmd('echo $fileName')
--     end,
--     {}
-- )
--
-- vim.api.nvim_create_user_command('SFApexNew',
--     function ()
--         local classPath = 'force-app/main/default/classes/'
--         vim.ui.input({prompt = 'Class name: '},function (input)
--             vim.system({'sf','apex','generate','class','-d',classPath ,'-n',input},mapOutput):wait()
--             vim.cmd('e ' .. classPath .. input .. '.cls')
--         end
--         )
--     end,
--     {}
-- )

