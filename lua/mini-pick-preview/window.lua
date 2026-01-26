local M = {}

-- プレビューウィンドウのID（グローバル状態）
---@type number | nil プレビューウィンドウID
M.preview_win = nil

---@type number | nil プレビューバッファID
M.preview_buf = nil

---プレビューバッファを作成する
---@return number バッファID
local function create_preview_buffer()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
	return buf
end

---プレビューウィンドウを作成する
---右側に固定、高さはpickerと同じ、幅は自動計算
---pickerのボーダー・ハイライト・autocommand設定を継承
---@return number | nil ウィンドウID、失敗時はnil
function M.open()
	-- 既存ウィンドウをクローズ
	M.close()

	-- プレビューバッファ作成
	M.preview_buf = create_preview_buffer()

	-- pickerウィンドウ（親ウィンドウ）を取得
	local picker_win = vim.api.nvim_get_current_win()

	-- ウィンドウが有効か確認
	if not vim.api.nvim_win_is_valid(picker_win) then
		return nil
	end

	local picker_win_config = vim.api.nvim_win_get_config(picker_win)

	-- pickerウィンドウが浮動ウィンドウであることを確認
	if not picker_win_config.relative or picker_win_config.relative == "" then
		return nil
	end

	-- pickerのスタイル設定を継承
	local border = picker_win_config.border or "rounded"
	local noautocmd = picker_win_config.noautocmd or false
	local col = picker_win_config.col + picker_win_config.width + 4

	-- プレビューウィンドウの位置・サイズを計算
	local preview_config = {
		relative = "editor",
		focusable = false,
		style = "minimal",
		border = border,
		noautocmd = noautocmd,
		anchor = picker_win_config.anchor,
		zindex = picker_win_config.zindex and (picker_win_config.zindex - 1),
		height = picker_win_config.height,
		row = picker_win_config.row,
		col = col,
		width = vim.o.columns - col,
	}

	-- プレビューウィンドウ作成
	pcall(function()
		M.preview_win = vim.api.nvim_open_win(M.preview_buf, false, preview_config)
	end)

	-- ハイライトをpickerから継承
	if M.preview_win and vim.api.nvim_win_is_valid(M.preview_win) then
		pcall(function()
			vim.api.nvim_set_hl(0, "MiniPickPreviewNormal", { link = "MiniPickNormal" })
			vim.api.nvim_set_hl(0, "MiniPickPreviewBorder", { link = "MiniPickBorder" })
			vim.api.nvim_win_set_config(
				M.preview_win,
				{ winhighlight = "Normal:MiniPickPreviewNormal,FloatBorder:MiniPickPreviewBorder" }
			)
		end)
	end

	return M.preview_win
end

---プレビューウィンドウをクローズする
function M.close()
	if M.preview_win and vim.api.nvim_win_is_valid(M.preview_win) then
		vim.api.nvim_win_close(M.preview_win, true)
		M.preview_win = nil
	end

	if M.preview_buf and vim.api.nvim_buf_is_valid(M.preview_buf) then
		vim.api.nvim_buf_delete(M.preview_buf, { force = true })
		M.preview_buf = nil
	end
end

---プレビューウィンドウが表示中かどうか
---@return boolean 表示中ならtrue
function M.is_open()
	return M.preview_win ~= nil and vim.api.nvim_win_is_valid(M.preview_win)
end

---プレビューバッファのIDを取得
---@return number | nil バッファID、表示中でなければnil
function M.get_preview_buf()
	return M.preview_buf
end

return M
