local M = require('local')

vim.api.nvim_create_user_command("Local", M.load, {})

if M.options.autoload then
  M.load()
end
