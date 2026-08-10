# DECISIONS

紀錄這個 repo 做過的主要架構決策、為什麼這樣選、放棄過哪些方案。

---

## 1. 將既有 iOS 專案整理為作品集

**選擇**：建立獨立 repository，移除原始 remote、組織識別與不適合公開的資料，再以中性品牌 AirPump 呈現。

**為什麼**：
* 公開作品集不應暴露原始組織、內部服務或私人文件
* 獨立 repository 可避免誤推到原始 remote
* 中性命名讓內容聚焦在 UIKit、BLE 與資料架構

**怎麼處理識別**：
* 公開 Bundle ID 使用 `com.example.AirPumpPortfolio`
* `Config/Signing.xcconfig` 可選擇性載入被忽略的 `Signing.local.xcconfig`
* 個人 Apple Developer Team ID 只留在本機，不進 tracked files
* App 顯示名稱與 navigation title 統一為 `AirPump`

**公開邊界**：不納入原始組織名稱、商標、內部文件、私有服務資訊、憑證或個人簽署資料。

---

## 2. 紀錄頁採 MVVM + Repository + Combine

**選擇**：將 `TodayViewController` / `HistoryTableViewController` / `DiscoveryTableViewController` 從「VC 內塞死資料 + 直接 cellForRow 寫死字串」改為 MVVM。

**為什麼**：
* 原 code 假資料寫死在 `cellForRowAt` 裡，未來要接 BLE 時 VC 要大改
* 想要可清楚展示「Mock / Real 切換」能力 — 作品集價值
* Combine 是 iOS 13+ 原生，不增加第三方依賴

**Repository pattern 帶來的好處**：
* `protocol TodayRecordRepository` 定義契約
* `MockTodayRecordRepository` 提供展示資料；`RealmTodayRecordRepository` 提供實際持久化資料
* VM 不關心資料來源
* Demo Mode 切換資料來源時，畫面與 ViewModel 不需改動

**放棄的選項**：
* ❌ SwiftUI + Observation：UIKit 為主，整個換成 SwiftUI 工程量過大
* ❌ Combine 純 publisher 不要 ViewModel：VC 直接訂閱 repository，但這樣 format 邏輯散在 VC 裡，違反 MVVM 精神
* ❌ Closure callback 取代 Combine：可行但 Combine 更可組合、cancellable 管理更乾淨

---

## 3. 自繪 BarChartView，不引第三方 chart 套件

**選擇**：純 `draw(_:)` + `UIBezierPath` 自繪長條圖。約 60 行。

**為什麼**：
* iOS deployment target = 13.0，**Swift Charts 需要 iOS 16+** → 用不了
* 不想為作品集只加一個圖表就引 `Charts` / `DGCharts`（500KB+ 體積、額外維護成本）
* 自繪展示 Core Graphics 能力，portfolio 加分
* 圖表需求簡單（7 天 bar，無交互）

**放棄的選項**：
* ❌ 提高 deployment target 到 iOS 16 用 Swift Charts：捨棄太多裝置，且 UIKit + Swift Charts 要 `UIHostingController`，更複雜
* ❌ DGCharts SPM：依賴體積、學習曲線、未來維護

---

## 4. Operation 頁弧線從寫死改為 bounds-driven

**選擇**：`UIBezierPath(roundedRect: leftView.bounds, ...)` 動態，並把 setup 從 `viewDidLoad` 移到 `viewDidLayoutSubviews` + one-shot flag。

**為什麼**：
* 原 code 把 path 寫死 `185 × 375` 或 `200 × 430`（依 screenWidth 分流）
* `leftView.frame = CGRect(...)` 直接設 frame 在 Auto Layout view 上**根本不會生效**
* 後果：path 比 view 大 55px，弧線下緣**畫到外面**，覆蓋下方模式按鈕

**順手清理**：
* 移除 `setupConstraints()` 中為了補這個 bug 的 4 個 screenHeight 分支
* 移除 2 個 outlet `lStackBottomConstraint` / `rStackBottomConstraint`
* `leftStack` / `rightStack` 改為錨定 `leftView.bottom + 16`，不再漂浮到 `safeArea.bottom`

**埋坑紀錄**：第一次重構漏設 `border.strokeColor`，gradient 整個被 mask 為空 → 漸層消失。CAShapeLayer 當 mask 用時只看 alpha，但 strokeColor 必須是非透明色才會「畫出 stroke 區域」。

---

## 5. Nav bar 按鈕從自製 PNG 改 SF Symbols

**選擇**：`prefMenu` / `addDevice` PNG（圖檔內含色圓圈）→ SF Symbol `line.3.horizontal` / `plus`，並把 nav bar tintColor 設為白色。

**為什麼**：
* 原 PNG 把圓圈背景烤進圖檔，又用 `.alwaysOriginal` 渲染 → 跟 nav bar 青色不協調（左邊深青、右邊紅圈撞色）
* SF Symbols 自動隨 tintColor 染色，跟 nav bar 顏色協調
* iOS-native 寫法，作品集展示

**影響範圍**：5 個 storyboard + 5 個 controller 全部統一替換。

**附帶**：`prefMenu.imageset` / `addDevice.imageset` 變成死碼資產，待視覺驗證後可刪。

---

## 6. 討論區「溫馨提醒」alert 用 weak ref 防疊加

**選擇**：`private weak var currentAlertView: ReusableAlertView?` + viewDidAppear guard。

**為什麼**：
* 原 code 在 `viewDidAppear` 直接 `showAlertView()`，alertView 是 local 變數
* 切換 tab 來回 → viewDidAppear 重複觸發 → 疊加多個 alertView
* 使用者看到「按確認背景變了但對話框沒消失」（其實是底下還有一個）

**為什麼用 weak ref 不用 strong ref**：
* `ReusableAlertView` 的 IBAction 已有 `defer { removeFromSuperview() }`，按完會自己從畫面移除
* 移除後 view 被 ARC 釋放，weak ref 自動 nil
* 下次 viewDidAppear 才能再 show（guard 過得了）
* strong ref 會阻止 ARC 釋放，需要手動 nil，多餘的同步點

---

## 待決定

（每次要重大決策但還沒下手的，先寫到這邊）

* 是否把 `OperationViewController` 重構 MVVM？工程量大（1800 行 + fixedFrame 子 view）。先不動。
* `RealmSwift` 是否真的要保留作為未來 persistence？若不用，建議移除 SPM 依賴與所有 `import RealmSwift`。

## 7. Operation MVVM 採分階段拆分

**第一階段**：新增 `OperationViewModel`，集中管理左右側連線／擠乳狀態與 VoiceOver 文案；`OperationViewController` 仍保留 BLE command 與 UIKit binding。

**為什麼**：
* 先建立可被 unit test 驗證的狀態邊界，避免直接重寫 1,800 行控制器。
* BLE 寫入流程尚未移動，降低實體裝置行為回歸風險。
* 後續可依序抽出 BLE command adapter、session timer 與 mode state，再縮小 ViewController 責任。
