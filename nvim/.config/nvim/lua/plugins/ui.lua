return {
  -- colorscheme
  {
    "dgox16/oldworld.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("oldworld")
    end,
  },
  { "topazape/oldtale.nvim", lazy = true },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          { "diagnostics" },
          { "filename", path = 1 },
        },
        lualine_x = {
          {
            function()
              return vim.diagnostic.status()
            end,
            cond = function()
              return vim.diagnostic.status() ~= ""
            end,
          },
          {
            function()
              return vim.ui.progress_status()
            end,
            cond = function()
              return vim.ui.progress_status() ~= ""
            end,
          },
          { "diff" },
          { "filetype", icon_only = true },
        },
        lualine_y = { "location" },
        lualine_z = {},
      },
    },
  },

  -- icons
  {
    "echasnovski/mini.icons",
    lazy = true,
    init = function()
      -- override nvim-web-devicons with mini.icons
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
    opts = {},
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>n", group = "notes" },
        { "<leader>q", group = "quit" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  -- snacks notifier + other UI utilities
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      scope = { enabled = true },
      words = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = "│ ╲ ││\n││╲╲││\n││ ╲ │",
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    },
  },
}
