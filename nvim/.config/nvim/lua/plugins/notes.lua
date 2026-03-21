return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {},
  },

  -- simple note-taking commands
  {
    dir = ".", -- virtual plugin for note keymaps
    name = "notes",
    keys = {
      {
        "<leader>nn",
        function()
          local notes_dir = vim.fn.expand("~/notes")
          vim.fn.mkdir(notes_dir, "p")
          local name = vim.fn.input("Note: ", "")
          if name == "" then
            return
          end
          if not name:match("%.md$") then
            name = name .. ".md"
          end
          vim.cmd.edit(notes_dir .. "/" .. name)
        end,
        desc = "New/open note",
      },
      {
        "<leader>nf",
        function()
          require("fzf-lua").files({ cwd = vim.fn.expand("~/notes") })
        end,
        desc = "Find notes",
      },
      {
        "<leader>ng",
        function()
          require("fzf-lua").live_grep({ cwd = vim.fn.expand("~/notes") })
        end,
        desc = "Grep notes",
      },
    },
  },
}
