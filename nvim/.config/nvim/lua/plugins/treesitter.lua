local parsers = {
  "astro",
  "bash",
  "css",
  "dart",
  "diff",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "jsonc",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "regex",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = parsers,
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local map = vim.keymap.set

      -- select
      local selects = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }
      for key, query in pairs(selects) do
        map({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      -- move
      local moves = {
        ["]f"] = { "goto_next_start", "@function.outer" },
        ["]c"] = { "goto_next_start", "@class.outer" },
        ["]a"] = { "goto_next_start", "@parameter.inner" },
        ["]F"] = { "goto_next_end", "@function.outer" },
        ["]C"] = { "goto_next_end", "@class.outer" },
        ["[f"] = { "goto_previous_start", "@function.outer" },
        ["[c"] = { "goto_previous_start", "@class.outer" },
        ["[a"] = { "goto_previous_start", "@parameter.inner" },
        ["[F"] = { "goto_previous_end", "@function.outer" },
        ["[C"] = { "goto_previous_end", "@class.outer" },
      }
      for key, args in pairs(moves) do
        map({ "n", "x", "o" }, key, function()
          move[args[1]](args[2], "textobjects")
        end, { desc = args[1] .. " " .. args[2] })
      end

      -- swap
      map("n", "<leader>a", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap param next" })
      map("n", "<leader>A", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap param prev" })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
