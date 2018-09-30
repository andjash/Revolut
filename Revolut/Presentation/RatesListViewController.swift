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
        tableView.register(UINib(nibName: String(describing: RateCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RateCell.self))
        tableView.alpha = 0
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        presenter.viewIsReady()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RateCell.self)) as! RateCell
        bind(entry: data[indexPath.row], toCell: cell)
        cell.textField.delegate = self
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
        if (activityIndicator.isAnimating) {
            activityIndicator.alpha = 0
            activityIndicator.stopAnimating()
            tableView.alpha = 1
        }
        
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
        tableView.moveRow(at: IndexPath(row: atIndex, section: 0), to: zeroIp)
        tableView.scrollToRow(at: zeroIp, at: .top, animated: true)
        
        for ip in tableView.indexPathsForVisibleRows ?? [] {
            if let cell = tableView.cellForRow(at: ip) as? RateCell {
                if (ip.row == 0) {
                    cell.textField.becomeFirstResponder()
                }
                cell.textField.indexPath = ip
            }
        }
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
