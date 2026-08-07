# Runbook

## Simulator 作品集截圖驗證（2026-08-05）

### 目前進度

- 已在 iPhone 15 / iOS 17.5 Simulator 啟動 AirPump，並確認「紀錄」主分頁可顯示 Demo Mode 資料。
- 已產生並目視確認三張紀錄頁截圖：
  - `Docs/Media/airpump-record-today.png`
  - `Docs/Media/airpump-record-history.png`
  - `Docs/Media/airpump-record-discovery.png`
- README 的三欄展示已改為上述實際畫面。

### 已確認的操作問題

- Xcode 若仍有 CovidAPI 執行工作階段，會搶回 Simulator 前景；擷取 AirPump 前應先停止該工作階段。
- 目前為多螢幕配置，`cliclick` 座標與 Simulator 視窗座標不一致，不應沿用螢幕截圖換算出的絕對座標。
- `osascript` 與 `cliclick` 目前回報缺少 macOS Accessibility 權限。Codex 是由 Terminal 內的 `codex-gh` 啟動，因此權限應授予實際承載程序的 Terminal，而不是尋找 Codex App。
- Terminal 已列在 Accessibility 清單時，需關閉再開啟權限、完全退出 Terminal（Command-Q），重新開啟後再啟動 `codex-gh`，讓新程序取得 TCC 權限。

### 驗證結果

1. macOS Screen Recording 與 Accessibility 權限可用。
2. 擷取前已停止會搶前景的 CovidAPI，並以 `simctl launch` 明確啟動 AirPump。
3. 三張圖片皆由 Simulator 裝置顯示直接輸出，不包含視窗外框或其他 App 內容。
4. 歷史與統計畫面均顯示橘色 Demo Mode 標示，資料與目前 mock repository 一致。

## Unit tests（2026-08-05）

- 新增 `Breast PumpTests` target 並納入 shared scheme。
- 覆蓋 Demo Mode 切換通知、左右紀錄合併、10 分鐘 session pairing window、當日篩選、duration 解析與七日統計。
- 已在 iPhone 15 / iOS 17.5 Simulator 執行 7 個 tests，0 failures，結果為 `TEST SUCCEEDED`。

## GitHub Actions CI（2026-08-05）

- Workflow：`.github/workflows/ios-ci.yml`
- 觸發條件：push 至 `main`、所有 pull requests。
- 使用 `macos-15` runner，動態建立 runner 上最新可用的 iOS Simulator。
- 驗證 tracked files 不含 Apple Developer Team ID，且 `Signing.local.xcconfig` 保持 ignored／untracked。
- 執行 shared `Breast Pump` scheme 的完整 unit-test suite，無需 code signing。

## 窄螢幕版面回歸（2026-08-06）

- 「當日紀錄」、「歷史紀錄」與「統計分析」皆以 393pt、320pt 兩種寬度驗證；核心操作頁另以 320×568 最小尺寸驗證。
- 歷史紀錄 cell 原先四個右側欄位沿用 375pt storyboard 固定座標，已改為響應式 stack view constraints。
- 測試會確認所有紀錄與 KPI 文字位於 cell 邊界內，依 label 的最小縮放比例檢查文字可完整容納，並驗證自繪圖表未超出 cell。
- 操作頁的尺寸判斷已由一次性的 `UIScreen` 讀值改為每次 layout 依 `view.bounds` 更新，能正確因應尺寸變化並避免重複 transform。
- 影音區、偏好設定與討論區警示框亦納入 320pt 寬度檢查；警示框外層會限制在目前畫面寬度，遮罩背景可隨尺寸調整。
- 圖示導覽、左右強度控制、開始／暫停、裝置連線狀態與影音操作已補上 VoiceOver 名稱，並加入回歸測試。
- 影音頁下載與類型選擇按鈕由 31pt 高調整為至少 44×44pt 觸控範圍，窄螢幕版面測試仍通過。
- 完整 suite 共 12 個 tests，0 failures。
