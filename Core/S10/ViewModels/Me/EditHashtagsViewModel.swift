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
    let ctx: Context
    let collection: MeteorCollection
    let subMyTags: MeteorSubscription
    let subSuggestedTags: MeteorSubscription
    
    public let placeholder: PropertyOf<String>
    public let hashtags: FetchedResultsArray<HashtagViewModel>
    
    public init(ctx: Context) {
        self.ctx = ctx
        subMyTags = ctx.meteor.subscribe("my-hashtags")
        subSuggestedTags = ctx.meteor.subscribe("suggested-hashtags")
        collection = ctx.meteor.collection("hashtags")
        
        hashtags = Hashtag
            .sorted(by: HashtagKeys.selected.rawValue, ascending: false) // Doesn't seem right, but w/e
            .results { HashtagViewModel(hashtag: $0 as! Hashtag) }
        
        let placeholders = [
            "Tag #me",
            "Tag #myClasses #econ101",
            "Tag #myProfessors #gateman",
            "Tag #myHometown #paris #vancouver",
            "Tag #myHobbies #skiing",
            "Tag #myClubs #ubccvc",
            "Tag #myResidence #gage #vanier #totem",
            "Tag #myFavouritePlaceAtUBC #roseGarden",
            "Tag #myFavouriteArtists #picasso",
            "Tag #myFavouriteMusicians #taylorswift"
        ]
        var counter = 0
        placeholder = PropertyOf(placeholders[0],
            timer(3, onScheduler: QueueScheduler.mainQueueScheduler).map { _ in
                counter++
                return placeholders[counter % placeholders.count]
            })
    }
    
    public func toggleHashtagAtIndex(index: Int) {
        let hashtag = hashtags.array[index]
        hashtag.selected ? ctx.meteor.removeHashtag(hashtag.text) : ctx.meteor.insertHashtag(hashtag.text)
    }
    
    public func selectHashtag(text: String) {
        ctx.meteor.insertHashtag(text)
    }
    
    public func autocompleteHashtags(hint: String) -> Future<[String], NSError> {
        return hint.length > 0 ? ctx.meteor.searchHashtag(hint).deliverOn(UIScheduler()) : Future(value: [])
    }
    
}