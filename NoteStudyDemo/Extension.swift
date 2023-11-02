//
//  Extension.swift
//  NoteStudyDemo
//
//  Created by Kathy on 02/11/2023.
//

import Foundation
import UIKit
class CustomTextField: UITextField {
    @IBInspectable
    var language: String?
    private func getKeyboardLanguage() -> String? {
        return language ?? "en" // here you can choose keyboard any way you need
    }

    override var textInputMode: UITextInputMode? {
        if let language = getKeyboardLanguage() {
            for tim in UITextInputMode.activeInputModes {
                if tim.primaryLanguage!.contains(language) {
                    return tim
                }
            }
        }
        return super.textInputMode
    }

}
