local M = {}

function M.load()
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup("Local", { clear = true }),
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()

      if (not vim.bo[bufnr].buflisted) or #vim.bo[bufnr].buftype > 0 then
        return
      end

      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local bufdir = vim.fs.dirname(bufname)
      local rootdir = vim.fs.root(bufdir, M.options.root) or bufdir

      local matches = vim.fs.find(M.options.file, {
        path = rootdir,
        stop = bufname,
        upward = false,
        type = 'file',
        limit = math.huge,
      })

      for _, file in ipairs(matches) do
        if M.options.verbose then
          vim.notify("local.nvim: trying to source " .. file, vim.log.levels.DEBUG)
        end
        local status, error = pcall(vim.cmd.source, file)
        if not pcall(vim.cmd.source, file) then
          vim.notify("local.nvim: failed to source " .. file .. ': ' .. error, vim.log.levels.ERROR)
        end
      end
    end
  })
end

---@class SetupOptions
---@field root? table<string> default = { '.local.lua', '.local.vim' }. Specify the file names to source
---@field file? table<string> default = { '.local.lua', '.local.vim' }. Specify the file names to source
---@field autoload? boolean default = true. Autoload the 'files' on startup
---@field verbose? boolean default = false. Be verbose.

---@param options? SetupOptions
function M.setup(options)
  M.options = vim.tbl_extend('force', {
    root = { '.git' },
    file = { '.local.lua', '.local.vim' },
    autoload = true,
    verbose = false,
  }, options or {})
  vim.g.did_setup_local = true
end

return M
