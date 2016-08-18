import UIKit

class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var SendChatTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.CollectionView.dataSource = self
        self.CollectionView.delegate = self
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // telling the controller to use the reusuable 'receivecell' from chatCollectionViewCell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ReceiveCell",
            forIndexPath: indexPath) as! ChatCollectionViewCell
        
        // use this cell for all received chats
        cell.receiveChatLabel.layer.cornerRadius = 5
        cell.receiveChatLabel.layer.masksToBounds = true
        
        // use this cell for chats user sends
        // cell.sendChatLabel.layer.cornerRadius = 5
        // cell.sendChatLabel.layer.masksToBounds = true
        
        // sample chat
        cell.receiveChatLabel.text = "The Quick Brown Fox Jumps Over the Lazy Dog"
        return cell
    }
 
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
    }
}
