//
//  EditHashtagsViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/9/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct EditHashtagsViewModel {
    let meteor: MeteorService
    let collection: MeteorCollection
    let subMyTags: MeteorSubscription
    let subSuggestedTags: MeteorSubscription
    
    public let hashtags: FetchedResultsArray<HashtagViewModel>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        subMyTags = meteor.subscribe("my-hashtags")
        subSuggestedTags = meteor.subscribe("suggested-hashtags")
        collection = meteor.collection("hashtags")
        
        hashtags = Hashtag
            .sorted(by: HashtagKeys.selected.rawValue, ascending: false) // Doesn't seem right, but w/e
            .results { HashtagViewModel(hashtag: $0 as! Hashtag) }
    }
    
    public func toggleHashtagAtIndex(index: Int) {
        var array = hashtags.array

        if (array[index].selected) {
            meteor.removeHashtag(array[index].text).onComplete { _ in

            }
        } else {
            meteor.insertHashtag(array[index].text).onComplete { _ in

            }
        }
    }
    
    public func selectHashtag(text: String) {
//        meteor.insertHashtag(text).onComplete { _ in
//            self.hashtags.array.insert(Hashtag(text: text, selected: true), atIndex: 0)
//        }
    }
    
    public func autocompleteHashtags(hint: String) -> Future<[String], NSError> {
        return hint.length > 0 ? meteor.searchHashtag(hint).deliverOn(UIScheduler()) : Future(value: [])
    }
    
}