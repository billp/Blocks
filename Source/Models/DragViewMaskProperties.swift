//
//  DragViewMaskProperties.swift
//  Blocks
//
//  Created by Bill Panagiotopoulos on 20/2/24.
//

import Foundation

public struct DragViewMaskProperties {
    let top: Double
    let left: Double
    let bottom: Double
    let right: Double
    let cornerRadius: Double

    public init(top: Double, right: Double, bottom: Double, left: Double, cornerRadius: Double) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.cornerRadius = cornerRadius
    }
}
