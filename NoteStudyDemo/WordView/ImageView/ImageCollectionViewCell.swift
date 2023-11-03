//
//  ImageCollectionViewCell.swift
//  NoteStudyDemo
//
//  Created by Kathy on 03/11/2023.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wordImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        wordImg.layer.borderWidth = 1
        wordImg.layer.borderColor = UIColor.systemBlue.cgColor
        wordImg.layer.cornerRadius = 5
    }
    func setDataImage(image: String?){
        if let image = image, let url = URL(string: image) {
            wordImg.load(url: url)
        } else {
            wordImg.image = UIImage(named: "default_image")
        }
    }
    func updateLayoutSelected() {
        wordImg.layer.borderColor = UIColor.red.cgColor
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.wordImg?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                self.wordImg?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        })
    }
    func updateLayoutDeselected() {
        wordImg.layer.borderColor = UIColor.systemBlue.cgColor
        self.wordImg?.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
}
