// Copyright © 2015 Okanagan College
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


//  ReadableRepository.swift
//  AstroCalendar
//
//  Created by Francis Bailey on 2015-03-15.
//  Copyright (c) 2015 Okanagan College. All rights reserved.
//
//
//  Version History
//
//  Author          Date            Description
//  ===============================================================================
//  Francis         18/03/2015      Added @objc to fix compiler errors




import Foundation


protocol ReadableRepository {
    
    func query( query : String, parameters : [AnyObject]? ) -> [ReadableRepositoryRow]
    init( filename : String, gid : String )

}

@objc protocol ReadableRepositoryRow {
    var data : Dictionary<String, ReadableRepositoryCol> { get set }

    subscript(key: String) -> ReadableRepositoryCol? {
        get
        set
    }
    
    func description()->String
}

@objc protocol ReadableRepositoryCol {
    
    // New conversion functions
    func asString()->String
    
    func asInt()->Int
    
    func asDouble()->Double
    
    func asData()->NSData?
    
    func asDate()->NSDate?
    
    func description()->String
}