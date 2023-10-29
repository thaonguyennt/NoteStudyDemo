//
//  ViewController.swift
//  NoteStudyDemo
//
//  Created by Kathy on 27/10/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWord: UIButton!
    var addView: AddWordView?
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
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        addView = AddWordView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero))
        getAllItem()
    }

    private func showAddWord() {
        if let addView = addView {
            if !addView.isDescendant(of: view) {
                self.view.addSubview(addView)
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
    @IBAction func actionAddWord(_ sender: Any) {
        showAddWord()
        
    }
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alert  = UIAlertController(title: "⚠️", message: "Do you want to deleted?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
                    self?.deleteItem(item: self?.arrWords[indexPath.row])
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            let data = arrWords[indexPath.row]
            cell.setDataCell(kr: data.kr_language ?? "", vn: data.vn_language ?? "")
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = arrWords[indexPath.row]
        addView?.setValue(kr: word.kr_language ?? "", vn: word.vn_language ?? "")
        showAddWord()
    }
}
extension ViewController {
    func getAllItem(){
        do {
            arrWords = try context.fetch(Word.fetchRequest())
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func createItem(kr: String, vn: String){
        let newItem = Word(context: context)
        newItem.id = Date()
        newItem.kr_language = kr
        newItem.vn_language = vn
        
        do {
            try context.save()
            getAllItem()
        } catch {
            print(error.localizedDescription)
        }
    }
    func deleteItem(item: Word?){
        guard let item = item else {return}
        context.delete(item)
        do {
            try context.save()
            getAllItem()
        } catch {
            print(error.localizedDescription)
        }
    }
    func updateItem(item: Word, kr: String, vn: String ){
        item.kr_language = kr
        item.vn_language = vn
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

}
extension ViewController: AddWordViewDelegete {
    func saveWord(vn: String?, kr: String?) {
        removeAddView()
        createItem(kr: kr ?? "", vn: vn ?? "")
    }
    func cancelAddNewWord() {
        removeAddView()
    }
   
}

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var vnLb: UILabel!
    @IBOutlet weak var krLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setDataCell(kr: String, vn: String) {
        vnLb.text = vn
        krLb.text = kr
    }
}
