//
//  OperationViewController.swift
//  Breast Pump
//
//  Created by Addwii on 2021/12/13.
//

import UIKit
import CoreBluetooth
import RealmSwift

/// 主操作頁面
class OperationViewController: UIViewController {
    // MARK: - Properties
    private var bleManager: BLEConnectionManager { BLEConnectionManager.shared }
    private let stopwatch = Stopwatch()
    private let stopLastWatch = Stopwatch()
    
    private lazy var shutdownAlertView: ShutdownAlertView = {
        let view = ShutdownAlertView.instantiateFromNib()
        view.delegate = self
        return view
    }()
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: view.bounds)
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
//    private var timer: Timer?
//    private var lastTimer: Timer?
    
    /// 檢查 vc 是否有在畫面上，避免沒在畫面上做無謂的更新
//    private var vcIsOnScreen: Bool {
//        viewIfLoaded?.window != nil && UIApplication.shared.applicationState == .active }
    
    // 裝置特徵字典
    private var charDict = [CBUUID: CBCharacteristic]()
    private var charLastDict = [CBUUID: CBCharacteristic]()
    // 從自動模式跳開
    private var autoCount = 0
    private var autoLastCount = 0
    // navigationBar用圖顯示原樣
    private let prefMenuImage = UIImage(named: "prefMenu")?.withRenderingMode(.alwaysOriginal)
    private let addDeviceImage = UIImage(named: "addDevice")?.withRenderingMode(.alwaysOriginal)
    // 現螢幕寬高
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    // 特徵值字串
    private let Left  = "00"
    private let Right = "01"
    private let Pause = "00"
    private let Play  = "01"
    private let Massage = "00"
    private let Milking = "01"
    private let Impossible = "10"
    private let None = ""
    private let Yes = "是"
    private let No = "否"
    private var sideJudge = "judgeSide"
    
    // Theme Color
    private let themeColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
    private let lightThemeColor = #colorLiteral(red: 0.8274509804, green: 0.9176470588, blue: 0.9411764706, alpha: 1)
    private let titleColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)
    private let turnOffBtnColor = #colorLiteral(red: 0.9803921569, green: 0.5960784314, blue: 0.5960784314, alpha: 1)
    private let systemGrayFive = #colorLiteral(red: 0.898, green: 0.8980392157, blue: 0.9176470588, alpha: 1)
    
    // MARK: - IBOutlet
    // 顯示日期
    @IBOutlet weak var dateLabel: UILabel!
    
    // 底層view
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    // 強度view
    @IBOutlet weak var leftStrenthView: UIView!
    @IBOutlet weak var rightStrenthView: UIView!
    // 模式、開關底view
    @IBOutlet weak var leftStack: UIStackView!
    @IBOutlet weak var rightStack: UIStackView!
    
    // 模式buttons
    @IBOutlet var autoButton: [UIButton]!
    @IBOutlet var milkingButton: [UIButton]!
    @IBOutlet var massageButton: [UIButton]!

    // 顯示電量
    @IBOutlet var batteryImageView: [UIImageView]!
    // 顯示已使用時間
    @IBOutlet var timeLabel: [UILabel]!
    
    // 顯示是否配對
    @IBOutlet var bleStateButton: [UIButton]! // isn't enable
    // 顯示集乳量（毫升數）
    @IBOutlet var mlLabel: [UILabel]!
    // 顯示強度
    @IBOutlet var strengthLabel: [UILabel]!
    // Other Buttons
    @IBOutlet var decreaseButton: [UIButton]!
    @IBOutlet var increaseButton: [UIButton]!
    @IBOutlet var playPauseButton: [UIButton]!
    @IBOutlet var turnOffButton: [UIButton]!
    // Constraints
    @IBOutlet weak var opTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rStackBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Date())
        configureUI()
        // 自動連線才可能會用到
//        didUpdateValueForState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bleManager.startingScan()
        setupListener()
        didUpdateValueForUiState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bleManager.stopScanning()
    }
    
    // MARK: - IBAction
    /// 降低強度
    @IBAction func decreaseTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {

                    var parameter = NSInteger(lv - 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入降強度
                    device.peripheral.writeValue(data,
                                                 for: charDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                if let level = charLastDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv - 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入降強度
                    device.peripheral.writeValue(data,
                                                 for: charLastDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
            }
            
        case 1:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv - 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入降強度
                    device.peripheral.writeValue(data,
                                                 for: charDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charLastDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv - 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入降強度
                    device.peripheral.writeValue(data,
                                                 for: charLastDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
            }
            
        default: break
        }
    }
    /// 增加強度
    @IBAction func increaseTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv + 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入增強度
                    device.peripheral.writeValue(data,
                                                 for: charDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charLastDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv + 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入增強度
                    device.peripheral.writeValue(data,
                                                 for: charLastDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
            }

        case 1:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv + 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入增強度
                    device.peripheral.writeValue(data,
                                                 for: charDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if let level = charLastDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
                   let lv = Int(level) {
                    
                    var parameter = NSInteger(lv + 1)
                    let data = NSData(bytes: &parameter, length: 1) as Data
                    // MARK: 寫入增強度
                    device.peripheral.writeValue(data,
                                                 for: charLastDict[GATT.PUMP_LEVEL]!,
                                                 type: .withResponse)
                }
            }
            
        default: break
        }
    }
    /// 啟動暫停切換
    @IBAction func playPauseTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                if stringValue(at: charDict[GATT.PUMP_STATUS]) == Pause {
                    
                    let data = Data(hexString: Play)
                    // MARK: 寫入啟動
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopwatch.start()
//                    updateConnectingTime()
                    
                } else if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
                    
                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopwatch.stop()
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Pause {
                    
                    let data = Data(hexString: Play)
                    // MARK: 寫入啟動
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopLastWatch.start()
//                    updateConnectingLastTime()
                    
                } else if charLastDict[GATT.PUMP_STATUS]?.value?.hexToStr() == Play {
                    
                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopLastWatch.stop()
                }
            }
            
        case 1:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                if stringValue(at: charDict[GATT.PUMP_STATUS]) == Pause {
                    
                    let data = Data(hexString: Play)
                    // MARK: 寫入啟動
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopwatch.start()
//                    updateConnectingTime()
                    
                } else if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
                    
                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopwatch.stop()
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Pause {
                    
                    let data = Data(hexString: Play)
                    // MARK: 寫入啟動
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopLastWatch.start()
//                    updateConnectingLastTime()
                    
                } else if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
                    
                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                    
