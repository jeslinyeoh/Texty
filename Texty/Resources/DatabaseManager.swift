//
//  DatabaseManager.swift
//  Texty
//
//  Created by Jeslin Yeoh on 28/12/2021
//  following iOS Academy's YouTube tutorial.
//
//  Modified by Jeslin Yeoh in Feb 2022.
//
//  Interact with Firebase Realtime Database

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

/// A Manager object to read and write data to Firebase Realtime Database
final class DatabaseManager {
    
    /// Shared instance of class
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    public var isLocalUser = false
    
    // Prevent user to not create instances of this class
    private init() {}
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
    }
}


extension DatabaseManager {
    
    
    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }

}


// MARK: - Account Management
extension DatabaseManager {
    
    /// Checks if users exists with given email
    /// Parameters
    /// - `email`: target email to be checked
    /// - `completion`: Async closure to return with result
    /// - Returns: False if user already exists
    public func userExists(with email: String,
                           completion: @escaping ((Bool)->Void)){
        
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            
            
            // check if snapshot.value is a String
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { [weak self] error, _ in
            
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            
            
            // add to array of users
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                
                // unwrap optional "value"
                if var usersCollection = snapshot.value as? [[String: String]] {
                    
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    
                    // append to user array
                    usersCollection.append(newElement)
                    
                    
                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                     
                }
                
                else {
                    
                    // create that array
                    let newCollection: [[String: String ]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
            })

        })
    }
    
    
    /// Get all users from the database
    public func getAllUsers(completion: @escaping(Result<[[String:String]], Error>) -> Void) {
        
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    
    // to be edited
    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localisedDescription: String {
            
            switch self {
                
            case .failedToFetch:
                return "This means"
            }
        }
    }
    
}


/*
 ** pull out all the users in 1 request when user starts a new conversation
 
 users =>
     [
        [
            "name:
            "safe_email:
        ]
     
        [
            "name:
            "safe_email:
        ]
     ]
 */


// MARK: - Sending messages/ conversations
extension DatabaseManager {
    
    
    /*
     
        "abcdef" {
            "messages": [
                {
                    "id": String
                    "type": text, photo, video
                    "content": String //var
                    "date": Date()
                    "sender_email": String
                    "isRead": true/false
                }
        }
     
        conversation => [
            [
                "conversation_id": "abcdef"// unique identifier
                "other_user_email":
                "latest_message": => {
                    "date": Date()
                    "latest_message": "message"
                    "is_read": true/ false
                }
            ]
        ]
     
     
     */
    
    /// Create a new conversation with target user email and first message sent
    /// Message is a struct
    /// name is for the other user.
    public func createNewConversation (with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        // reference to the current user's node
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {

            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
                
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
                
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            // explicitly declare the type because it has many types inside
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // explicitly declare the type because it has many types inside
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            
            // Update recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                
                if var recipient_conversations = snapshot.value as? [[String: Any]] {
                    // append
                    recipient_conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(recipient_conversations)
                }
                
                else {
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            
            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user, append
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations // update the conversations node
    
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                })
            }
            
            else {
                // conversation array does not exist, create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                })
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
//        {
//            "id": String
//            "type": text, photo, video
//            "content": String //var
//            "date": Date()
//            "sender_email": String
//            "is_read": true/false
//        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {

        case .text(let messageText):
            message = messageText
            break
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                message = targetUrlString
            }
            break
            
        case .video(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                message = targetUrlString
            }
            
