//
//  Error.swift
//  BlocksTests
//
//  Created by Vassilis Panagiotopoulos on 19/12/21.
//

import Foundation

/// Custom implementation of errors for Blocks.
enum BlocksError: Error {
    /// Thowed when invalid model class is provided.
    case invalidModelClass
    /// Thowed when invalid view class is provided.
    case invalidViewClass(reuseIdentifier: String)
}

extension BlocksError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidModelClass:
            return NSLocalizedString("Invalid model class provided. Your model should conform to: " +
                                     "NibComponent or ClassComponent", comment: "Blocks")
        case .invalidViewClass(let reuseIdentifier):
            return NSLocalizedString("Your view class with reuseIdentifier '\(reuseIdentifier)' should conform to '" +
                                     String(describing: ComponentViewConfigurable.self) + "'", comment: "Blocks")
        }
    }

    func keyForProtocol<P>(aProtocol: P.Type) -> String {
        return ("\(aProtocol)")
    }
}
