//
//  AddWordView.swift
//  NoteStudyDemo
//
//  Created by Kathy on 27/10/2023.
//

import Foundation
import UIKit
import SafariServices
import WebKit
protocol AddWordViewDelegete: AnyObject {
    func cancelAddNewWord()
    func saveWord(vn: String?, kr: String?, isUpdate: Bool)
}
class AddWordView: UIView, UITextFieldDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var vnTextField: UITextField!
    @IBOutlet weak var krTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var vnRecordBtn: UIButton!
    @IBOutlet weak var krRecordBtn: UIButton!
    
    
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    
    private var timer: Timer?
    private var count: Double = 0.0
    
    var parentView: ViewController?
    weak var delegete: AddWordViewDelegete?
    private var isUpdate: Bool = false
    var currentVNLanguageSelected: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayoutView()
    }
    func resetValue(){
        isUpdate = false
        vnTextField.text = ""
        krTextField.text = ""
    }
    func setValue(kr: String, vn: String) {
        isUpdate = true
        vnTextField.text = vn
        krTextField.text = kr
    }
    func setupLayoutView(){
        Bundle.main.loadNibNamed("AddWordView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.layer.cornerRadius = 10
        saveBtn.layer.cornerRadius = saveBtn.frame.height / 2
        cancelBtn.layer.cornerRadius = cancelBtn.frame.height / 2
        vnTextField.delegate = self
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        Helper_Audio.shared.cancelRecording()
        stopTimer()
        delegete?.cancelAddNewWord()
    }
    @IBAction func saveAction(_ sender: Any) {
        Helper_Audio.shared.cancelRecording()
        stopTimer()
        vnRecordBtn.setImage(UIImage(systemName: "mic"), for: .normal)
        krRecordBtn.setImage(UIImage(systemName: "mic"), for: .normal)
        
        if let vnText = vnTextField.text, !vnText.isEmpty,
           let krText = krTextField.text, !vnText.isEmpty
        
        {
            delegete?.saveWord(vn: vnText, kr: krText, isUpdate: isUpdate)
        }
        else {
            showAlert(message: "Please Enter Word")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        parentView?.present(alert, animated: true)
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        count += 0.1
        if count > 1 {
            count = 0.0
        }
        print("count: \(count)")
        if currentVNLanguageSelected {
            vnRecordBtn.setImage(UIImage(systemName: "waveform.and.mic", variableValue: count), for: .normal)
        } else {
            krRecordBtn.setImage(UIImage(systemName: "waveform.and.mic", variableValue: count), for: .normal)
        }
    }
    func stopTimer(){
        count = 0.0
        timer?.invalidate()
    }
    @IBAction func recordAction(_ sender: UIButton) {
        Helper_Audio.shared.cancelRecording()
        stopTimer()
        vnRecordBtn.setImage(UIImage(systemName: "mic"), for: .normal)
        krRecordBtn.setImage(UIImage(systemName: "mic"), for: .normal)
        print("is selected: \(sender.isSelected)")
        //vn language
        if sender.tag == 1 {
            currentVNLanguageSelected = true
            if !sender.isSelected {
                runTimer()
                Helper_Audio.shared.recordAndRecognizeSpeech(locale: "vi_VN", completion: {[weak self] bool, str in
                    if bool {
                        self?.vnTextField.text = str
                    } else {
                        self?.showAlert(message: str)
                    }
                })
            } else {
                stopTimer()
                vnRecordBtn.setImage(UIImage(systemName: "mic"), for: .normal)
                Helper_Audio.shared.cancelRecording()
            }
        }
        else
        //kr language
        {
            currentVNLanguageSelected = false
            if !sender.isSelected {
                runTimer()
                Helper_Audio.shared.recordAndRecognizeSpeech(locale: "ko_KR", completion: {[weak self] bool, str in
                    if bool {
                        self?.krTextField.text = str
                    } else {
                        self?.showAlert(message: str)
                    }
                })
            } else {
                stopTimer()
                krRecordBtn.setImage(UIImage(systemName: "mic"), for: .normal)
                Helper_Audio.shared.cancelRecording()
            }
        }
        sender.isSelected = !sender.isSelected
    }
  
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == vnTextField, let text = textField.text, !text.isEmpty {
            self.loadImageFromText(text: text)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == vnTextField, let text = textField.text, !text.isEmpty {
            Helper_LoadImage.shared.search(text: text)
        }
    }
}
extension AddWordView: SFSafariViewControllerDelegate {
    func loadImageFromText(text: String) {
        if let url = URL(string: "https://www.google.com/search?q=\(text)&tbm=isch") {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            parentView?.present(safariViewController, animated: true)
        }
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true)

            // Lấy URL của hình ảnh đầu tiên trong kết quả
            let webView = controller.view as? WKWebView

            let response = webView?.evaluateJavaScript("document.querySelector('.rg_meta img').src") as? String
            if let response = response {
                // Tải xuống hình ảnh
                let imageData = try? Data(contentsOf: URL(string: response)!)
                if let imageData = imageData {
                    // Hiển thị hình ảnh
                    img1.image = UIImage(data: imageData)
                }
            }
        }
}