//                    stopLastWatch.stop()
                }
            }
            
        default: break
        }
    }
    /// 切至"01"模式
    @IBAction func milkingAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoCount += 1
                
                if stringValue(at: charDict[GATT.OPERATION_MODE]) == Massage {
                    
                    let data = Data(hexString: Milking)
                    // MARK: 寫入吸乳
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoLastCount += 1
                
                if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Massage {
                    
                    let data = Data(hexString: Milking)
                    // MARK: 寫入吸乳
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
            }
            
        case 1:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoCount += 1
                
                if stringValue(at: charDict[GATT.OPERATION_MODE]) == Massage {
                    
                    let data = Data(hexString: Milking)
                    // MARK: 寫入吸乳
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoLastCount += 1
                
                if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Massage {
                    
                    let data = Data(hexString: Milking)
                    // MARK: 寫入吸乳
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
            }
            
        default: break
        }
    }
    /// 切至"00"模式
    @IBAction func massageAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoCount += 1
                
                if stringValue(at: charDict[GATT.OPERATION_MODE]) == Milking {
                    
                    let data = Data(hexString: Massage)
                    // MARK: 寫入按摩
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoLastCount += 1
                
                if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Milking {
                    
                    let data = Data(hexString: Massage)
                    // MARK: 寫入按摩
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
            }
            
        case 1:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoCount += 1
                
                if stringValue(at: charDict[GATT.OPERATION_MODE]) == Milking {

                    let data = Data(hexString: Massage)
                    // MARK: 寫入按摩
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                autoLastCount += 1
                
                if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Milking {

                    let data = Data(hexString: Massage)
                    // MARK: 寫入按摩
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.OPERATION_MODE]!,
                                                 type: .withResponse)
                }
            }
            
        default: break
        }
    }
    /// 結束吸乳動作（分左右）
    @IBAction func leftTurnOffTapped(_ sender: UIButton) {
        sideJudge = Left
        showShutDownAlertView()
//        if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
        
//        view.addSubview(backgroundView)
//        view.addSubview(shutdownAlertView)
//        shutdownAlertView.center = view.center
        
//        } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
//            view.addSubview(backgroundView)
//            view.addSubview(shutdownAlertView)
//            shutdownAlertView.center = view.center
//        }
    }
    @IBAction func rightTurnOffTapped(_ sender: UIButton) {
        sideJudge = Right
        showShutDownAlertView()
//        if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
        
//        view.addSubview(backgroundView)
//        view.addSubview(shutdownAlertView)
//        shutdownAlertView.center = view.center
        
//        } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
//            view.addSubview(backgroundView)
//            view.addSubview(shutdownAlertView)
//            shutdownAlertView.center = view.center
//        }
    }
    
    /// 已拆分，不再連動
    @IBAction func turnOffTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
//                guard let uuidStr = deviceUUID(from: charDict) else { return }
//                guard let device = bleConnectedDevice(has: uuidStr) else { return }

//                guard let device = bleManager.connectedDevices.filter({ $0.peripheral.identifier.uuidString == uuidStr }).first else { return }
                
                showShutDownAlertView()
//                view.addSubview(backgroundView)
//                view.addSubview(shutdownAlertView)
//                shutdownAlertView.center = view.center
                
//                AlertManager.showActionAlert(subtitle: "確定結束？",
//                                             actionType: .default) { [self] (_) in
//
//                    if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
//
//                        let data = Data(hexString: Pause)
//                        // MARK: 寫入暫停
//                        device.peripheral.writeValue(data!,
//                                                     for: charDict[GATT.PUMP_STATUS]!,
//                                                     type: .withResponse)
//                    }
//
//                    stopwatch.stop()
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        bleManager.disconnectDeviceActively(device)
//                    }
//                }
                
//                let alert = UIAlertController(title: None, message: "確定結束？",
//                                              preferredStyle: .alert)
//                let confirmAction = UIAlertAction(title: Yes, style: .default) { [self] (_) in
//                    
////                    let deviceUUID = CBUUID(string: device.peripheral.identifier.uuidString)
//
//                    if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
//                        let data = Data(hexString: Pause)
//                        // MARK: 寫入暫停
//                        device.peripheral.writeValue(data!,
//                                                     for: charDict[GATT.PUMP_STATUS]!,
//                                                     type: .withResponse)   }
//                    
//                    stopwatch.stop()
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        bleManager.disconnectDeviceActively(device)
////                        // 更新完UI再廣播取回
////                        if bleManager.charDict.isEmpty &&
////                            !bleManager.charLastDict.keys.contains(deviceUUID) {
////                            bleManager.broadcastCharDictChanged()
////                        } else if bleManager.charLastDict.isEmpty && !bleManager.charDict.keys.contains(deviceUUID) {
////                            bleManager.broadcastCharLastDictChanged()
////                        }
//                    }
//
////                    bleManager.disconnectDeviceActively(device) {
////                        if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
////                            let data = Data(hexString: Pause)
////                            // 寫入暫停
////                            device.peripheral.writeValue(data!,
////                                                         for: charDict[GATT.PUMP_STATUS]!,
////                                                         type: .withResponse)                              }
////                        stopwatch.stop()
////                    }
//
////                    let group = DispatchGroup()
////                    group.enter()
////                    if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
////                        let data = Data(hexString: Pause)
////                        // 寫入暫停
////                        device.peripheral.writeValue(data!,
////                                                     for: charDict[GATT.PUMP_STATUS]!,
////                                                     type: .withResponse)                              }
////                    group.leave()
////                    group.wait()
////                    group.enter()
////                    while stringValue(at: charDict[GATT.PUMP_STATUS]) == Pause {
////                        bleManager.disconnectDeviceActively(device)
////                    }
////                    group.leave()
////                    stopwatch.stop()
////                    resetLeftViews()

//                    // MARK: 寫入資料庫
//    //                startCounting()
//                }
                
//                alert.addAction(confirmAction)
//                let cancelAction = UIAlertAction(title: No, style: .cancel, handler: nil)
//                alert.addAction(cancelAction)
//                if self.presentedViewController == nil {
//                    present(alert, animated: true, completion: nil)
//                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
//                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
//                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                showShutDownAlertView()
//                view.addSubview(backgroundView)
//                view.addSubview(shutdownAlertView)
//                shutdownAlertView.center = view.center
                
//                AlertManager.showActionAlert(subtitle: "確定結束？",
//                                             actionType: .default) { [self] (_) in
//
//                    if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
//
//                        let data = Data(hexString: Pause)
//                        // MARK: 寫入暫停
//                        device.peripheral.writeValue(data!,
//                                                     for: charLastDict[GATT.PUMP_STATUS]!,
//                                                     type: .withResponse)
//                    }
//
//                    stopLastWatch.stop()
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        bleManager.disconnectDeviceActively(device)
//                    }

                    // MARK: 寫入資料庫
    //                startCounting()
//                }

//                if self.presentedViewController == nil {
//                    present(alert, animated: true, completion: nil)
//                }
            }
            
        case 1:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                
//                guard let uuidStr = deviceUUID(from: charDict) else { return }
//                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                showShutDownAlertView()
//                view.addSubview(backgroundView)
//                view.addSubview(shutdownAlertView)
//                shutdownAlertView.center = view.center
                
