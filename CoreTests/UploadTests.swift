//
//  UploadTests.swift
//  S10
//
//  Created by Tony Xiao on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Quick
import Nimble

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("the 'Documentation' directory") {
            it("has everything you need to get started") {
                let variable = 1232
                expect(variable) == 1232
//                let sections = Directory("Documentation").sections
//                expect(sections).to(contain("Organized Tests with Quick Examples and Example Groups"))
//                expect(sections).to(contain("Installing Quick"))
            }
            
            context("if it doesn't have what you're looking for") {
                it("needs to be updated") {
                    let variable = 1111
                    expect { variable }.toEventually(equal(1111))
//                    let you = You(awesome: true)
//                    expect{you.submittedAnIssue}.toEventually(beTruthy())
                }
            }
        }
    }
}