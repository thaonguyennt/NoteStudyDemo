//
//  AddWordView.swift
//  NoteStudyDemo
//
//  Created by Kathy on 27/10/2023.
//

import Foundation
import UIKit
protocol AddWordViewDelegete: AnyObject {
    func saveWord(vn: String?, kr: String?)
}
class AddWordView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var vnTextField: UITextField!
    @IBOutlet weak var krTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var bgView: UIView!

    var parentView: ViewController?
    weak var delegete: AddWordViewDelegete?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayoutView()
    }
    func setupLayoutView(){
        Bundle.main.loadNibNamed("AddWordView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.layer.cornerRadius = 10
        saveBtn.layer.cornerRadius = 10
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let vnText = vnTextField.text, !vnText.isEmpty,
           let krText = krTextField.text, !vnText.isEmpty
        
        {
            delegete?.saveWord(vn: vnText, kr: krText)
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Word", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            parentView?.present(alert, animated: true)
        }
    }
}
