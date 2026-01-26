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

**ゼロコンフィグ設計**

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

## 内部API

### window.open()

プレビューウィンドウを作成します（自動呼び出し、ユーザーは使用不要）。

**動作**:
1. pickerウィンドウの座標・サイズを取得
2. 右側に固定、高さはpickerと同じで配置
3. プレビューバッファを作成し、ウィンドウに割り当て

### window.close()

プレビューウィンドウをクローズします（自動呼び出し、ユーザーは使用不要）。

**動作**:
1. ウィンドウをクローズ
2. バッファを削除
3. グローバル状態をリセット

### window.is_open()

プレビューウィンドウが表示中か確認（内部用）。

### window.get_preview_buf()

プレビューバッファIDを取得（内部用）。

## イベント処理

### MiniPickStart

picker開始時にプレビューウィンドウを自動作成します。

### MiniPickStop

picker終了時にプレビューウィンドウを自動クローズします。

### MiniPickMatch

pickerのマッチが更新されたとき、プレビューを自動更新します。

**処理内容**:
1. `MiniPick.get_picker_state()` で現在の選択アイテムを取得
2. `MiniPick.default_preview()` でプレビュー表示

## 制約事項

### mini.pick single-window設計

mini.pickはsingle-window設計が特徴です。ウィンドウfocusが変わるとpickerが自動停止されるため：

- プレビューウィンドウは `focusable: false` で作成
- ユーザーは常にpickerウィンドウにfocus保持
- プレビュー更新は自動的に行われる

### Item形式の柔軟性

pickerが返すitemは複数の形式をサポートしています：

- string: パス文字列
- table with `text`: マッチ表示用テキスト
- table with `path`: ファイルパス
- table with `bufnr`: バッファID
- table with `lnum`, `col`: 行・列番号

`MiniPick.default_preview()` がこれらを自動判別して表示します。

### プレビュー不可アイテム

`path` や `bufnr` を持たないアイテムはプレビューできない場合があります。その場合、プレビューウィンドウは空のままになります。

## ファイル構成

```
lua/mini-pick-preview/
├── init.lua      # エントリーポイント、setup()関数
├── window.lua    # ウィンドウ操作（右側固定）
└── events.lua    # mini.pickイベント処理
```

## パフォーマンス

- プレビューウィンドウ作成・削除は軽量（MiniPickStart/Stop時のみ）
- イベント処理は最小限（状態取得と描画のみ）
- 大量item時のパフォーマンスは `MiniPick.default_preview()` の実装に依存

