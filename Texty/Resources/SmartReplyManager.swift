//
//  SmartReplyManager.swift
//  Texty
//
//  Created by Jeslin Yeoh on 05/03/2022.
//

import Foundation
import MLKit

final class SmartReplyManager {
    
    public static let shared = SmartReplyManager()
    
    var conversation: [TextMessage] = []
    
    static var count = 0
    
    /// Take in text Strings to be fed to the Google Smart Reply API
    /// Parameter
    /// - `text`: message
    /// - `userID`: sender email
    /// - `isLocalUser`: check if sender is local user
    /// - Returns null
    public func inputToSmartReply(text: String, userID: String, isLocalUser: Bool, date: Date, totalMessages: Int) {
        
        var lowerCasedSentence = text.lowercased()
        
        LanguageManager.shared.translateLanguage(sentence: lowerCasedSentence, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case.failure(let error):
                print("Language Translator error, failed to get translated words: \(error)")
            
            case .success(let translatedWords):
                
                print("translated words in main: \(translatedWords)")
                let translatedText = SlangsManager.shared.translateSlangs(word_array: translatedWords)
                
                let message = TextMessage(
                    text: translatedText,
                    timestamp: date.timeIntervalSince1970,
                    userID: userID,
                    isLocalUser: isLocalUser)
                
                strongSelf.conversation.append(message)
                
                SmartReplyManager.count += 1
                
                if SmartReplyManager.count == totalMessages - 1 {
                    SmartReplyManager.count = 0
                    strongSelf.getSmartReplies()
                    strongSelf.clearConversation()
                }
                
            }
        
        })


    }
    
    
    public func getSmartReplies() {
        SmartReply.smartReply().suggestReplies(for: conversation) { result, error in
            
            print("reach smart reply")
            guard error == nil, let result = result else {
                return
            }
            
            if (result.status == .notSupportedLanguage) {
                // The conversation's language isn't supported, so
                // the result doesn't contain any suggestions.
            }
            
            else if (result.status == .success) {
                // Successfully suggested smart replies.
                // ...
                
                let dict = [
                    "0": result.suggestions[0].text,
                    "1": result.suggestions[1].text,
                    "2": result.suggestions[2].text
                ]
                
                NotificationCenter.default.post(name: .didSuggestionsUpdateNotification, object: dict)
            }
        }
    }
    
    
    public func clearConversation(){
        conversation = []
    }
}
