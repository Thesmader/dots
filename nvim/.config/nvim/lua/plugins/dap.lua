--- Strip comments and trailing commas from JSONC (VSCode launch.json format)
local function decode_jsonc(str)
  -- remove single-line comments
  str = str:gsub("//[^\n]*", "")
  -- remove multi-line comments
  str = str:gsub("/%*.-%*/", "")
  -- remove trailing commas before } or ]
  str = str:gsub(",%s*([%]%}])", "%1")
  return vim.json.decode(str)
end

--- Load .vscode/launch.json with JSONC support and type remapping
local function load_launchjs(dap)
  local path = vim.fn.getcwd() .. "/.vscode/launch.json"
  local f = io.open(path, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()

  local ok, data = pcall(decode_jsonc, content)
  if not ok or not data or not data.configurations then
    vim.notify("Failed to parse launch.json: " .. tostring(data), vim.log.levels.WARN)
    return
  end

  local type_map = {
    ["pwa-node"] = { "javascript", "typescript" },
    ["node"] = { "javascript", "typescript" },
    ["pwa-chrome"] = { "javascript", "typescript" },
    ["debugpy"] = { "python" },
  }

  for _, cfg in ipairs(data.configurations) do
    local fts = type_map[cfg.type] or { cfg.type }
    -- translate vscode dart/flutter configs for nvim-dap
    if cfg.type == "dart" then
      local args = cfg.args and vim.deepcopy(cfg.args) or {}
      if cfg.program then
        table.insert(args, 1, "--target=" .. cfg.program)
      end
      cfg = vim.tbl_extend("force", cfg, {
        args = args,
        program = nil,
      })
    end
    for _, ft in ipairs(fts) do
      dap.configurations[ft] = dap.configurations[ft] or {}
      table.insert(dap.configurations[ft], cfg)
    end
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
      "igorlfs/nvim-dap-view",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      {
        "<leader>dt",
        function()
          require("dap").terminate({ hierarchy = true, all = true })
        end,
        desc = "Terminate (all sessions)",
      },
      -- hover inspect
      { "<leader>dh", function() require("dap.ui.widgets").hover() end, mode = { "n", "v" }, desc = "DAP hover" },
      -- dap-view
      { "<leader>dv", "<cmd>DapViewToggle<cr>", desc = "Toggle DAP view" },
    },
    config = function()
      local dap = require("dap")

      -- disable built-in launch.json provider (doesn't handle JSONC)
      dap.providers.configs["dap.launch.json"] = nil

      -- load project-local launch.json (JSONC-safe)
      load_launchjs(dap)

      -- register dart adapter if flutter-tools hasn't yet (fvm-aware)
      if not dap.adapters.dart then
        local flutter_bin = vim.fn.resolve(vim.fn.expand("~/fvm/default/bin/flutter"))
        dap.adapters.dart = {
          type = "executable",
          command = flutter_bin,
          args = { "debug_adapter" },
        }
      end

      -- reload launch.json when changing directories
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function() load_launchjs(dap) end,
      })

      -- close dap-view on session end
      vim.api.nvim_create_autocmd("User", {
        pattern = "DapTerminate",
        callback = function()
          vim.defer_fn(function()
            pcall(vim.cmd, "DapViewClose")
          end, 100)
        end,
      })
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      ensure_installed = { "js" },
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },

  {
    "igorlfs/nvim-dap-view",
    opts = {},
  },

  -- flutter/dart
  {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      local fvm_flutter = vim.fn.resolve(vim.fn.expand("~/fvm/default/bin/flutter"))
      return {
        flutter_path = fvm_flutter,
        debugger = {
          enabled = true,
          run_via_dap = true,
          register_configurations = function(_)
            -- append launch.json configs after flutter-tools' defaults
            load_launchjs(require("dap"))
          end,
        },
        lsp = {
          capabilities = capabilities,
          color = { enabled = true },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            analysisExcludedFolders = {
              vim.fn.expand("$HOME/.pub-cache"),
            },
          },
        },
      }
    end,
  },
}