//                AlertManager.showActionAlert(subtitle: "確定結束？",
//                                             actionType: .default) { [self] (_) in
//
//                    if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
//
//                        let data = Data(hexString: Pause)
//                        // MARK: 寫入暫停
//                        device.peripheral.writeValue(data!,
//                                                     for: charDict[GATT.PUMP_STATUS]!,
//                                                     type: .withResponse)
//                    }
//
//                    stopwatch.stop()
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        bleManager.disconnectDeviceActively(device)
//                    }
                    
                    // MARK: 寫入資料庫
    //                startCounting()
//                }
                
//                if self.presentedViewController == nil {
//                    present(alert, animated: true, completion: nil)
//                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
//                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
//                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                showShutDownAlertView()
//                view.addSubview(backgroundView)
//                view.addSubview(shutdownAlertView)
//                shutdownAlertView.center = view.center
                
//                AlertManager.showActionAlert(subtitle: "確定結束？",
//                                             actionType: .default) { [self] (_) in
//                    if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
//
//                        let data = Data(hexString: Pause)
//                        // MARK: 寫入暫停
//                        device.peripheral.writeValue(data!,
//                                                     for: charLastDict[GATT.PUMP_STATUS]!,
//                                                     type: .withResponse)
//                    }
//
//                    stopLastWatch.stop()
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        bleManager.disconnectDeviceActively(device)
//                    }
                    
                    // MARK: 寫入資料庫
    //                startCounting()
//                }
                
//                if self.presentedViewController == nil {
//                    present(alert, animated: true, completion: nil)
//                }
            }
            
        default: break
        }
        
    }
    
    // MARK: - Methods
    private func startCounting() {
        let realmData = try! Realm()
        let milkingData: RLM_BreastPump = RLM_BreastPump()
        
//        開始時間
//        dynamic var startTime: String = ""
//        結束時間
//        dynamic var endTime: String = ""
//        持續時間
//        dynamic var duration: String = ""
        
        let date = Date()
        milkingData.date = date
        
        
        
        if let breastSide = charDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
            milkingData.breastSide = breastSide
        }
        if let liquidHeight = charDict[GATT.LIQUID_HEIGHT]?.value?.first {
            let lh = Int(liquidHeight)
            milkingData.amount = lh
        }
        if let strength = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr() {
            milkingData.strength = strength
        }
        if let mode = charDict[GATT.OPERATION_MODE]?.value?.hexToStr() {
            milkingData.mode = mode
        }

//        milkingData.endTime =
//        milkingData.duration =
        
        try! realmData.write({
            realmData.add(milkingData)
        })
        
