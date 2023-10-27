//
//  ViewController.swift
//  NoteStudyDemo
//
//  Created by Kathy on 27/10/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWord: UIButton!
    var addView: AddWordView?
    private var arrWords: [Word] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        addWord.layer.cornerRadius = addWord.frame.height / 2
        tableView.delegate = self
        tableView.dataSource = self
        addView = AddWordView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero))
        
    }

    @IBAction func actionAddWord(_ sender: Any) {
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
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            let data = arrWords[indexPath.row]
            cell.setDataCell(kr: data.kr_language, vn: data.vn_language)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }
    func fetchData(){
        
    }
}
extension ViewController: AddWordViewDelegete {
    func saveWord(vn: String?, kr: String?) {
        if let addView = addView, addView.isDescendant(of: view) {
            UIView.animate(withDuration: 1) {
                addView.removeFromSuperview()
            }
        }
    }
    
    
}
struct Word {
    var id: Date
    var kr_language: String
    var vn_language: String
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
