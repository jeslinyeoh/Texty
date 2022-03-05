//
//  ChatViewController.swift
//  Texty
//
//  Created by Jeslin Yeoh on 30/12/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation


final class ChatViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        
        return formatter
    } ()
    
    public let otherUserEmail: String
    private var conversationID: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Me")
        
    }
    

    
    // constructor
    init(with email: String, id: String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
//        messages.append(Message(sender: selfSender,
//                                messageId: "1",
//                                sentDate: Date(),
//                                kind: .text("Hello World Message.")))
//
//        messages.append(Message(sender: selfSender,
//                                messageId: "1",
//                                sentDate: Date(),
//                                kind: .text("Hello World Message. Hello World Message.")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.delegate = self
        messageInputBar.delegate = self
        setupInputButton()
    }
    
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self]_ in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
    }
    
    private func presentInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentPhotoInputActionsheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentVideoInputActionsheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Location",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentLocationPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler:  nil ))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageID = strongSelf.createMessageID(),
                  let conversationID = strongSelf.conversationID,
                  let name = strongSelf.title,
                  let selfSender = strongSelf.selfSender else {
                      return
                  }
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            print("long=\(longitude) | lat = \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                 size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageID,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                
                if success {
                    print("Sent location message")
                }
                
                else {
                    print("Failed to send location message")
                }
            })
        }
        
        
        
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionsheet(){
        
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "What would you like to attach a photo from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil ))
        
        present(actionSheet, animated: true)
    }
    
    
    private func presentVideoInputActionsheet(){
        
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "What would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil ))
        
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            
            switch result{
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }

                }

                
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        }
    }

}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let messageID = createMessageID(),
              let conversationID = conversationID,
              let name = self.title,
              let selfSender = selfSender else {
                  return
              }
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData()  {
            
            
            let fileName = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".png"
            
            // Upload image
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded message photo: \(urlString)")
                    
                    
                    // placeholder image is irrelevant but is non-optional in Media struct definition
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageID,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("Sent photo message")
                        }
                        
                        else {
                            print("Failed to send photo message")
                        }
                    })
                    
                case .failure(let error):
                    print("Message photo upload error: \(error)")
                }
            })
        }
        
        
        else if let videoURL = info[.mediaURL] as? URL {
            
            let fileName = "video_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            // uploading a video
            StorageManager.shared.uploadMessageVideo(with: videoURL, fileName: fileName, completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded message video: \(urlString)")
                    
                    
                    // placeholder image is irrelevant but is non-optional in Media struct definition
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                              return
                          }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageID,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("Sent video message")
                        }
                        
                        else {
                            print("Failed to send video message")
                        }
                    })
                    
                case .failure(let error):
                    print("Message video upload error: \(error)")
                }
            })
            
        }
    
    }
}


extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageID = createMessageID() else {
                return
        }
        
        print("Sending: \(text)")
        
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        
        // Send message
        if isNewConversation {
            // create convo in database
            
            
            // name is other user's name
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                
                if success {
                    self?.isNewConversation = false
                    let newConversationID = "conversation_\(message.messageId)"
                    self?.conversationID = newConversationID
                    self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil // clear the input text field
                    
                    print("Message sent.")
                }
                
                else {
                    print("Failed to send.")
                }
            })
            
        }
        
        else {
            // append to existing conversation data
            
            guard let conversationID = conversationID,
                  let name = self.title else {
                return
            }
            
            
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                
                if success {
                    self?.messageInputBar.inputTextView.text = nil // clear the input text field
                    print("Message sent")
                }
                
                else {
                    print("Failed to send")
                }
            })
            
        }
    }
    
    
    private func createMessageID() -> String? {

        // date, otherUserEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("Created message ID: \(newIdentifier)")
        
        return newIdentifier
    }
}



extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    // know who the current sender is
    func currentSender() -> SenderType {
        
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        // Message Kit uses sections to separate every message
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // to display the photo message in chat
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            
            imageView.sd_setImage(with: imageURL, completed: nil)
            
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            
            // our message that we've sent
            return .link
        }
        
        return .secondarySystemBackground

    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            // show our image
            
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            }
            
            else {
                // images/safeEmail_profile_picture.png
                
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch download URL
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                        
                    case .success(let url):
                        
                        self?.senderPhotoURL = url
                        
                        DispatchQueue.main.async{
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        
                        
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
        
        // other user image
        else {
            if let otherUserImageURL = self.otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserImageURL, completed: nil)
            }
            
            else {
                // images/safeEmail_profile_picture.png
                
                let email = self.otherUserEmail
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch download URL
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                        
                    case .success(let url):
                        
                        self?.otherUserPhotoURL = url
                        
                        DispatchQueue.main.async{
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        
                        
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
    }
    
    
}

extension ChatViewController: MessageCellDelegate {
    
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location"
            navigationController?.pushViewController(vc, animated: true)
        
        default:
            break
        }
    }
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            
            let vc = PhotoViewerViewController(with: imageURL)
            navigationController?.pushViewController(vc, animated: true)
            
            
        case .video(let media):
            guard let videoURL = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
            
        
        default:
            break
        }
    }
}


