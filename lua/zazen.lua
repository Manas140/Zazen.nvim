local cmd = vim.cmd
local api = vim.api
local o = vim.o
local opt = vim.opt

local M = {}
local on = false
local conf = {
  gap = 0.2,
  border = "rounded",
  num = true,
}

M.setup = function(opts)
  for a, b in pairs(opts or {}) do
    conf[a] = b
  end
  api.nvim_create_user_command("Zazen", function()
    M.zen()
  end, {})
end

M.zen = function ()
  on = not on

  if on then
    -- Get previous buffer to open in new window 
    local buffer = api.nvim_get_current_buf()

    -- A new empty buffer to fill background
    cmd ":tabnew"
    M.scr = api.nvim_get_current_buf()

    -- Set options
    o.showmode = true
    o.relativenumber = false
    o.number = false
    o.laststatus = 0

    local a = 0
    if conf.tabline then a = 2 end
    o.showtabline = a

    -- Create window
    local h, w = o.lines, o.columns
    M.win = api.nvim_open_win(buffer, true, {
      relative = "editor",
      zindex = 5,
      width = w - math.floor(w * conf.gap),
      height = h - 1,
      col = math.floor(w * conf.gap/2),
      row = 0,
      border = conf.border,
      style = "minimal",
    })

    -- Floating Window Options
    opt.signcolumn = 'yes:1'
    opt.number = conf.num
    opt.cul = true
    opt.relativenumber = false

    -- Color
    api.nvim_win_set_option(M.win, "winhl", "NormalFloat:Normal,FloatBorder:Comment")

    -- AutoCommands for resize
    api.nvim_create_autocmd("VimResized", {
      callback = function ()
        h, w = o.lines, o.columns

        local cfg = api.nvim_win_get_config(M.win)
        local row, col, height, width = cfg["row"][false], cfg["col"][false], cfg["height"], cfg["width"]

        col = math.floor(w * conf.gap/2)
        row = 0
        width = w - math.floor(w * conf.gap)
        height = h

        cfg["row"][false], cfg["col"][false], cfg["height"], cfg["width"] = row, col, height, width

        api.nvim_win_set_config(M.win, cfg)
        opt.signcolumn = 'yes:1'
        opt.number = conf.num
        opt.cul = true
        opt.relativenumber = false
      end
    })
  else
    -- Reset all options
    o.number = true
    o.showtabline = 2
    o.laststatus = 2

    if api.nvim_win_is_valid(M.win) then api.nvim_win_close(M.win, {force=true}) end
    if api.nvim_buf_is_valid(M.scr) then api.nvim_buf_delete(M.scr, {force=true}) end
  end
end

return {
  setup = M.setup
}
