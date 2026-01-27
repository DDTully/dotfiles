-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.relativenumber = true
vim.g.snacks_animate = false
vim.opt.swapfile = false

vim.cmd([[
  au BufRead,BufNewFile *.tmpl set filetype=html
]])
