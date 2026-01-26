# mini-pick-preview.nvim 仕様書

## 概要

`mini-pick-preview.nvim` は `mini.pick` の拡張プラグインで、mini.pickの右側に独立したプレビューウィンドウを表示します。

## ウィンドウスタイル

プレビューウィンドウはpickerのウィンドウスタイル設定を自動継承します。以下の設定が同期されます：

- **border**: ボーダースタイル（"rounded", "solid" など）
- **noautocmd**: autocommandイベント制御フラグ
- **ハイライト**: `MiniPickNormal`, `MiniPickBorder` グループを自動適用

このため、pickerのカラースキームやボーダー設定を変更すると、プレビューウィンドウも自動で反映されます。

### プレビューウィンドウの配置

- **位置**: 常に右側（固定）
- **高さ**: pickerウィンドウと同じ
- **幅**: 画面幅からpickerの右端までを使用（自動計算）

### 設定

```lua
require('mini-pick-preview').setup()
```

setup()はパラメータを受け取りません。すべての動作は固定です。

## API

### setup()

プラグインを初期化します。パラメータなし。

```lua
require('mini-pick-preview').setup()
```

## イベント処理

### MiniPickStart

picker開始時にプレビューウィンドウを自動作成します。

### MiniPickStop

picker終了時にプレビューウィンドウを自動クローズします。

## 制約事項

### mini.pick single-window設計

mini.pickはsingle-window設計が特徴です。ウィンドウfocusが変わるとpickerが自動停止されるため：

- プレビューウィンドウは `focusable: false` で作成
- ユーザーは常にpickerウィンドウにfocus保持
- プレビュー更新は自動的に行われる

### プレビュー不可アイテム

`path` や `bufnr` を持たないアイテムはプレビューできない場合があります。その場合、プレビューウィンドウは空のままになります。

## ファイル構成

```
lua/mini-pick-preview/
├── init.lua      # エントリーポイント、setup()関数
├── window.lua    # ウィンドウ操作（右側固定）
└── events.lua    # mini.pickイベント処理
```

