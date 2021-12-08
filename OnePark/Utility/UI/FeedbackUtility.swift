//
//  FeedbackUtility.swift
//  OnePark
//
//  Created by Leonardo on 16/08/21.
//

import SwiftUI

func haptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    UINotificationFeedbackGenerator().notificationOccurred(type)
}

func impact(intensity: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: intensity).impactOccurred()
}
