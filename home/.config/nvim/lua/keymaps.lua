local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Files" })
map("n", "<leader>g", function() require("neogit").open() end, { desc = "Git" })

