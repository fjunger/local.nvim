local M = {}

function M.load()

  vim.api.nvim_create_autocmd('FileType', {
    pattern = M.options.filetype,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local winnr = vim.api.nvim_get_current_win()
      local tabnr = vim.api.nvim_get_current_tabpage()
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local cwd = vim.fn.getcwd(winnr, tabnr)
      local begin = ""
      local files = {}
      local root = cwd

      if #filename > 0 then
        begin = filename
      else
        begin = vim.fs.joinpath(cwd, '.')
      end

      for _, mark in ipairs(M.options.root) do
        local path = vim.fs.root(begin, mark)
        if path ~= nil and #path > 0 then
          root = path
          break
        end
      end

      for dir in vim.fs.parents(begin) do
        for _, file in ipairs(M.options.file) do
          local path = vim.fs.joinpath(dir, file)
          if vim.fn.filereadable(path) == 1 then
            table.insert(files, 1, path)
          end
        end

        if dir == root then
          break
        end
      end

      for _, file in ipairs(files) do
        vim.cmd.source(file)
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
    filetype = 'cpp',
    autoload = true,
    verbose = false,
  }, options or {})
  vim.g.did_setup_local = true
end

return M
