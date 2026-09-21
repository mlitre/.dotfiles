return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy", extraArgs = { "--all-targets" } },
            cargo = { allFeatures = true, buildScripts = { enable = true } },
            procMacro = { enable = true },
            inlayHints = { lifetimeElisionHints = { enable = "skip_trivial" } },
          },
        },
      },
    },
  },
}
