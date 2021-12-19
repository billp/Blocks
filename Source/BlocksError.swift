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
    case invalidViewClass
}

extension BlocksError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidModelClass:
            return NSLocalizedString("Invalid model class provided. Your model should conform to: " +
                                     "ComponentViewModelNibInitializable or " +
                                     "ComponentViewModelClassInitializable", comment: "Blocks")
        case .invalidViewClass:
            return NSLocalizedString("Invalid view class provided. Your view class model should conform to: " +
                                     "ComponentViewProtocol", comment: "Blocks")
        }
    }
}
