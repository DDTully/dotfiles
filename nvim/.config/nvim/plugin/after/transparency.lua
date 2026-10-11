local function transparent()
  local groups = {
    "Normal",
    "NormalFloat",
    "FloatBorder",
    "Pmenu",
    "Terminal",
    "EndOfBuffer",
    "FoldColumn",
    "Folded",
    "SignColumn",
    "NormalNC",
    "WhichKeyFloat",
    "TelescopeBorder",
    "TelescopeNormal",
    "TelescopePromptBorder",
    "TelescopePromptTitle",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeVertSplit",
    "NeoTreeWinSeparator",
    "NeoTreeEndOfBuffer",
    "NvimTreeNormal",
    "NvimTreeVertSplit",
    "NvimTreeEndOfBuffer",
    "NotifyINFOBody",
    "NotifyERRORBody",
    "NotifyWARNBody",
    "NotifyTRACEBody",
    "NotifyDEBUGBody",
    "NotifyINFOTitle",
    "NotifyERRORTitle",
    "NotifyWARNTitle",
    "NotifyTRACETitle",
    "NotifyDEBUGTitle",
    "NotifyINFOBorder",
    "NotifyERRORBorder",
    "NotifyWARNBorder",
    "NotifyTRACEBorder",
    "NotifyDEBUGBorder",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

transparent()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("dotfiles_transparency", { clear = true }),
  callback = transparent,
})
