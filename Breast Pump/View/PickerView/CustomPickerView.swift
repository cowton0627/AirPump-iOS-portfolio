//
//  CustomPickerView.swift
//  Breast Pump
//
//  Created by user on 2022/5/31.
//

import UIKit

/// A helper protocol to implement option description for `EnumPicker`.
protocol Descriptable {
    var description: String { get }
}

/// A wrapper to better describe the usage of the custom pickers.
protocol WithCustomPicker { }
extension WithCustomPicker {
    /// A picker to choose between enum cases.
    /// - Parameters:
    ///   - textField: The text field to be used as trigger.
    ///   - currentState: The initial selected option of the picker when initiated
    ///   - onShow: The closure to be called when the picker shows up. Usually you can update the current state here.
    ///   - onScrolling: The closure to be called when the picker has scrolled to an option.
    ///   - onCancel: The closure to be called when the user pressed `Cancel`. Usually you have to called view.endEditing here to dismiss picker.
    ///   - onDone: The closure to be called when the user pressed `Done`. Usually you have to called view.endEditing here to dismiss picker and read the current state to know the user's decistion.
    func setEnumPicker<T: CaseIterable & Descriptable & Equatable>(on textField: UITextField, currentState: T, onShow: ((EnumPicker<T>)->())? = nil, onScrolling: ((T)->())? = nil, onCancel: @escaping (()->()), onDone: @escaping ((T)->())) {
        _ = EnumPicker(on: textField, currentState: currentState, onShow: onShow, onScrolling: onScrolling, onCancel: onCancel, onDone: onDone)
    }
    /// A picker to choose between equatable array items.
    /// - Parameters:
    ///   - textField: The text field to be used as trigger.
    ///   - list: The list of items to choose from.
    ///   - currentState: The initial selected option of the picker when initiated
    ///   - textModifier: The closure to be called when deciding how to describe the option.
    ///   - onShow: The closure to be called when the picker shows up. Usually you can update the current state here.
    ///   - onScrolling: The closure to be called when the picker has scrolled to an option.
    ///   - onCancel: The closure to be called when the user pressed `Cancel`. Usually you have to called view.endEditing here to dismiss picker.
    ///   - onDone: The closure to be called when the user pressed `Done`. Usually you have to called view.endEditing here to dismiss picker and read the current state to know the user's decistion.
    func setListPicker<T: Equatable>(on textField: UITextField, list: [T], currentState: T, textModifier: @escaping (T)->(String),  onShow: ((ListPicker<T>)->())? = nil, onScrolling: ((T)->())? = nil, onCancel: @escaping (()->()), onDone: @escaping ((T)->())) {
        _ = ListPicker(on: textField, list: list, currentState: currentState, textModifier: textModifier, onShow: onShow, onScrolling: onScrolling, onCancel: onCancel, onDone: onDone)
    }
}