//        if let milkingData = realmData?.objects(RLM_Milking.self) {
//            try! realmData?.write({
//                RLM_Milking(value: milkingData)
//            })
//        }
        
    }
    
    /// 顯示斷線警示
    private func showShutDownAlertView() {
        view.addSubview(backgroundView)
        view.addSubview(shutdownAlertView)
        shutdownAlertView.center = view.center
    }
    
    /// 配對與否（暫無用）
    private func isPaired() -> Bool {
        return false
    }
    
    /// 濾出特定裝置以操作
    private func bleConnectedDevice(has uuid: String) -> BLEDevice? {
        guard let device = bleManager.connectedDevices.filter({
            
            $0.peripheral.identifier.uuidString == uuid
            
        }).first else { return nil }
        
        return device
    }
    
    /// 取出特徵字典之特徵值字串
    private func stringValue(at dictChar: CBCharacteristic? = nil) -> String {
        // 因電量取出方式不同, 故擋掉
        guard dictChar != GATT.BATTERY_LEVEL else { return Impossible }
        // 因液高取出方式不同, 故擋掉
        guard dictChar != GATT.LIQUID_HEIGHT else { return Impossible }
        guard let value = dictChar?.value?.hexToStr() else { return Impossible }
        return value
//        if let value = dictChar.value?.hexToStr() {
//            return value
//        } else { return "" }
    }
    
    /// 取出特徵字典裝置uuid
    private func deviceUUID(from dict: [CBUUID: CBCharacteristic]) -> String? {
        for (key, value) in dict {
            if value.uuid == GATT.DEVICE_UUID {
                let uuidStr = key.uuidString
                return uuidStr
            }
        }
        return nil
//        let uuidStr = dict.filter {
//            $0.value.uuid == Gatt.DEVICE_UUID
//        }.first?.key.uuidString
        
//        guard let uuidStr = dict[Gatt.BREAST_SIDE]?.service?.peripheral?.identifier.uuidString else { return nil }
//        return uuidStr
    }
    
    /// 取回特徵字典，隨即更新UI狀態
    @objc private func retrieveCharDict(noti: Notification) {
        guard let charDict = noti.userInfo?["charDict"] as? [CBUUID: CBCharacteristic] else { return }
        self.charDict = charDict
        didUpdateValueForUiState()
    }
    @objc private func retrieveCharLastDict(noti: Notification) {
        guard let charLastDict = noti.userInfo?["charLastDict"] as? [CBUUID: CBCharacteristic] else { return }
        self.charLastDict = charLastDict
        didUpdateValueForUiState()
    }
    
    /// 重新連線時，button恢復可選（暫無用）
    @objc private func bleConnected(noti: Notification) {
        guard let device = noti.userInfo?["BLEDevice"] as? BLEDevice else { return }

        let deviceUUID = CBUUID(string: device.peripheral.identifier.uuidString)
        if charDict.keys.contains(deviceUUID),
           let side = charDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
            let index = side == Left ? 0 : 1
            DispatchQueue.main.async { self.btnsEnabled(index) }

        } else if charLastDict.keys.contains(deviceUUID),
                  let side = charLastDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
            let index = side == Left ? 0 : 1
            DispatchQueue.main.async { self.btnsEnabled(index) }
        }
    }
    
    /// 裝置斷線時，UI的變化
    @objc private func bleDisconnected(noti: Notification) {
        // 廣播裝置斷線時, manager的字典已無services, 但操作頁字典仍可比對裝置uuid（因為尚未廣播取回）
        guard let device = noti.userInfo?["BLEDevice"] as? BLEDevice else { return }
        let deviceUUID = CBUUID(string: device.peripheral.identifier.uuidString)
        
        if charDict.keys.contains(deviceUUID),
           let side = charDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
            
            side == Left ? resetLeftViews() : resetRightViews()
            let index = side == Left ? 0 : 1
            stopwatch.stop()
            autoCount = 0
            DispatchQueue.main.async { self.btnsDisable(index) }

            // 更新完UI再廣播取回 空特徵字典
            if bleManager.charDict.isEmpty &&
                !bleManager.charLastDict.keys.contains(deviceUUID) {
                bleManager.broadcastCharDictChanged()
                
            } else if bleManager.charLastDict.isEmpty && !bleManager.charDict.keys.contains(deviceUUID) {
                bleManager.broadcastCharLastDictChanged()
            }

        } else if charLastDict.keys.contains(deviceUUID),
                  let side = charLastDict[GATT.BREAST_SIDE]?.value?.hexToStr() {
            
            side == Left ? resetLeftViews() : resetRightViews()
            let index = side == Left ? 0 : 1
            stopLastWatch.stop()
            autoLastCount = 0
            DispatchQueue.main.async { self.btnsDisable(index) }
            
            if bleManager.charDict.isEmpty &&
                !bleManager.charLastDict.keys.contains(deviceUUID) {
                bleManager.broadcastCharDictChanged()
                
            } else if bleManager.charLastDict.isEmpty && !bleManager.charDict.keys.contains(deviceUUID) {
                bleManager.broadcastCharLastDictChanged()
            }
            
        }
        
    }
    // 設置buttons可選否
    private func btnsEnabled(_ index: Int) {
//        self.decreaseButton[index].isEnabled = true
//        self.increaseButton[index].isEnabled = true
//        self.playPauseButton[index].isEnabled = true
//        self.milkingButton[index].isEnabled = true
//        self.massageButton[index].isEnabled = true
        self.turnOffButton[index].isEnabled = true
    }
    private func btnsDisable(_ index: Int) {
//        self.decreaseButton[index].isEnabled = false
//        self.increaseButton[index].isEnabled = false
//        self.playPauseButton[index].isEnabled = false
//        self.milkingButton[index].isEnabled = false
//        self.massageButton[index].isEnabled = false
        self.turnOffButton[index].isEnabled = false
    }
    
    /// Left BarButtonItem Action
    @objc private func showPrefMenu() {
        let storyboard = UIStoryboard(name: .Preference)
        let vc = storyboard.instantiateVC(withClass: PersonalPreferenceTableViewController.self)
        show(vc, sender: self)
    }
    /// Right BarButtonItem Action
    @objc private func showDeviceList() {
        // 手機藍芽開啟時, 才允許加入裝置
        if bleManager.isBluetoothOn, let vc = storyboard?.instantiateVC(withClass: DeviceListViewController.self) {
            // 從第二頁傳值過來用
            vc.delegate = self
            show(vc, sender: self)

        } else {
            AlertManager.showConfirmAlert(title: "注意", subtitle: "請開啟手機藍芽")

        }
    }
    
    /// 更新特徵狀態
    private func didUpdateValueForUiState() {
        // MARK: 預設為連線的第一台才可切左右
        if bleManager.connectedDevices.count == 2,
           stringValue(at: charDict[GATT.BREAST_SIDE]) == Left,
           stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left
        {
            guard let uuid = deviceUUID(from: charLastDict) else { return }
            guard let device = bleConnectedDevice(has: uuid) else { return }
            
            let data = Data(hexString: Right)
            // MARK: 寫入右邊
            device.peripheral.writeValue(data!,
                                         for: charLastDict[GATT.BREAST_SIDE]!,
                                         type: .withResponse)
//            bleManager.connectedDevices.filter {
//                $0.peripheral.identifier.uuidString == uuid
//            }.first?.peripheral.writeValue(data!,
//                                           for: charLastDict[GATT.BREAST_SIDE]!,
//                                           type: .withResponse)
            
        } else if bleManager.connectedDevices.count == 2,
                  stringValue(at: charDict[GATT.BREAST_SIDE]) == Right,
                  stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right
        {
            guard let uuid = deviceUUID(from: charLastDict) else { return }
            guard let device = bleConnectedDevice(has: uuid) else { return }
            
            let data = Data(hexString: Left)
            // MARK: 寫入左邊
            device.peripheral.writeValue(data!,
                                         for: charLastDict[GATT.BREAST_SIDE]!,
                                         type: .withResponse)
//            bleManager.connectedDevices.filter {
//                $0.peripheral.identifier.uuidString == uuid
//            }.first?.peripheral.writeValue(data!,
//                                           for: charLastDict[GATT.BREAST_SIDE]!,
//                                           type: .withResponse)
        }
        // MARK: - 可切左右的那台, 必須在另一台是暫停時才可切
        if bleManager.connectedDevices.count == 2,
           stringValue(at: charDict[GATT.BREAST_SIDE]) == Left,
           stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left,
           stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play
        {
            guard let uuid = deviceUUID(from: charDict) else { return }
            guard let device = bleConnectedDevice(has: uuid) else { return }

            let dat = Data(hexString: Right)
            // 寫入右邊
            device.peripheral.writeValue(dat!,
                                         for: charDict[GATT.BREAST_SIDE]!,
                                         type: .withResponse)
//            bleManager.connectedDevices.filter {
//                $0.peripheral.identifier.uuidString == uuid
//            }.first?.peripheral.writeValue(dat!,
//                                           for: charDict[GATT.BREAST_SIDE]!,
//                                           type: .withResponse)
            
        } else if bleManager.connectedDevices.count == 2,
                  stringValue(at: charDict[GATT.BREAST_SIDE]) == Right,
                  stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right,
                  stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play
        {
            guard let uuid = deviceUUID(from: charDict) else { return }
            guard let device = bleConnectedDevice(has: uuid) else { return }
            
            let dat = Data(hexString: Left)
            // 寫入左邊
            device.peripheral.writeValue(dat!,
                                         for: charDict[GATT.BREAST_SIDE]!,
                                         type: .withResponse)
//            bleManager.connectedDevices.filter {
//                $0.peripheral.identifier.uuidString == uuid
//            }.first?.peripheral.writeValue(dat!,
//                                           for: charDict[GATT.BREAST_SIDE]!,
//                                           type: .withResponse)
            
        } else if bleManager.connectedDevices.count == 2,
                  stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left,
                  stringValue(at: charDict[GATT.BREAST_SIDE]) == Left,
                  stringValue(at: charDict[GATT.PUMP_STATUS]) == Play
        {
            guard let uuid = deviceUUID(from: charLastDict) else { return }
            guard let device = bleConnectedDevice(has: uuid) else { return }

            let dat = Data(hexString: Right)
            // 寫入右邊
            device.peripheral.writeValue(dat!,
                                         for: charLastDict[GATT.BREAST_SIDE]!,
                                         type: .withResponse)
//            bleManager.connectedDevices.filter {
//                $0.peripheral.identifier.uuidString == uuid
//            }.first?.peripheral.writeValue(dat!,
//                                           for: charLastDict[GATT.BREAST_SIDE]!,
//                                           type: .withResponse)
            
        } else if bleManager.connectedDevices.count == 2,
                  stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right,
                  stringValue(at: charDict[GATT.BREAST_SIDE]) == Right,
                  stringValue(at: charDict[GATT.PUMP_STATUS]) == Play
        {
            guard let uuid = deviceUUID(from: charLastDict) else { return }
            guard let device = bleConnectedDevice(has: uuid) else { return }

            let dat = Data(hexString: Left)
            // 寫入左邊
            device.peripheral.writeValue(dat!,
                                         for: charLastDict[GATT.BREAST_SIDE]!,
                                         type: .withResponse)
//            bleManager.connectedDevices.filter {
//                $0.peripheral.identifier.uuidString == uuid
//            }.first?.peripheral.writeValue(dat!,
//                                           for: charLastDict[GATT.BREAST_SIDE]!,
//                                           type: .withResponse)
        }
        
        
        // 判斷連線可能無法用在此處
        // 判斷左右
        if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
            
            if bleManager.connectedDevices.count == 1 { resetRightViews() }
            // 更新電池電量
            updateBatteryLevel(from: charDict, indexStr: Left)
            // 更新連線時間
            // 更新集乳量
//            func updateCharDictMilk() {
//                if let liquidHeight = charDict[GATT.LIQUID_HEIGHT]?.value?.first
//    //               let lh = String(data: liquidHeight, encoding: .utf8)
//    //               let lh = NSString(data: liquidHeight, encoding: String.Encoding.utf8.rawValue)
//                {
//    //                let lh = String(decoding: liquidHeight, as: UTF8.self)
//                    let lh = Int(liquidHeight)
//                    let text = "\(liquidHeight) mL"
//
//                    DispatchQueue.main.async {
//                        if lh == 120 {
//                            self.mlLabel[0].attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.red])
//                        } else {
//                            self.mlLabel[0].attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: self.titleColor])
//                        }
//                    }
//                }
//            }

            // MARK: 更新強度
            if let level = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
               let lv = Int(level) {
                DispatchQueue.main.async {
                    self.strengthLabel[0].text = "\(lv)"
                }
            }
            // MARK: 更新啟動與暫停
            if stringValue(at: charDict[GATT.PUMP_STATUS]) == Pause {
                DispatchQueue.main.async {
                    self.playPauseButton[0].setImage(UIImage(named: "play"), for: .normal)
                }
            } else if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
                DispatchQueue.main.async { [self] in
                    // 更新集乳量
                    updateMlLabel(from: charDict, toIndex: 0)
                    playPauseButton[0].setImage(UIImage(named: "pause"), for: .normal)
                }
            }
            // MARK: 更新模式
            if stringValue(at: charDict[GATT.OPERATION_MODE]) == Massage {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 0, countRef: autoCount, modeRef: Massage)
                }
                
            } else if stringValue(at: charDict[GATT.OPERATION_MODE]) == Milking {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 0, countRef: autoCount, modeRef: Milking)
                }
            }
            // MARK: 更新配對狀態
            guard let uuidStr = deviceUUID(from: charDict) else { return }
