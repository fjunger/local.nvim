local M = require('local')

vim.api.nvim_create_user_command("Local", M.load, {
  desc = "Load local.nvim files for the current buffer",
})

if M.options.autoload then
  M.load()
end
