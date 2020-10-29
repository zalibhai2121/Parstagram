//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Zainab Alibhai on 10/22/20.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
    

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showCommentBar = false
    var posts = [PFObject]()
    var selectedpost: PFObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a Comment ..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        // Do any additional setup after loading the view.
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className:"Post")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            } 
        }
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
//        create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedpost
        comment["author"] = PFUser.current()!

        selectedpost.add(comment, forKey: "comments")
        selectedpost.saveInBackground { (success, error) in
            if success {
                print("comment saved")
            } else {
                print("error saving comment")
            }
        }
        tableView.reloadData()
//        clear and dismiss bar
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imagefile = post["image"] as! PFFileObject
            let urlString = imagefile.url!
            let url = URL(string: urlString)!
            cell.postView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedpost = post
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? SceneDelegate
         else {
           return
         }
        delegate.window?.rootViewController = loginViewController
    }
}
