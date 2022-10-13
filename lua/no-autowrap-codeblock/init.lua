local AUGROUP_NAME = "NoAutowrapCodeblock"

local query = vim.treesitter.parse_query(
  "markdown",
  [[
  (fenced_code_block) @code_block
  ]]
)

local get_root = function(bufnr)
  local language_tree = vim.treesitter.get_parser(bufnr, "markdown")
  local syntax_tree = language_tree:parse()
  return syntax_tree[1]:root()
end

local get_code_block_range = function(node)
  local range = { vim.treesitter.get_node_range(node):range() }
  local row_start = range[1] - 1 -- line before block
  local row_end = range[3] + 2 -- line after block
  return row_start, row_end
end

local get_cursor_line = function(bufnr)
  local winnr = vim.fn.bufwinnr(bufnr)
  return vim.fn.getcurpos(winnr)[2]
end

local is_cursor_inside_code_block = function(bufnr)
  bufnr = bufnr or vim.fn.bufnr()
  if vim.bo[bufnr].filetype ~= "markdown" then
    vim.notify("Can only be used in markdown")
    return
  end

  local root = get_root(bufnr)

  local cursor_line = get_cursor_line(bufnr)

  for _, node in query:iter_matches(root, bufnr, cursor_line - 1, cursor_line + 2) do
    local row_start, row_end = get_code_block_range(node)

    -- Check if cursor inside code block node
    if cursor_line > row_start and cursor_line < row_end then
      return true
    end
  end
  return false
end

local defaults

local reset_default_options = function()
  if not defaults then
    return
  end
  vim.cmd("setlocal formatoptions=" .. defaults)
  defaults = nil
end

local set_code_block_options = function()
  vim.cmd("setlocal formatoptions-=a")
end

local run = function()
  defaults = defaults or vim.o.formatoptions

  if is_cursor_inside_code_block() then
    set_code_block_options()
  else
    reset_default_options()
  end
end

local is_enabled = function()
  return group_id ~= nil
end

local create_autocmds = function()
  local group_id = vim.api.nvim_create_augroup(AUGROUP_NAME, { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { pattern = "*.md", callback = run, group = group_id })
end

local delete_autocmds = function()
  vim.api.nvim_del_augroup_by_name(AUGROUP_NAME)
end

local enable = function()
  if is_enabled() then
    vim.notify("Already enabled.")
    return
  end
  create_autocmds()
end

local disable = function()
  if not is_enabled() then
    vim.notify("Already disabled.")
    return
  end
  delete_autocmds()
  reset_default_options()
end

return {
  enable = enable,
  disable = disable,
}
