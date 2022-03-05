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
    
    
    /// Take in text Strings to be fed to the Google Smart Reply API
    /// Parameter
    /// - `text`: message
    /// - `userID`: sender email
    /// - `isLocalUser`: check if sender is local user
    /// - Returns null
    public func inputToSmartReply(text: String, userID: String, isLocalUser: Bool) {
        
        let message = TextMessage(
            text: text,
            timestamp: Date().timeIntervalSince1970,
            userID: userID,
            isLocalUser: isLocalUser)
        
        conversation.append(message)

    }
    
    
    public func getSmartReplies() {
        SmartReply.smartReply().suggestReplies(for: conversation) { result, error in
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