//            if bleManager.connectedDevices.filter({ $0.peripheral.identifier.uuidString == uuidStr }).first?.peripheral.state == .connected
            if bleConnectedDevice(has: uuidStr)?.peripheral.state == .connected {
                
                DispatchQueue.main.async {
                    // 確定在操作頁, 且碼表停止, 才開始更新連線時間
                    if self.presentedViewController == nil && !self.stopwatch.isRunning {
                        self.setupConnectingTime()
                    }
                    self.setMlLabel(0)
                    self.bleStateButton[0].setImage(UIImage(named: "blueTooth_On"), for: .normal)
                    self.setTurnOffButton(0)
                    
                }
            } else {
                resetLeftViews()
                DispatchQueue.main.async {
                    self.bleStateButton[0].setImage(UIImage(named: "blueTooth_Off"), for: .normal)
                }
            }

        } else if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
            
            if bleManager.connectedDevices.count == 1 { resetLeftViews() }
            // 更新電池電量
            updateBatteryLevel(from: charDict, indexStr: Right)
            
            // 更新連線時間
            // 更新集乳量

            // MARK: 更新強度
            if let level = charDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
               let lv = Int(level) {
                DispatchQueue.main.async {
                    self.strengthLabel[1].text = "\(lv)"
                }
            }
            // MARK: 更新啟動與暫停
            if stringValue(at: charDict[GATT.PUMP_STATUS]) == Pause {
                DispatchQueue.main.async {
                    self.playPauseButton[1].setImage(UIImage(named: "play"), for: .normal)
                }
            } else if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {
                DispatchQueue.main.async { [self] in
                    // 更新集乳量
                    updateMlLabel(from: charDict, toIndex: 1)
                    playPauseButton[1].setImage(UIImage(named: "pause"), for: .normal)
                }
            }
            // MARK: 更新模式
            if stringValue(at: charDict[GATT.OPERATION_MODE]) == Massage {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 1, countRef: autoCount, modeRef: Massage)
                }
                
            } else if stringValue(at: charDict[GATT.OPERATION_MODE]) == Milking {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 1, countRef: autoCount, modeRef: Milking)
                }
            }
            // MARK: 更新配對狀態
            guard let uuidStr = deviceUUID(from: charDict) else { return }
//            if bleManager.connectedDevices.filter({ $0.peripheral.identifier.uuidString == uuidStr }).first?.peripheral.state == .connected
            if bleConnectedDevice(has: uuidStr)?.peripheral.state == .connected {
                
                DispatchQueue.main.async {
                    // 確定在操作頁面, 且碼表停止, 才開始更新連線時間
                    if self.presentedViewController == nil && !self.stopwatch.isRunning {
                        self.setupConnectingTime()
                    }
                    self.setMlLabel(1)
                    self.bleStateButton[1].setImage(UIImage(named: "blueTooth_On"), for: .normal)
                    self.setTurnOffButton(1)

                }
            } else {
                resetRightViews()
                DispatchQueue.main.async {
                    self.bleStateButton[1].setImage(UIImage(named: "blueTooth_Off"), for: .normal)
                }
            }
        }
        
        // MARK: - 以下charLastDict
        if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
            
            if bleManager.connectedDevices.count == 1 { resetRightViews() }
            // 更新電池電量
            updateBatteryLevel(from: charLastDict, indexStr: Left)
            
            // 更新連線時間
            // 更新集乳量

            // MARK: 更新強度
            if let level = charLastDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
               let lv = Int(level) {
                DispatchQueue.main.async {
                    self.strengthLabel[0].text = "\(lv)"
                }
            }
            // MARK: 更新啟動與暫停
            if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Pause {
                DispatchQueue.main.async {
                    self.playPauseButton[0].setImage(UIImage(named: "play"), for: .normal)
                }
            } else if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
                DispatchQueue.main.async { [self] in
                    // 更新集乳量
                    updateMlLabel(from: charLastDict, toIndex: 0)
                    playPauseButton[0].setImage(UIImage(named: "pause"), for: .normal)
                }
            }
            // MARK: 更新模式
            if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Massage {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 0, countRef: autoLastCount, modeRef: Massage)
                }
                
            } else if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Milking {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 0, countRef: autoLastCount, modeRef: Milking)
                }
            }
            // MARK: 更新配對狀態
            guard let uuidStr = deviceUUID(from: charLastDict) else { return }
