//
//  ImageDetailsCell.swift
//  LambdaTimeline
//
//  Created by Jason Modisett on 1/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol ImageDetailsCellDelegate: class {
    func textFieldBeganEditing(textFieldText: String)
    func textFieldTextChanged(to text: String)
    func textFieldEndedEditing()
    func beautifyButtonPressed()
}

class ImageDetailsCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        imageDescriptionTextField.delegate = self
        imageDescriptionTextField.addTarget(self, action: #selector(ImageDetailsCell.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    private func updateViews() {
        if isBeautifyDisabled {
            beautifyButton.alpha = 0.2
            beautifyButton.isUserInteractionEnabled = false
        } else {
            beautifyButton.alpha = 1.0
            beautifyButton.isUserInteractionEnabled = true
        }
    }

    @IBAction func beautifyButtonPressed(_ sender: Any) {
        delegate?.beautifyButtonPressed()
        isBeautifyOn = !isBeautifyOn
        let title = isBeautifyOn == true ? "TURN OFF BEAUTIFY ✨" : "TURN ON BEAUTIFY ✨"
        beautifyButton.backgroundColor = isBeautifyOn == true ? UIColor(named: "LambdaDark")! : UIColor(named: "Lambda")!
        beautifyButton.setTitle(title, for: .normal)
    }
    
    weak var delegate: ImageDetailsCellDelegate?
    var isBeautifyDisabled: Bool = true { didSet { updateViews() }}
    var isBeautifyOn: Bool = false
    
    @IBOutlet weak var beautifyButton: UIButton!
    @IBOutlet weak var imageDescriptionTextField: UITextField!
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldTextChanged(to: imageDescriptionTextField.text ?? "")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldBeganEditing(textFieldText: textField.text ?? "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        imageDescriptionTextField.resignFirstResponder()
        delegate?.textFieldEndedEditing()
        return true
    }

}
