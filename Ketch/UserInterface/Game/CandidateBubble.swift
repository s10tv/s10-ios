//
//  CandidateBubble.swift
//  Ketch
//
//  Created by Tony Xiao on 3/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class CandidateBubble : UserAvatarView {

    var candidate: Candidate? {
        didSet { user = candidate?.user }
    }

    var drag : UIAttachmentBehavior?
    var dropzone: CandidateDropZone? {
        didSet {
            oldValue?.freeBubble()
            dropzone?.dropBubble(self)
        }
    }
}
