//
//  Helper.swift
//  NoteStudyDemo
//
//  Created by Kathy on 30/10/2023.
//

import Foundation
import Speech

class Helper_Audio {
    static let shared = Helper_Audio()
    
    let audioEngine = AVAudioEngine() // give updates when the mic is receiving audio.
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer() // This will do the actual speech recognition
    let request = SFSpeechAudioBufferRecognitionRequest()//This allocates speech as the user speaks in real-time and controls the buffering
    var recognitionTask: SFSpeechRecognitionTask? //This will be used to manage, cancel, or stop the current recognition task.
    
    func recordAndRecognizeSpeech(locale: String, completion: @escaping (Bool, String) -> ()) {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            completion(false, "There has been an audio engine error.")
        }
        guard let myRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: locale)) else {
            //A recognizer is not supported for the current locale
            return completion(false, "Speech recognition is not supported for your current locale.")
        }
        if !myRecognizer.isAvailable {
            //A recognizer is not available right now
            completion(false, "Speech recognition is not currently available. Check back at a later time.")
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                completion(true, bestString)
            } else if let error = error {
                completion(false, "There has been a speech recognition error.")
                
            }
        })
    }
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
