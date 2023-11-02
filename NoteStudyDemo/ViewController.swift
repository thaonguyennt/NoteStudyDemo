//
//  ViewController.swift
//  NoteStudyDemo
//
//  Created by Kathy on 27/10/2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var synthesizer = AVSpeechSynthesizer()
    @IBOutlet weak var searchWord: UISearchBar!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWord: UIButton!
    
    var addView: AddWordView?
    private var itemSelected: Word?
    private var currentBackgroundImage: String?
    private var arrBackgroundImage: [String] = []
    private var arrWords: [Word] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addWord.layer.cornerRadius = addWord.frame.height / 2
        tableView.delegate = self
        tableView.dataSource = self
        searchWord.delegate = self
        addView = AddWordView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero))
        insertBacgroundImage()
        getAllItem()
    }

    private func showAddWord() {
        if let addView = addView {
            if !addView.isDescendant(of: view) {
                self.view.addSubview(addView)
                addView.parentView = self
                addView.delegete = self
                addView.contentView.alpha = 0
                addView.frame.size = self.view.frame.size
                UIView.transition(with: addView, duration: 0.5) {
                    addView.contentView.alpha = 1
                }
            }
        }
    }
    func removeAddView(){
        if let addView = addView, addView.isDescendant(of: view) {
            addView.resetValue()
            UIView.animate(withDuration: 1) {
                addView.removeFromSuperview()
            }
        }
    }
    func insertBacgroundImage(){
        for i in 1...15 {
            arrBackgroundImage.append("bg\(i)")
        }
    }
    @IBAction func actionAddWord(_ sender: Any) {
        showAddWord()
        
    }
    @IBAction func checkRandomWord(_ sender: Any) {
        
    }
    
    @IBAction func changeBackGround(_ sender: Any) {
        var randomImage: String?
        randomImage = arrBackgroundImage.randomElement()
        if currentBackgroundImage == randomImage {
            randomImage = arrBackgroundImage.randomElement()
        }
        currentBackgroundImage = randomImage
        bgImage.image = UIImage(named: randomImage ?? "")
    }
    private func textToSpeed(text: String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko")
        synthesizer.speak(utterance)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            let data = arrWords[indexPath.row]
            cell.setDataCell(kr: data.kr_language ?? "", vn: data.vn_language ?? "", imgUrl: data.image ?? "")
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let kr_word = arrWords[indexPath.row].kr_language
        textToSpeed(text: kr_word ?? "")
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        itemSelected = arrWords[indexPath.row]
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            let alert  = UIAlertController(title: "⚠️", message: "Do you want to deleted?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
                self?.deleteItem(item: self?.arrWords[indexPath.row])
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
           }
           delete.image = UIImage(systemName: "trash")
           delete.backgroundColor = .red
        
        let edit = UIContextualAction(style: .normal, title: "Edit") {  [weak self] (action, view, completionHandler) in
            self?.addView?.setValue(kr: self?.itemSelected?.kr_language ?? "", vn: self?.itemSelected?.vn_language ?? "", link: self?.itemSelected?.image ?? "")
            self?.showAddWord()
           }
        edit.image = UIImage(systemName: "pencil")
        edit.backgroundColor = .blue
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipe
    }
}
extension ViewController {
    func getAllItem(){
        do {
            arrWords = try context.fetch(Word.fetchRequest()).reversed()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func createItem(kr: String, vn: String, link: String){
        let newItem = Word(context: context)
        newItem.id = Date()
        newItem.kr_language = kr
        newItem.vn_language = vn
        newItem.image = link
        do {
            try context.save()
            arrWords.insert(newItem, at: 0)
        } catch {
            print(error.localizedDescription)
        }
    }
    func deleteItem(item: Word?){
        guard let item = item else {return}
        context.delete(item)
        do {
            try context.save()
            guard let index = arrWords.firstIndex(of: item) else { return  }
            arrWords.remove(at: index)
        } catch {
            print(error.localizedDescription)
        }
    }
    func updateItem(item: Word?, kr: String?, vn: String?, link: String?){
        item?.kr_language = kr
        item?.vn_language = vn
        item?.image = link
        do {
            try context.save()
            getAllItem()
        } catch {
            print(error.localizedDescription)
        }
    }

}
extension ViewController: AddWordViewDelegete {
    func saveWord(vn: String?, kr: String?, link: String?, isUpdate: Bool) {
        removeAddView()
        if isUpdate {
            updateItem(item: itemSelected, kr: kr, vn: vn, link: link)
        } else {
            createItem(kr: kr ?? "", vn: vn ?? "", link: link ?? "")
        }
    }
    func cancelAddNewWord() {
        removeAddView()
    }
   
}
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.folding(options: .diacriticInsensitive, locale: .current)
        var filterData: [Word] = []
        getAllItem()
        if !searchText.isEmpty {
            for word in arrWords {
                if let vn = word.vn_language, vn.folding(options: .diacriticInsensitive, locale: .current).uppercased().contains(searchText.uppercased())  {
                    filterData.append(word)
                }
            }
            arrWords = filterData
        } else {
            getAllItem()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    func searchText(text: String) {
        
    }
}
class CustomCell: UITableViewCell {
    
    @IBOutlet weak var vnLb: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var krLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.cornerRadius = 10
    }
    func setDataCell(kr: String, vn: String, imgUrl: String) {
        vnLb.text = vn
        krLb.text = kr
        if let url = URL(string: imgUrl) {
            img.load(url: url) {}
        }
        else{
            img.image = UIImage(named: "default_image")
        }
    }
}
