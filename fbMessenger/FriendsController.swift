//
//  ViewController.swift
//  fbMessenger
//
//  Created by Chiang Chuan on 7/17/16.
//  Copyright © 2016 Chiang Chuan. All rights reserved.
//

import UIKit
import CoreData



class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    
    private let cellId = "cellId"
    
//    var messages: [Message]?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date",ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if type == .Insert{
            blockOperations.append(NSBlockOperation(block: {
                self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({
            
            for operation in self.blockOperations{
                operation.start()
            }
            
            }, completion: { (completed) in
                
                let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
                let indexPath = NSIndexPath(forItem: lastItem, inSection: 0)
                self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                
        })
    }
    
    var blockOperations = [NSBlockOperation]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Recent"
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.registerClass(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupData()
        
        do{
            try fetchedResultsController.performFetch()
        } catch let err{
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .Plain, target: self, action: #selector(addMark))
        
    }
    
    func addMark(){
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        let mark = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
        mark.name = "Mark Zuckerbarg"
        mark.profileImageName = "zuckprofile"
        
        FriendsController.createMessageWithText("Hellow, I'm Mark, Nice to meet you...", friend: mark, minutesAgo: 0, context: context)
        
        let bill = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
        bill.name = "Bill Gates"
        bill.profileImageName = "bill_gates_profile"
        
        FriendsController.createMessageWithText("Hellow, I like Window very much...", friend: bill, minutesAgo: 0, context: context)
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects{
            return count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! MessageCell
        
        
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        
        cell.message = friend.lastMessage
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width, 100)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controler = ChatLogController(collectionViewLayout: layout)
        
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend

        
        controler.friend = friend
        navigationController?.pushViewController(controler, animated: true)
        
    }
    
    
}
class MessageCell: BaseCell {
    
    override var highlighted: Bool{
        didSet{
            backgroundColor = highlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.whiteColor()
            nameLabel.textColor = highlighted ? UIColor.whiteColor() : UIColor.blackColor()
            timeLabel.textColor = highlighted ? UIColor.whiteColor() : UIColor.blackColor()
            messageLabel.textColor = highlighted ? UIColor.whiteColor() : UIColor.blackColor()
        }
    }
    
        
    var message: Message? {
        didSet{
            nameLabel.text = message?.friend?.name
            
            if let profileImageName = message?.friend?.profileImageName{
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            messageLabel.text = message?.text
            
            if let date = message?.date{
                
                let dateFormater = NSDateFormatter()
                dateFormater.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSinceDate(date)
                
                let secondInDays : NSTimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > 7 * secondInDays {
                    dateFormater.dateFormat = "MM/dd/yy"
                }else if elapsedTimeInSeconds > secondInDays{
                    dateFormater.dateFormat = "EEE"
                }
               
                timeLabel.text = dateFormater.stringFromDate(date)

            }

        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend Name"
        label.font = UIFont.systemFontOfSize(18)
        return label
    }()
    
    let messageLabel: UILabel = {
       let label = UILabel()
        label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)

        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:05 pm"
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews(){
       
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        profileImageView.image = UIImage(named: "ruuprofile")
        hasReadImageView.image = UIImage(named: "ruuprofile")
        
        
        addConstraintsWithFormat("H:|-14-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))


        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
        

    }
    private func setupContainerView(){
        let containeView    = UIView()
        addSubview(containeView)
        
        addConstraintsWithFormat("H:|-90-[v0]|", views: containeView)
        addConstraintsWithFormat("V:[v0(50)]", views: containeView)
        
        addConstraint(NSLayoutConstraint(item: containeView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        containeView.addSubview(nameLabel)
        containeView.addSubview(messageLabel)
        containeView.addSubview(timeLabel)
        containeView.addSubview(hasReadImageView)

        
        containeView.addConstraintsWithFormat("H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        
        containeView.addConstraintsWithFormat("V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        
        containeView.addConstraintsWithFormat("H:|[v0]-8-[v1(20)]-12-|", views: messageLabel,hasReadImageView)
        
        containeView.addConstraintsWithFormat("V:|[v0(24)]", views: timeLabel)
       
        containeView.addConstraintsWithFormat("V:[v0(20)]|", views: hasReadImageView)


    }
    
}



extension UIView{
    
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
}



class BaseCell: UICollectionViewCell{
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){

    }
    
}