/// A picker view working with an enum type.
class EnumPicker<T: CaseIterable & Descriptable & Equatable>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// The current option of the picker.
    private var _currentState: T
    
    /// The option where the scrolling stopped at.
    private var scrollingState: T
    
    private func scrollToCurrentState() {
        if let index = T.allCases.firstIndex(of: currentState) {
            self.selectRow(index as! Int, inComponent: 0, animated: false)
        }
    }

    /// You can later change this value to update the picker.
    var currentState: T {
        get { _currentState }
        set {
            _currentState = newValue
            scrollToCurrentState()
        }
    }
    
    var onScrolling: ((T)->())?
    var onDone: ((T)->())
    var onCancel: (()->())
    private let onShow: ((EnumPicker)->())?
    
    init(on textField: UITextField, currentState: T, onShow: ((EnumPicker)->())? = nil, onScrolling: ((T)->())? = nil, onCancel: @escaping (()->()), onDone: @escaping ((T)->())) {
        self._currentState = currentState
        self.scrollingState = currentState
        self.onScrolling = onScrolling
        self.onDone = onDone
        self.onCancel = onCancel
        self.onShow = onShow

        super.init(frame: .zero)
        
        let pickerBar = UIToolbar()
        let doneBarItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicking))
        let cancelBarItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicking))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerBar.setItems([cancelBarItem, flexibleSpace, doneBarItem], animated: true)
        pickerBar.sizeToFit()
        
        textField.inputView = self
        textField.inputAccessoryView = pickerBar
        
        textField.addTarget(self, action: #selector(showingPicker), for: .editingDidBegin)
        
        configureView()
    }

    @objc
    func donePicking() {
        callDidSelectRowsBeforeAnimationStop()
        _currentState = scrollingState
        onDone(currentState)
    }
    
    @objc
    func cancelPicking() { onCancel() }
    
    @objc
    func showingPicker() {
        scrollToCurrentState()
        onShow?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        self.backgroundColor = .white
        self.dataSource = self
        self.delegate = self
    }
    
    /// Update selected row before animation stops to avoid invalid selection.
    private func callDidSelectRowsBeforeAnimationStop(){
        for i in 0..<self.numberOfComponents {
            delegate?.pickerView?(self, didSelectRow: self.selectedRow(inComponent: i), inComponent: i)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { T.allCases.count }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { T.allCases[row as! T.AllCases.Index].description }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        scrollingState = T.allCases[row as! T.AllCases.Index]
        onScrolling?(currentState)
    }
}


/// A picker view working with an array.
class ListPicker<T: Equatable>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    let textModifier: (T) -> (String)
    let list: [T]
    
    /// The current option of the picker.
    private var _currentState: T
    
    /// The option where the scrolling stopped at.
    private var scrollingState: T
    
    private func scrollToCurrentState() {
        if let index = list.firstIndex(of: _currentState) {
            self.selectRow(index, inComponent: 0, animated: false)
        }
    }

    /// You can later change this value to update the picker.
    var currentState: T {
        get { _currentState }
        set {
            _currentState = newValue
            scrollToCurrentState()
        }
    }
    var onScrolling: ((T)->())?
    var onDone: ((T)->())
    var onCancel: (()->())
    private let onShow: ((ListPicker)->())?
    
    /// - Parameters:
    ///   - onShow: Triggered when the editing begin.  You can use this to update the currentState.
    init(on textField: UITextField, list: [T],  currentState: T, textModifier: @escaping (T) -> (String), onShow: ((ListPicker)->())? = nil, onScrolling: ((T)->())? = nil, onCancel: @escaping (()->()), onDone: @escaping ((T)->())) {
        self.list = list
        self._currentState = currentState
        self.scrollingState = currentState
        self.textModifier = textModifier
        self.onScrolling = onScrolling
        self.onDone = onDone
        self.onCancel = onCancel
        self.onShow = onShow

        super.init(frame: .zero)

        let pickerBar = UIToolbar()
        let doneBarItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicking))
        let cancelBarItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicking))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerBar.setItems([cancelBarItem, flexibleSpace, doneBarItem], animated: true)
        pickerBar.sizeToFit()

        textField.inputView = self
        textField.inputAccessoryView = pickerBar

        textField.addTarget(self, action: #selector(showingPicker), for: .editingDidBegin)

        configureView()
    }
    
    @objc
    func donePicking() {
        callDidSelectRowsBeforeAnimationStop()
        _currentState = scrollingState
        onDone(currentState)
    }

    @objc
    func cancelPicking() { onCancel() }

    @objc
    func showingPicker() {
        scrollToCurrentState()
        onShow?(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        self.backgroundColor = .white
        self.dataSource = self
        self.delegate = self
    }
    
    /// Update selected row before animation stops to avoid invalid selection.
    private func callDidSelectRowsBeforeAnimationStop(){
        for i in 0..<self.numberOfComponents {
            delegate?.pickerView?(self, didSelectRow: self.selectedRow(inComponent: i), inComponent: i)
        }
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { list.count }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { textModifier(list[row]) }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        scrollingState = list[row]
        onScrolling?(currentState)
    }
}


