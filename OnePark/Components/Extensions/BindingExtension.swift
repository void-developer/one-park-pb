//
//  BindingExtension.swift
//  BindingExtension
//
//  Created by Leonardo on 05/09/21.
//

import SwiftUI

extension Binding {
    func safeBinding<T>(defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>.init {
            self.wrappedValue ?? defaultValue
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
} 
