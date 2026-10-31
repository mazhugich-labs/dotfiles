local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        styles = { italic = false, transparency = false },
      })
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  {
    "stevearc/oil.nvim",
    opts = { view_options = { show_hidden = true } },
  },
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = { picker = { enabled = true } },
    keys = {
      { "<leader>f", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>s", function() Snacks.picker.grep() end, desc = "Search text" },
      { "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
  },
  { "lewis6991/gitsigns.nvim", event = "BufReadPre", opts = {} },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
})

