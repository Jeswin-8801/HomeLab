return {
  {
    -- https://www.lazyvim.org/plugins/formatting
    -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/formatting.lua
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    opts = function()
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          rust = { "ast_grep" },
          json = { "prettier" },
          jsonc = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          ["markdown.mdx"] = { "prettier" },
          graphql = { "prettier" },
          handlebars = { "prettier" },
        },
        -- LazyVim will merge the options you set here with builtin formatters.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          dprint = {
            condition = function(_, ctx)
              return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
            end,
          },
        },
      }
      return opts
    end,
  },
}