//            if bleManager.connectedDevices.filter({ $0.peripheral.identifier.uuidString == uuidStr }).first?.peripheral.state == .connected
            if bleConnectedDevice(has: uuidStr)?.peripheral.state == .connected {
                
                DispatchQueue.main.async {
                    // 確定在操作頁面, 且碼表停止, 才開始更新連線時間
                    if self.presentedViewController == nil && !self.stopLastWatch.isRunning {
                        self.setupConnectingLastTime()
                    }
                    self.setMlLabel(0)
                    self.bleStateButton[0].setImage(UIImage(named: "blueTooth_On"), for: .normal)
                    self.setTurnOffButton(0)

                }
            } else {
                resetLeftViews()
                DispatchQueue.main.async {
                    self.bleStateButton[0].setImage(UIImage(named: "blueTooth_Off"), for: .normal)
                }
            }

        } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
            
            if bleManager.connectedDevices.count == 1 { resetLeftViews() }
            // 更新電池電量
            updateBatteryLevel(from: charLastDict, indexStr: Right)
            
            // 更新連線時間
            // 更新集乳量

            // MARK: 更新強度
            if let level = charLastDict[GATT.PUMP_LEVEL]?.value?.hexToStr(),
               let lv = Int(level) {
                DispatchQueue.main.async {
                    self.strengthLabel[1].text = "\(lv)"
                }
            }
            // MARK: 更新啟動與暫停
            if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Pause {
                DispatchQueue.main.async {
                    self.playPauseButton[1].setImage(UIImage(named: "play"), for: .normal)
                }
            } else if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
                DispatchQueue.main.async { [self] in
                    // 更新集乳量
                    updateMlLabel(from: charLastDict, toIndex: 1)
                    playPauseButton[1].setImage(UIImage(named: "pause"), for: .normal)
                }
            }
            // MARK: 更新模式
            if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Massage {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 1, countRef: autoLastCount, modeRef: Massage)
                }
                
            } else if stringValue(at: charLastDict[GATT.OPERATION_MODE]) == Milking {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    updateModeButtons(atIndex: 1, countRef: autoLastCount, modeRef: Milking)
                }
            }
            // MARK: 更新配對狀態
            guard let uuidStr = deviceUUID(from: charLastDict) else { return }
//            if bleManager.connectedDevices.filter({ $0.peripheral.identifier.uuidString == uuidStr }).first?.peripheral.state == .connected
            if bleConnectedDevice(has: uuidStr)?.peripheral.state == .connected {
                
                DispatchQueue.main.async {
                    // 確定在操作頁面, 且碼表停止, 才開始更新連線時間
                    if self.presentedViewController == nil && !self.stopLastWatch.isRunning {
                        self.setupConnectingLastTime()
                    }
                    self.setMlLabel(1)
                    self.bleStateButton[1].setImage(UIImage(named: "blueTooth_On"), for: .normal)
                    self.setTurnOffButton(1)

                }
            } else {
                resetRightViews()
                DispatchQueue.main.async {
                    self.bleStateButton[1].setImage(UIImage(named: "blueTooth_Off"), for: .normal)
                }
            }
        }


    }
    
    // MARK: - 更新集乳量（在啟動狀態才更新）
    private func updateMlLabel(from dict: [CBUUID : CBCharacteristic], toIndex: Int) {
        if let liquidHeight = dict[GATT.LIQUID_HEIGHT]?.value?.first
//               let lh = String(data: liquidHeight, encoding: .utf8)
//               let lh = NSString(data: liquidHeight, encoding: String.Encoding.utf8.rawValue)
        {
//                let lh = String(decoding: liquidHeight, as: UTF8.self)
            let lh = Int(liquidHeight)
            let text = "\(liquidHeight) mL"

//            DispatchQueue.main.async {
            if lh == 120 {
                self.mlLabel[toIndex].attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.red])
            } else {
                self.mlLabel[toIndex].attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: self.titleColor])
            }
