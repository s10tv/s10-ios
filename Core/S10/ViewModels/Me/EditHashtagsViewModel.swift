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
    
    public let hashtags: ArrayProperty<Hashtag>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        subMyTags = meteor.subscribe("my-hashtags")
        subSuggestedTags = meteor.subscribe("suggested-hashtags")
        collection = meteor.collection("hashtags")
        hashtags = ArrayProperty([
            Hashtag(text: "eco101", selected: true),
            Hashtag(text: "taylrswift", selected: true),
            Hashtag(text: "skiing", selected: true),
            Hashtag(text: "snowboard", selected: true),
            Hashtag(text: "manila", selected: true),
            Hashtag(text: "surf", selected: true),
            Hashtag(text: "paris", selected: false),
            Hashtag(text: "gateman", selected: false),
            Hashtag(text: "ubcpride", selected: false),
            Hashtag(text: "leagueoflegends", selected: false)
        ])
    }
    
    public func toggleHashtagAtIndex(index: Int) {
        var array = hashtags.array
        array[index].selected = !array[index].selected
        hashtags.array = array
    }
    
    public func selectHashtag(text: String) {
        hashtags.array.insert(Hashtag(text: text, selected: true), atIndex: 0)
    }
    
    public func autocompleteHashtags(hint: String) -> Future<[Hashtag], NSError> {
        return self.meteor.searchHashtag(hint);
    }
    
}