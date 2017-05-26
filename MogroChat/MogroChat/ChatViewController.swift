//
//  ChatViewController.swift
//  MogroChat
//
//  Created by Marcelo Mogrovejo on 5/22/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    var photoCache = NSCache<AnyObject, AnyObject>()
    var messageRef = FIRDatabase.database().reference().child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentUser = FIRAuth.auth()?.currentUser {
            self.senderId = currentUser.uid
            
            if currentUser.isAnonymous == true {
                self.senderDisplayName = "Anonymous"
            } else {
                self.senderDisplayName = currentUser.displayName
            }
        }
        
        // FirebaseDatabase example
//        let rootRef = FIRDatabase.database().reference()
//        let messageRef = rootRef.child("messages")
//        print(rootRef)
//        print(messageRef)
        
//        messageRef.childByAutoId().setValue("second message")
//        messageRef.observe(FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
//            print(snapshot.value!)
//            if let dict = snapshot.value as? NSDictionary {
//                print(dict)
//            }
//        }
        
//        messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
////            print(snapshot.value!)
//            if let message = snapshot.value as? String {
//                print(message)
//            }
//        }
        
        observeMessages()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action methods
    
    @IBAction func logOut(_ sender: Any) {
        Helper.helper.logOut()
    }
    
    // JSQMessagesViewController methods
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        print(messages)
//        
//        collectionView.reloadData()
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "mediaType": "TEXT"]
        newMessage.setValue(messageData)
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let sheet = UIAlertController(title: "Media Message", message: "Please select a media", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        var returnMessage: JSQMessageBubbleImageDataSource!
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        
        // Outgoing message
        if message.senderId == self.senderId {
            returnMessage = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
        // Incoming message
        } else {
            returnMessage = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.blue)
        }
        return returnMessage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        return avatarDict[message.senderId]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UIImagePickerControllerDelegate and UINavigationControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture: picture, video: nil)
        } else if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
            sendMedia(picture: nil, video: videoURL)
        } else {
            let defaultImage = UIImage(named: "Google")
            sendMedia(picture: defaultImage, video: nil)
            print("Something went wrong")
        }
        collectionView.reloadData()
        
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Private methods
    
    func getMediaFrom(type: CFString) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        mediaPicker.allowsEditing = false
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func observeMessages() {
        messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let mediaType = dict["mediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                self.observeUsers(id: senderId)
                
                switch mediaType {
                    case "TEXT":
                        let text = dict["text"] as! String
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    case "PHOTO":
                        var photo = JSQPhotoMediaItem(image: nil)
                        let fileUrl = dict["fileUrl"] as! String
                        
                        if let cachedPhoto = self.photoCache.object(forKey: fileUrl as AnyObject) as? JSQPhotoMediaItem {
                            photo = cachedPhoto
                            self.collectionView.reloadData()
                        } else {
                            // Move to a background thread to do some long running work
                            DispatchQueue.global(qos: .userInteractive).async {
                                let data = NSData(contentsOf: NSURL(string: fileUrl)! as URL)
                                
                                // Bounce back to the main thread to update the UI
                                DispatchQueue.main.async {
                                    let picture = UIImage(data: data! as Data)
                                    photo?.image = picture
                                    self.collectionView.reloadData()
                                    self.photoCache.setObject(photo!, forKey: fileUrl as AnyObject)
                                }
                            }
                        }
                        
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                        // Outgoing media
                        if self.senderId == senderId {
                            photo?.appliesMediaViewMaskAsOutgoing = true
                        // Incoming media
                        } else {
                            photo?.appliesMediaViewMaskAsOutgoing = false
                        }
                    case "VIDEO":
                        let fileUrl = dict["fileUrl"] as! String
                        let video = NSURL(string: fileUrl)
                        let videoItem = JSQVideoMediaItem(fileURL: video! as URL, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    
                        // Outgoing media
                        if self.senderId == senderId {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                        // Incoming media
                        } else {
                            videoItem?.appliesMediaViewMaskAsOutgoing = false
                        }
                    default:
                        print("Unknown data type")
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func observeUsers(id: String) {
        FIRDatabase.database().reference().child("users").child(id).observe(.value) { (snapshot: FIRDataSnapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let avatarUrl = dict["photoUrl"] as! String
                self.setupAvatar(url: avatarUrl, messageId: id)
            }
        }
    }
    
    func setupAvatar(url: String, messageId: String) {
        if url != "" {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOf: fileUrl! as URL)
            let image = UIImage(data: data! as Data)
            let userImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDict[messageId] = userImage
        } else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        collectionView.reloadData()
    }
    
    func sendMedia(picture: UIImage?, video: NSURL?) {
        if let picture = picture {
            print(FIRStorage.storage().reference())
            let filePath = "\(String(describing: FIRAuth.auth()?.currentUser!.uid))/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata: FIRStorageMetadata?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "PHOTO"]
                newMessage.setValue(messageData)
            }
        } else if let video = video {
            print(FIRStorage.storage().reference())
            let filePath = "\(String(describing: FIRAuth.auth()?.currentUser!.uid))/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video as URL)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metadata) { (metadata: FIRStorageMetadata?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "VIDEO"]
                newMessage.setValue(messageData)
            }
        }
        
    }
    
}
