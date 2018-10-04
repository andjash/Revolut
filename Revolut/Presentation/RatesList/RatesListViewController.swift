//
//  RatesListViewController.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import UIKit
import ObjectiveC

class RatesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RatesListPresenterDelegate, UITextFieldDelegate {
    
    let presenter: RatesListPresenter
    
    var data: [RatesListPresenter.DataEntry] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var loadingIndicatorVisible : Bool {
        get {
            return activityIndicator.isAnimating
        }
        set {
            if newValue {
                activityIndicator.alpha = 1
                activityIndicator.startAnimating()
                tableView.alpha = 0
                placeholderLabel.alpha = 0
            } else {
                activityIndicator.alpha = 0
                activityIndicator.stopAnimating()
            }
        }
    }
    
    required init(presenter: RatesListPresenter) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
   
        self.presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: RateCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: RateCell.self))
        loadingIndicatorVisible = true
        presenter.viewIsReady()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RateCell.self)) as! RateCell
        bind(entry: data[indexPath.row], toCell: cell)
        cell.textField.delegate = self
        cell.textField.addTarget(nil, action: #selector(textFieldChanged), for: .editingChanged)
        cell.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        cell.textField.indexPath = indexPath
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RateCell {
            cell.textField.becomeFirstResponder()
        }
    }
    
    // MARK: - RatesListPresenterDelegate
    
    func display(data newData: [RatesListPresenter.DataEntry]) {
        loadingIndicatorVisible = false
        
        if (newData.count == 0) {
            displayPlacehodler(with: "No data")
            return
        }
        tableView.alpha = 1
        
        if data.count == newData.count {
            data = newData
            for ip in tableView.indexPathsForVisibleRows ?? [] {
                if let cell = tableView.cellForRow(at: ip) as? RateCell {
                    bind(entry: data[ip.row], toCell: cell)
                }
            }
        } else {
            data = newData
            tableView.reloadData()
        }
    }
    
    func focusEntry(atIndex: Int, allData: [RatesListPresenter.DataEntry]) {
        data = allData
        
        let zeroIp = IndexPath(row: 0, section: 0)
        let oldIp = IndexPath(row: atIndex, section: 0)
       
        (tableView.cellForRow(at: oldIp) as? RateCell)?.textField.indexPath = zeroIp
        tableView.moveRow(at: oldIp, to: zeroIp)
        tableView.scrollToRow(at: zeroIp, at: .top, animated: true)
        
        
        tableView.indexPathsForVisibleRows?.compactMap { ip in
            return (tableView.cellForRow(at: ip) as? RateCell).flatMap { (ip, $0) }
        }.forEach { (ip, cell) in
            cell.textField.indexPath = ip
        }
    }
    
    func display(error: String) {
        loadingIndicatorVisible = false
        displayPlacehodler(with: error)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let ip = textField.indexPath else {
            assert(false, "Editing text field without indexPath")
            
            return
        }
        
        presenter.didStartEditing(forEntry: data[ip.row], atIndex: ip.row)
    }
    
    @objc func textFieldChanged(sender: AnyObject?) {
        guard let textField = sender as? UITextField else {
            assert(false, "Wrong sender for method")
            return
        }

        guard let ip = textField.indexPath else {
            assert(false, "Editing not exisiting textfield")
            return
        }
        presenter.didEditValue(forEntry: data[ip.row], newValue: textField.text ?? "")
    }
    
    
    // MARK: - Private
    
    private func bind(entry: RatesListPresenter.DataEntry, toCell cell: RateCell) {
        cell.currencyNameLabel.text = entry.currencyName
        cell.textField.text = entry.value
    }
    
    private func displayPlacehodler(with text: String) {
        tableView.alpha = 0
        placeholderLabel.alpha = 1
        placeholderLabel.text = text
    }
    
    
    @objc private func keyboardWillHide(notification: Notification) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        let finalKeyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero
        var bottomInset = finalKeyboardFrame.height;
        
        bottomInset -= self.view.window?.safeAreaInsets.bottom ?? 0
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
    }
    
}


private extension UITextField {
    
    private static var IndexPathAssociationKey: UInt8 = 0
    
    var indexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &UITextField.IndexPathAssociationKey) as? IndexPath
        }
        set {
            objc_setAssociatedObject(self, &UITextField.IndexPathAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
