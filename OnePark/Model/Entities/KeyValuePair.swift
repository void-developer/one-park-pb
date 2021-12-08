//
//  KeyValuePair.swift
//  KeyValuePair
//
//  Created by Leonardo Angeli on 04/09/21.
//

import SwiftUI

struct KeyValuePair: Identifiable, Hashable, Equatable {
    var id: String
    var value: String
    
    init(key id: String, value: String) {
        self.id = id
        self.value = value
    }
}
