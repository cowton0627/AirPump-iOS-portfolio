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
- 已在 iPhone 15 / iOS 17.5 Simulator 執行 14 個 unit/integration tests，0 failures，結果為 `TEST SUCCEEDED`；另有 10 個 XCUITests 由同一個 shared scheme 執行。

## GitHub Actions CI（2026-08-05）

- Workflow：`.github/workflows/ios-ci.yml`
- 觸發條件：push 至 `main`、所有 pull requests。
- 使用 `macos-15` runner，動態建立 runner 上最新可用的 iOS Simulator。
- 驗證 tracked files 不含 Apple Developer Team ID，且 `Signing.local.xcconfig` 保持 ignored／untracked。
- 執行 shared `Breast Pump` scheme 的完整 unit 與 UI test suites，無需 code signing；失敗時上傳 `.xcresult` artifact。
- 測試完成後以 `xcresulttool` 將結果摘要寫入 GitHub Actions Summary，方便核對測試數量、destination 與失敗資訊。

## 窄螢幕版面回歸（2026-08-06）

- 「當日紀錄」、「歷史紀錄」與「統計分析」皆以 393pt、320pt 兩種寬度驗證；核心操作頁另以 320×568 最小尺寸驗證。
- 歷史紀錄 cell 原先四個右側欄位沿用 375pt storyboard 固定座標，已改為響應式 stack view constraints。
- 測試會確認所有紀錄與 KPI 文字位於 cell 邊界內，依 label 的最小縮放比例檢查文字可完整容納，並驗證自繪圖表未超出 cell。
- 操作頁的尺寸判斷已由一次性的 `UIScreen` 讀值改為每次 layout 依 `view.bounds` 更新，能正確因應尺寸變化並避免重複 transform。
- 影音區、偏好設定與討論區警示框亦納入 320pt 寬度檢查；警示框外層會限制在目前畫面寬度，遮罩背景可隨尺寸調整。
- 圖示導覽、左右強度控制、開始／暫停、裝置連線狀態與影音操作已補上 VoiceOver 名稱，並加入回歸測試。
- 影音頁下載與類型選擇按鈕由 31pt 高調整為至少 44×44pt 觸控範圍，窄螢幕版面測試仍通過。
- BLE 圖示與 VoiceOver value 共用 `setConnectionState(_:at:)` 更新；連線讀為「已連線」，斷線與 reset 讀為「未連線」。
- 開始／暫停圖示與 VoiceOver 名稱共用 `setPumpingState(_:at:)` 更新，依左右側與即時狀態朗讀「開始…擠乳」或「暫停…擠乳」。
- 紀錄頁的今日／歷史／分析切換共用 `selectRecordPage(at:)` 更新內容、顏色與 VoiceOver `.selected` trait，避免選取狀態只靠色彩表達。
- 影音與照片詳情頁的純圖示控制具有明確 VoiceOver 名稱；影音播放按鈕切換時會同步朗讀「播放影音」或「暫停影音」。
- 偏好設定的響鈴與通知開關以 `UISwitch.isOn` 同步內部狀態及相依設定列，避免事件重送或程式化變更造成畫面與狀態相反。
- 自訂提醒、結束擠乳與低電量警示框皆標記為 VoiceOver modal；標題使用 `.header` trait，純圖示關閉鈕朗讀為「關閉」。
- 完整 suite 共 14 個 unit/integration tests 與 10 個 XCUITests，0 failures。
- `Breast PumpUITests` 透過 `AIRPUMP_START_TAB=1` 從紀錄頁啟動，使用 `tab.records` 與 `records.today/history/analysis` identifiers 驗證實際點擊與選取狀態；另有流程切換 `preference.beep`／`preference.notify`／`作品集示範模式`、從 `tab.video` 分別選取「所有項目」／「相簿」／「影片」，以及從 `tab.discussion` 關閉並重新進入時恢復「敬請期待」提示。
- UI Test 啟動時傳入 `-ApplePersistenceIgnoreState YES`，避免 Scene state restoration 讓測試沿用前一條流程的 tab 或 overlay。
- 操作頁 UI smoke test 直接以 `AIRPUMP_START_TAB=0` 啟動，驗證無 BLE 時左右降低強度與開始／暫停控制仍有穩定 identifiers、VoiceOver 名稱與可呈現狀態。
