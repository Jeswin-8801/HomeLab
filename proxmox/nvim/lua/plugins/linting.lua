return {
  {
    -- https://www.lazyvim.org/plugins/linting
    -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/linting.lua
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        fish = { "fish" },
        html = { "htmlhint" },
        python = { "bandit" },
        java = { "checkstyle" },
        rust = { "ast_grep" },
      },
    },
  },
}
