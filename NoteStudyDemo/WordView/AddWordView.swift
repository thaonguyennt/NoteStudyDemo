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
    func saveWord(vn: String?, kr: String?, link: String?, isUpdate: Bool)
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var timer: Timer?
    private var count: Double = 0.0
    private var listImages: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var parentView: ViewController?
    weak var delegete: AddWordViewDelegete?
    private var isUpdate: Bool = false
    private var linkImg: String?
    private var itemSelected: IndexPath?
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
        linkImg = nil
        listImages = []
    }
    func setValue(kr: String, vn: String, link: String) {
        isUpdate = true
        vnTextField.text = vn
        krTextField.text = kr
        listImages.append(link)
     
    }
    func setupLayoutView(){
        Bundle.main.loadNibNamed("AddWordView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.layer.cornerRadius = 10
        saveBtn.layer.cornerRadius = saveBtn.frame.height / 2
        cancelBtn.layer.cornerRadius = cancelBtn.frame.height / 2
        krTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
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
            delegete?.saveWord(vn: vnText, kr: krText, link: linkImg, isUpdate: isUpdate)
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
            if #available(iOS 16.0, *) {
                vnRecordBtn.setImage(UIImage(systemName: "waveform.and.mic", variableValue: count), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 16.0, *) {
                krRecordBtn.setImage(UIImage(systemName: "waveform.and.mic", variableValue: count), for: .normal)
            } else {
                // Fallback on earlier versions
            }
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
  
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == krTextField, let text = textField.text, !text.isEmpty {
            Helper_LoadImage.shared.search(text: text) {[weak self] listImages in
                self?.listImages = listImages ?? []
            }
        }
    }
}
extension AddWordView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell()}
        if indexPath == itemSelected {
            cell.updateLayoutSelected()
        } else {
            cell.updateLayoutDeselected()
        }
        cell.setDataImage(image: listImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 10
        return CGSize(width: width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelected = indexPath
        let imageSelected = listImages[indexPath.row]
        self.linkImg = imageSelected
        if let cell = collectionView.cellForItem(at:  indexPath) as? ImageCollectionViewCell {
            cell.updateLayoutSelected()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at:  indexPath) as? ImageCollectionViewCell {
            cell.updateLayoutDeselected()
        }
    }
}
