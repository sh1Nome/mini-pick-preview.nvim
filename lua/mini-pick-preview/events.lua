local M = {}

local window = require("mini-pick-preview.window")

-- タイマー状態管理
local current_timer = nil
local last_item = nil

---プレビューを更新する（共通処理）
---@param item any 現在選択されているアイテム
local function update_preview(item)
	-- プレビューウィンドウが表示中か確認
	if not window.is_open() then
		return
	end

	-- MiniPick が利用可能か確認
	if not MiniPick or not MiniPick.default_preview then
		return
	end

	-- プレビューバッファに表示
	local preview_buf = window.get_preview_buf()
	if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
		pcall(function()
			MiniPick.default_preview(preview_buf, item)
		end)
	end
end

---タイマーコールバック：カーソル移動を検知してプレビューを更新する
local function on_timer_tick()
	-- fast event contextのため、メインループで実行するようスケジュール
	vim.schedule(function()
		local ok, err = pcall(function()
			-- MiniPick が利用可能か確認
			if not MiniPick or not MiniPick.get_picker_matches then
				return
			end

			-- 現在のマッチ情報を取得
			local ok_matches, matches = pcall(MiniPick.get_picker_matches)
			if not ok_matches or not matches then
				return
			end

			-- 現在選択されているアイテムを取得
			local item = matches.current
			if not item then
				return
			end

			-- 前回のアイテムと比較してプレビューを更新
			if item ~= last_item then
				last_item = item
				update_preview(item)
			end
		end)
		if not ok then
			vim.notify("Error in timer callback: " .. tostring(err), vim.log.levels.ERROR)
		end
	end)
end

---MiniPickStartイベント：picker開始時にプレビューウィンドウを作成する
local function on_pick_start()
	-- プレビューウィンドウ作成（右側、高さ自動、幅自動）
	window.open()

	-- タイマーを開始（100ms間隔でカーソル移動を監視）
	last_item = nil
	current_timer = vim.uv.new_timer()
	current_timer:start(100, 100, on_timer_tick)
end

---MiniPickStopイベント：picker終了時にプレビューウィンドウをクローズする
local function on_pick_stop()
	-- タイマーを停止
	if current_timer then
		current_timer:stop()
		current_timer:close()
		current_timer = nil
	end

	last_item = nil
	window.close()
end

---イベントリスナーを登録する
function M.setup()
	local group = vim.api.nvim_create_augroup("MiniPickPreview", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MiniPickStart",
		callback = on_pick_start,
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MiniPickStop",
		callback = on_pick_stop,
	})
end

return M
