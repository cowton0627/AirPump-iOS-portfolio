# AirPump iOS · Portfolio

> 一支 iOS UIKit app，控制藍牙穿戴式擠乳器並做紀錄分析。
> 從個人前公司專案 fork 出來做為作品集，已清除公司識別與 IP。

## Demo

> 截圖待補

## 技術棧

* **UI**：Swift + UIKit + Storyboard
* **架構**：MVVM + Repository Pattern + Combine（紀錄相關頁面）
* **iOS target**：13.0+
* **依賴**：Swift Package Manager · `realm-swift`

## 架構亮點

每個資料頁採取以下分層：

```
View (UIViewController)
    │  binds via Combine
    ▼
ViewModel  (formats data into ViewState)
    │  uses
    ▼
Repository (protocol)
    │  implemented by:
    ├── MockXxxRepository   ← 目前
    └── BLEXxxRepository    ← 未來真機資料
```

切換到真機資料**只需要新寫 Repository 並注入 ViewModel**，View 跟 ViewModel 完全不動。

## 重點實作

* 純 UIKit 自繪 `BarChartView`（無第三方依賴，~60 行 `draw(_:)`）
* `CAGradientLayer + CAShapeLayer.mask` 畫漸層弧線（操作頁的水滴形）
* SF Symbols + tintColor 取代客製 icon，nav bar 風格統一
* 示範資料明確標示橘色 banner，未連線真機時不誤導使用者

## 細節決策

每個重大選擇的理由與放棄的選項見 [DECISIONS.md](DECISIONS.md)。

## 開發

```bash
open "Breast Pump.xcodeproj"
# 在 Xcode 選自己的 Team
# ⌘R run
```

需先在 Signing & Capabilities 設定自己的 Apple Developer Team。

## License

僅供個人作品集展示。原專案 IP 屬原東家所有，本 fork 已移除所有商標、產品名稱與內部識別資訊。
