-- Plugin: echaya/neowiki.nvim
-- Installed via store.nvim

return {
  "echaya/neowiki.nvim",
  opts = {
    wiki_dirs = {
      -- neowiki.nvim supports both absolute and tilde-expanded paths
      {
        name = "Work",
        path = "~/Sync/work/wiki",
      },
      {
        name = "Personal",
        path = "~/Sync/personal/wiki",
      },
    },
  },
  keys = {
    {
      "<leader>ww",
      "<cmd>lua require('neowiki').open_wiki()<cr>",
      desc = "Open Wiki",
    },
    {
      "<leader>wW",
      "<cmd>lua require('neowiki').open_wiki_floating()<cr>",
      desc = "Open Wiki in Floating Window",
    },
    {
      "<leader>wT",
      "<cmd>lua require('neowiki').open_wiki_new_tab()<cr>",
      desc = "Open Wiki in Tab",
    },
  },
}

