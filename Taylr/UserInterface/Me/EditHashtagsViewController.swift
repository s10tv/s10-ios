//
//  EditHashtagsViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/9/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MLPAutoCompleteTextField
import Async
import Core

class EditHashtagsViewController : UIViewController {
    @IBOutlet weak var textField: MLPAutoCompleteTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var vm: EditHashtagsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.autoCompleteTableAppearsAsKeyboardAccessory = true
        textField.shouldResignFirstResponderFromKeyboardAfterSelectionOfAutoCompleteRows = false
        textField.autocorrectionType = .No
        
        vm = EditHashtagsViewModel(meteor: Meteor)
        collectionView <~ (vm.hashtags, HashtagCell.self)

        vm.placeholder.producer.startWithNext { [weak self] in
            if let this = self where (this.textField.text?.length ?? 0) == 0 {
                this.textField.fadeTransition(1)
                this.textField.placeholder = $0
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: EditHashtags")
    }
}

// MARK: - UIScrollViewDelegate

extension EditHashtagsViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        textField.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegate

extension EditHashtagsViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let hashtag = vm.hashtags.array[indexPath.item]
        if hashtag.selected {
            Analytics.track("Hashtag: Remove", ["Text": hashtag.text])
        } else {
            Analytics.track("Hashtag: Add", ["Text": hashtag.text])
        }
        vm.toggleHashtagAtIndex(indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

// TODO: Eventually use self-sizing UICollectionViewCell instead of hardcoding like this...

private let HashtagFont = UIFont(.cabinRegular, size: 14)

extension EditHashtagsViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let hashtag = vm.hashtags.array[indexPath.item]
        var size = (hashtag.displayText as NSString).boundingRectWithSize(CGSizeMake(1000, 1000),
            options: [], attributes: [NSFontAttributeName: HashtagFont], context: nil).size
        size.width += 10 * 2
        size.height += 8 * 2
        return size
    }
}

// MARK: - MLPAutoCompleteTextField DataSource / Delegate

extension EditHashtagsViewController : MLPAutoCompleteTextFieldDelegate {
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, shouldConfigureCell cell: UITableViewCell!, withAutoCompleteString autocompleteString: String!, withAttributedString boldedString: NSAttributedString!, forAutoCompleteObject autocompleteObject: MLPAutoCompletionObject!, forRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        cell.textLabel?.text = "#" + autocompleteString
        return false
    }
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, didSelectAutoCompleteString selectedString: String!, withAutoCompleteObject selectedObject: MLPAutoCompletionObject!, forRowAtIndexPath indexPath: NSIndexPath!) {
        let hashtagText = selectedString.substringFromIndex(1)
        vm.selectHashtag(hashtagText)
        Analytics.track("Hashtag: Add", ["Text": hashtagText])
        textField.text = nil
        textField.reloadData()
    }
}

extension EditHashtagsViewController : MLPAutoCompleteTextFieldDataSource {
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!, completionHandler handler: (([AnyObject]!) -> Void)!) {
        // TODO: Dispose me
        vm.autocompleteHashtags(string).onSuccess { hashtags in
            handler(hashtags)
        }
    }
}