            break
            
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name // other user's name
        ]
        
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          return nil
                      }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                
                
                return Conversation(id: conversationID,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
            
        })
        
    }
    
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        // observe means call when there's changes to the database
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            guard let localUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            
            let safeLocalUserEmail = DatabaseManager.safeEmail(emailAddress: localUserEmail)
            
            let messages: [Message] = value.compactMap({ dictionary in
                
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as?  String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString),
                      let type = dictionary["type"] as? String else {
                          return nil
                      }
                
                
                var kind: MessageKind?
                if type == "photo" {
                    
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        
                        return nil
                    }
                    
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300)) //should use width of device
                    
                    kind = .photo(media)
                    
                }
                
                else if type == "video" {
                    
                    guard let videoUrl = URL(string: content),
                          let placeHolder = UIImage(named: "video_placeholder"),
                          let backgroundImage = UIImage(named: "black_image") else {
                        
                        return nil
                    }
                    
                    let media = Media(url: videoUrl,
                                      image: backgroundImage,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300)) //should use width of device
                    
                    kind = .video(media)
                    
                }
                
                else if type == "location" {
                    
                    let locationComponents = content.components(separatedBy: ",")
                    
                    guard let longitude = Double(locationComponents[0]),
                        let latitude = Double(locationComponents[1]) else {
                        return nil
                    }
                    
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    kind = .location(location)
                }
                
                
                else {
                    kind = .text(content)
                    
                    // check if current message is sent by local user and send it to the Smart Reply Manager
                    self.isLocalUser = safeLocalUserEmail == senderEmail
                    
                    // print("messages count: \(value.count)")
                    SmartReplyManager.shared.inputToSmartReply(text: content, userID: senderEmail, isLocalUser: self.isLocalUser, date: date, totalMessages: value.count)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: Date(), // to prevent bugs for not loading other devices' message
                               kind: finalKind)
            })
            
            completion(.success(messages))
            
        })
        
        
    }
    
    
    /// Send a message with target conversation and message
    /// Message is a struct
    /// conversation take in conversationID
    public func sendMessage(to conversationID: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        
        // add new message to Messages
        
        // update sender latest message
        
        // update recipient latest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        
        // update messages in chat
        database.child("\(conversationID)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {

            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
                
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                
                break
                
                
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                
                break
                
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name // other user's name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversationID)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    
                    var databaseEntryConversations = [[String: Any]]()
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    // if current other user conversation exists
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        
                        var targetConversation: [String: Any]?
                        var position = 0
                        
                        // search for latest message under a given conversation id
                        for conversation in currentUserConversations {
                            
                            if let currentID = conversation["id"] as? String,
                               currentID == conversationID {
                                targetConversation = conversation
                                break
                            }
                            
                            position += 1
                        }
                        
                        // if conversation exists
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        
                        // conversation not found, reinsert the conversation
                        else {
                            let newConversationData: [String: Any] = [

                                "id": conversationID,
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                        
                        
                    }
                    
                    else {
                        // previously deleted the other user's conversation
                        
                        let newConversationData: [String: Any] = [
                            "id": conversationID,
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        // update latest message for recipient user ///////////////////////////////////////
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            
                            var databaseEntryConversations = [[String: Any]]()
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }
                            
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0
                                
                                // search for latest message under a given conversation id
                                for conversation in otherUserConversations {
                                    
                                    if let currentID = conversation["id"] as? String,
                                       currentID == conversationID {
                                        targetConversation = conversation
                                        break
                                    }
                                    
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }

                                else {
                                    // fail to find in current collection
                                    let newConversationData: [String: Any] = [
                                        "id": conversationID,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            }
                            
                            else {
                                // current collection does not exist
                                
                                let newConversationData: [String: Any] = [
                                    "id": conversationID,
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                            
                            
                            
                            
                            
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                            
                        })
                        
                        completion(true)
                    })
                    
                })
                
            })
        })
    }
    
    
    public func deleteConversation(conversationID: String, completion: @escaping (Bool) -> Void) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Deleting conversation with id: \(conversationID)")
        
        // Get all conversations for current user
        // Delete conversation in collection with target id
        // reset those conversations for the user in database
        
        let ref = database.child("\(safeEmail)/conversations")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationID {
                        
                        print("Found conversation to delete")
                        break
                    }
                    
                    positionToRemove += 1
                }
                
                conversations.remove(at: positionToRemove)
                
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        print("Failed to delete conversation")
                        return
                    }
                    
                    print("Deleted conversation")
                    completion(true)
                })

            }
        })
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void){
        
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                
                // found previous conversation
                return safeSenderEmail == targetSenderEmail
                
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                completion(.success(id))
                return
            }
            
            completion(.failure(DatabaseError.failedToFetch))
            return
            
        })
    }
    
}




struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
