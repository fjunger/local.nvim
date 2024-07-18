local M = {}

function M.load()
  local home = vim.uv.os_homedir()
  local dir = vim.uv.cwd()
  local sources = {}
  local next = dir
  local root_checkpoint = false

  repeat
    -- check for source files
    for _, file in pairs(M.options.file) do
      local target = vim.fs.joinpath(next, file)
      if vim.uv.fs_stat(target) then
        table.insert(sources, 1, target)
      end
    end

    -- check root markers
    for _, root in pairs(M.options.root) do
      if vim.uv.fs_stat(vim.fs.joinpath(next, root)) then
        root_checkpoint = true
        break
      end
    end

    dir = next next = vim.uv.fs_realpath(vim.fs.joinpath(next, '..'))
  until (dir <= home) or root_checkpoint

  for _, source in pairs(sources) do
    if M.options.verbose then
      vim.notify("Local: " .. source)
    end
    vim.cmd.source(source)
  end
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
    verbose = true,
  }, options or {})
  vim.g.did_setup_local = true
end

return M