//            }
        }
    }
    
    // MARK: - 設置連線時間
    private func setupConnectingTime() {
//        guard timer == nil else { return }
//        timer =
        Timer.scheduledTimer(timeInterval: 0.1, target: self,
                             selector: #selector(updateElapsedTimeLabel(_:)),
                             userInfo: nil, repeats: true)
        stopwatch.start()
    }
    
    @objc private func updateElapsedTimeLabel(_ timer: Timer) {
//        print("Updating...")
        if stopwatch.isRunning {
            let minutes = Int(stopwatch.elapsedTime / 60)
            let seconds = Int(stopwatch.elapsedTime.truncatingRemainder(dividingBy: 60))
//            let tenthsOfSecond =
//            Int((stopwatch.elapsedTime * 10).truncatingRemainder(dividingBy: 10))
            
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                timeLabel[0].text = String(format: "%02d:%02d", minutes, seconds)
                
            } else if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                timeLabel[1].text = String(format: "%02d:%02d", minutes, seconds)
            }

        } else {
            timer.invalidate()
//            self.timer = nil
        }
    }
    
    private func setupConnectingLastTime() {
//        guard lastTimer == nil else { return }
//        lastTimer =
        Timer.scheduledTimer(timeInterval: 0.1, target: self,
                             selector: #selector(updateElapsedLastTimeLabel),
                             userInfo: nil, repeats: true)
        stopLastWatch.start()
    }
    
    @objc private func updateElapsedLastTimeLabel(_ timer: Timer) {
//        print("Updating...")
        if stopLastWatch.isRunning {
            let minutes = Int(stopLastWatch.elapsedTime / 60)
            let seconds = Int(stopLastWatch.elapsedTime.truncatingRemainder(dividingBy: 60))
//            let tenthsOfSecond
//            = Int((stopwatch.elapsedTime * 10).truncatingRemainder(dividingBy: 10))
            
            if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                timeLabel[0].text = String(format: "%02d:%02d", minutes, seconds)
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                timeLabel[1].text = String(format: "%02d:%02d", minutes, seconds)
            }
            
        } else {
            timer.invalidate()
//            self.lastTimer = nil
        }
    }
    
    // MARK: - 更新電池電量
    private func updateBatteryLevel(from dict: [CBUUID: CBCharacteristic], indexStr: String) {
//        guard let battLevel = Int(stringValue(at: dict[GATT.BATTERY_LEVEL])),
//                let index = Int(indexStr) else { return }
        guard let battLevel = dict[GATT.BATTERY_LEVEL]?.value?.first,
                let index = Int(indexStr) else { return }
        
        DispatchQueue.main.async {
            if 0 < battLevel && battLevel < 20 {
                let animatedImage = UIImage.animatedImageNamed("battery_low-",
                                                               duration: 0.75)
                self.batteryImageView[index].image = animatedImage
                

                
                if self.presentedViewController == nil {
                    let alertVC = UIStoryboard(name: .LowBatteryStoryboard).instantiateVC(withClass: LowBatteryAlertViewController.self)
                    self.present(alertVC, animated: true, completion: nil)
                }
            } else if battLevel == 20 {
                let animatedImage = UIImage.animatedImageNamed("battery_low-",
                                                               duration: 0.75)
                self.batteryImageView[index].image = animatedImage

            } else if 20 < battLevel && battLevel < 50 {
                self.batteryImageView[index].image = UIImage(named: "battery_25")

            } else if battLevel >= 50 && battLevel < 75 {
                self.batteryImageView[index].image = UIImage(named: "battery_50")

            } else if battLevel >= 75 && battLevel < 100 {
                self.batteryImageView[index].image = UIImage(named: "battery_75")

            } else if battLevel == 100 {
                self.batteryImageView[index].image = UIImage(named: "battery_100")
            }
            
        }
    }
    
    /// 連線後設置
    private func setMlLabel(_ index: Int) {
        if mlLabel[index].text == "-- mL" {
            mlLabel[index].text = "0 mL"
        }
    }
    // resetMlLabel（內函數）
    private func resetMlLabel(_ index: Int) {
        let text = "-- mL"
        self.mlLabel[index].attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: self.titleColor])
    }
    
    /// 連線後設置，否則顯示尚未配對
    private func setTurnOffButton(_ index: Int) {
        turnOffButton[index].backgroundColor = turnOffBtnColor
        turnOffButton[index].setTitle("結束吸乳", for: .normal)
        turnOffButton[index].setTitleColor(.white, for: .normal)
        btnsEnabled(index)
    }
    // resetTurnOffButton（內函數）
    private func resetTurnOffButton(_ index: Int) {
        turnOffButton[index].backgroundColor = systemGrayFive
        turnOffButton[index].setTitle("尚未配對", for: .normal)
        turnOffButton[index].setTitleColor(titleColor, for: .normal)
        btnsDisable(index)
    }
    
    /// 連線後設置，否則顯示灰色主題
    private func updateModeButtons(atIndex: Int, countRef: Int, modeRef: String) {
        func setModeButton(_ button: UIButton) {
//            button.titleLabel?.tintColor = .white
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = themeColor.cgColor
//            button.layer.borderWidth = 1
        }
        setModeButton(autoButton[atIndex])
        setModeButton(milkingButton[atIndex])
        setModeButton(massageButton[atIndex])
        
//        let colorBackground = countRef > 0 ? .white : themeColor
//        let colorTitle      = countRef > 0 ? themeColor : .white
        autoButton[atIndex].backgroundColor = countRef > 0 ? .white : themeColor
        autoButton[atIndex].setTitleColor(countRef > 0 ? themeColor : .white , for: .normal)
        
        if modeRef == Massage {
            milkingButton[atIndex].backgroundColor = .white
            milkingButton[atIndex].setTitleColor(themeColor, for: .normal)
            massageButton[atIndex].backgroundColor = themeColor
            massageButton[atIndex].setTitleColor(.white, for: .normal)
            
        } else if modeRef == Milking {
            massageButton[atIndex].backgroundColor = .white
            massageButton[atIndex].setTitleColor(themeColor, for: .normal)
            milkingButton[atIndex].backgroundColor = themeColor
            milkingButton[atIndex].setTitleColor(.white, for: .normal)
        }

    }
    
    // resetViews
    private func resetViews(_ index: Int) {
        DispatchQueue.main.async {
            self.batteryImageView[index].image = UIImage(named: "battery_null")
            self.timeLabel[index].text = "--:--"
            
            self.resetMlLabel(index)
//            let text = "-- mL"
//            self.mlLabel[index].attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: self.titleColor])
            
            self.bleStateButton[index].setImage(UIImage(named: "blueTooth_Off"),
                                                for: .normal)
            self.strengthLabel[index].text = "--"
            self.playPauseButton[index].setImage(UIImage(named: "play"),
                                                 for: .normal)
            self.resetMode(index)
            self.resetTurnOffButton(index)
        }
    }
    private func resetLeftViews()  { resetViews(0) }
    private func resetRightViews() { resetViews(1) }
    
    // resetMode（內函數）
    private func resetMode(_ index: Int) {
        func setModeButton(_ button: UIButton) {
            button.backgroundColor = .white
            button.setTitleColor(titleColor, for: .normal)
//            button.layer.cornerRadius = 25
            button.layer.borderColor = systemGrayFive.cgColor
//            button.layer.borderWidth = 1
        }

        setModeButton(autoButton[index])
        setModeButton(milkingButton[index])
        setModeButton(massageButton[index])
        
    }
//    private func resetLeftMode() { resetMode(0) }
//    private func resetRightMode() { resetMode(1) }
    
    private func configureUI() {
        // 設定navigationBar顯圖與buttonAction
        let leftBarItem = UIBarButtonItem(image: prefMenuImage, style: .plain,
                                          target: self, action: #selector(showPrefMenu))
        navigationItem.setLeftBarButton(leftBarItem, animated: true)
        
        let rightBarItem = UIBarButtonItem(image: addDeviceImage, style: .plain,
                                           target: self, action: #selector(showDeviceList))
        navigationItem.setRightBarButton(rightBarItem, animated: true)
        
        // 處理顯示日期
        let date = Date()
        let current = Calendar.current
        let year = current.component(.year, from: date)
        let day = current.component(.day, from: date)
        let month = current.component(.month, from: date)
        dateLabel.text = "\(year).\(month).\(day)"
        
        // 設置底層view
        setupLeftRightView()

        // 強度底view
        leftStrenthView.layer.cornerRadius = 35
        leftStrenthView.layer.borderColor = themeColor.cgColor
        leftStrenthView.layer.borderWidth = 2.5
        rightStrenthView.layer.cornerRadius = 35
        rightStrenthView.layer.borderColor = themeColor.cgColor
        rightStrenthView.layer.borderWidth = 2.5
        
        // 連線時間
        for timeLbl in timeLabel {
            timeLbl.text = "--:--"
        }
        
        // 電池電量
        for batteryImgView in batteryImageView {
            batteryImgView.image = UIImage(named: "battery_null")
        }
        
        // 乳量顯示
        for mlLbl in mlLabel {
            mlLbl.text = "-- mL"
            mlLbl.textColor = titleColor
        }
        
        // 配對與否
        for bleStateBtn in bleStateButton {
            bleStateBtn.setImage(UIImage(named: "blueTooth_Off"), for: .normal)
        }
        
        // strengthLabel
        for strengthLbl in strengthLabel {
            strengthLbl.text = "--"
        }
        
        // playPauseButton
        for playPauseBtn in playPauseButton {
            playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
        }
        
        // 模式buttons
        setupModeButtons(autoButton)
        setupModeButtons(milkingButton)
        setupModeButtons(massageButton)
        
        // 結束吸乳鍵
        for turnOffBtn in turnOffButton {
            turnOffBtn.backgroundColor = systemGrayFive
            turnOffBtn.setTitle("尚未配對", for: .normal)
            turnOffBtn.setTitleColor(titleColor, for: .normal)
            turnOffBtn.layer.cornerRadius = 20
            turnOffBtn.isEnabled = false
        }
        
        setupConstraints()
    }
    
    private func setupModeButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.backgroundColor = .white
            button.setTitleColor(titleColor, for: .normal)
            button.layer.cornerRadius = 25
            button.layer.borderColor = systemGrayFive.cgColor
            button.layer.borderWidth = 1
        }
    }
    
    private func setupLeftRightView() {
        //左半邊的view呈現圓弧形
        var leftPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 185, height: 375), byRoundingCorners: [.topRight,.bottomRight], cornerRadii: CGSize(width: 100, height: 0))
        //右半邊的view呈現圓弧形
        var rightPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 185, height: 375), byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: 100, height: 0))
        
        //若手機大於4.7吋調整畫面
        if screenWidth > 400 {
            leftView.frame = CGRect(x: 0, y: 0, width: 200, height: 430)
            leftPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 185, height: 430), byRoundingCorners: [.topRight,.bottomRight], cornerRadii: CGSize(width: 120, height: 0))
            rightView.frame = CGRect(x: 0, y: 0, width: 200, height: 430)
            rightPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 185, height: 430), byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: 120, height: 0))
        }
        
        let leftShapeLayer = CAShapeLayer()
        leftShapeLayer.path = leftPath.cgPath
        leftView.layer.mask = leftShapeLayer
        let rightShapeLayer = CAShapeLayer()
        rightShapeLayer.path = rightPath.cgPath
        rightView.layer.mask = rightShapeLayer
        
        //Add Border
        let leftBorderLayer = CAShapeLayer()
        leftBorderLayer.path = leftShapeLayer.path
        leftBorderLayer.fillColor = UIColor.clear.cgColor
        leftBorderLayer.strokeColor = themeColor.cgColor
        leftBorderLayer.lineWidth = 5
        leftBorderLayer.frame = leftView.bounds
