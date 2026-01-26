-- バックアップファイルとスワップファイルを無効化
vim.opt.backup = false
vim.opt.swapfile = false

-- このファイルから相対的にプラグインディレクトリ(親の親)を解決してランタイムパスに追加
local plugin_dir = vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":h:h")
vim.opt.rtp:prepend(plugin_dir)

-- mini.nvimをランタイムパスに追加
vim.opt.rtp:prepend(vim.fn.expand("$HOME") .. "/.local/share/nvim/site/pack/deps/start/mini.nvim")

-- mini-pick-previewプラグインを初期化
require("mini.pick").setup()
require("mini-pick-preview").setup()
