//
//  File.swift
//  
//
//  Created by Bill Panagiotopoulos on 13/2/24.
//

import Foundation

protocol ObjectNameProtocol: AnyObject, NSObjectProtocol {
    static var className: String { get }
    var classNames: String { get }
}

extension ObjectNameProtocol {
    static var className: String {
        String(describing: Self.self)
    }

    var classNames: String {
        String(describing: type(of: self))
    }
}

extension NSObject: ObjectNameProtocol { }