//        leftView.layer.addSublayer(leftBorderLayer)
        
        let rightBorderLayer = CAShapeLayer()
        rightBorderLayer.path = rightShapeLayer.path
        rightBorderLayer.fillColor = UIColor.clear.cgColor
        rightBorderLayer.strokeColor = themeColor.cgColor
        rightBorderLayer.lineWidth = 5
        rightBorderLayer.frame = rightView.bounds
//        rightView.layer.addSublayer(rightBorderLayer)

        // Add Gradient Border
        let lightCgColor = lightThemeColor.cgColor
        let deepCgColor = themeColor.cgColor
        
        let leftGradient = CAGradientLayer()
        leftGradient.frame = leftBorderLayer.bounds
        leftGradient.colors = [lightCgColor, deepCgColor]
        leftGradient.mask = leftBorderLayer
        leftView.layer.addSublayer(leftGradient)
        
        let rightGradient = CAGradientLayer()
        rightGradient.frame = rightBorderLayer.bounds
        rightGradient.colors = [lightCgColor, deepCgColor]
        rightGradient.mask = rightBorderLayer
        rightView.layer.addSublayer(rightGradient)
        
    }
        
    private func setupConstraints() { // 不調整375pt * 812pt
        
        if screenHeight > 830 {
            // 下移（ 原16 ）
            lViewTopConstraint.constant = 55
            rViewTopConstraint.constant = 55
            // 上移（ 原-16 ）
            lStackBottomConstraint.constant = -32
            rStackBottomConstraint.constant = -32

        } else if screenHeight > 700 && screenHeight < 810 { // 僅調整 414pt * 736pt
            // 上移（ 原24、60、16 ）
            opTopConstraint.constant = 0
            dateTopConstraint.constant = 36
            lViewTopConstraint.constant = 0
            rViewTopConstraint.constant = 0

        } else if screenHeight > 600 && screenHeight < 700 {
            // 上移（ 原24、60、16 ）
            opTopConstraint.constant = 0
            dateTopConstraint.constant = 36
            lViewTopConstraint.constant = 0
            rViewTopConstraint.constant = 0
            // 下移（ 原-16 ）
            lStackBottomConstraint.constant = -8
            rStackBottomConstraint.constant = -8
            
        } else if screenHeight < 600 {
            // 上移（ 原24、60 ）
            opTopConstraint.constant = 0
            dateTopConstraint.constant = 36
            
            leftView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75).translatedBy(x: -20, y: -80)
            rightView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75).translatedBy(x: 20, y: -80)
            leftStack.transform = CGAffineTransform(scaleX: 0.75, y: 0.75).translatedBy(x: -20, y: 0)
            rightStack.transform = CGAffineTransform(scaleX: 0.75, y: 0.75).translatedBy(x: 20, y: 0)
            
            // 下移（ 原-16 ）
            lStackBottomConstraint.constant = -8
            rStackBottomConstraint.constant = -8
        }
    }


}

// MARK: - Notification Center
private extension OperationViewController {
    func setupListener() {
        // 取回特徵字典
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(retrieveCharDict(noti:)),
                                               name: .retrieveCharDict, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(retrieveCharLastDict(noti:)),
                                               name: .retrieveCharLastDict, object: nil)
        // 監聽裝置連線
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bleConnected(noti:)),
                                               name: .didConnectedDevice, object: nil)
        // 監聽裝置斷線
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bleDisconnected(noti:)),
                                               name: .didDisconnectedDevice, object: nil)
    }
}

extension OperationViewController: DeviceListViewControllerDelegate {
    func sendDataToOperationVC() {
        // 這邊為接值的邏輯
    }
    
    
}

// MARK: - ShutdownAlertViewDelegate
extension OperationViewController: ShutdownAlertViewDelegate {
    func buttonTapped(sender: ShutdownAlertView) {
        sender.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    
    func confirmTapped(sender: ShutdownAlertView) {
        switch sideJudge {
        case Left:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                
                if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {

                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                }

                stopwatch.stop()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.bleManager.disconnectDeviceActively(device)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Left {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                
                if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
                    
                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                }
                
                stopLastWatch.stop()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.bleManager.disconnectDeviceActively(device)
                }
                
            }
        case Right:
            if stringValue(at: charDict[GATT.BREAST_SIDE]) == Right {
                   
                guard let uuidStr = deviceUUID(from: charDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }
                
                
                if stringValue(at: charDict[GATT.PUMP_STATUS]) == Play {

                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                }

                stopwatch.stop()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.bleManager.disconnectDeviceActively(device)
                }
                
            } else if stringValue(at: charLastDict[GATT.BREAST_SIDE]) == Right {
                
                guard let uuidStr = deviceUUID(from: charLastDict) else { return }
                guard let device = bleConnectedDevice(has: uuidStr) else { return }

                
                if stringValue(at: charLastDict[GATT.PUMP_STATUS]) == Play {
                    
                    let data = Data(hexString: Pause)
                    // MARK: 寫入暫停
                    device.peripheral.writeValue(data!,
                                                 for: charLastDict[GATT.PUMP_STATUS]!,
                                                 type: .withResponse)
                }
                
                stopLastWatch.stop()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.bleManager.disconnectDeviceActively(device)
                }
                
            }
        default: break
        }
        
        backgroundView.removeFromSuperview()
    }
    
}
