//
//  SwitchTableViewCell.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 8/18/22.
//

import UIKit
import Reusable

protocol SwitchTableViewCellDelegate: AnyObject {
    /// - parameter switchValueChangedTo: Should fire for `UIControl.Event.valueChanged`. Pass it the new `isOn` value of the cell's UISwitch.
    func switchTableViewCell(_ cell: SwitchTableViewCell, didChangeSwitchValueTo isOn: Bool)
}

class SwitchTableViewCell: UITableViewCell, Reusable {
    weak var switchDelegate: SwitchTableViewCellDelegate?

    /// User setting to toggle the option to save clips to the photos library.
    let saveVideosSwitch: UISwitch = {
        let _switch = UISwitch()
        _switch.onTintColor = .systemBlue
        _switch.isOn = UserDefaults.standard.bool(forKey: L10n.UserSettings.shouldSaveVideosKey)
        return _switch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        selectionStyle = .none
        accessoryView = saveVideosSwitch
        saveVideosSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
    }
    
    @objc
    func switchValueDidChange(_ sender: UISwitch) {
        switchDelegate?.switchTableViewCell(self, didChangeSwitchValueTo: sender.isOn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

