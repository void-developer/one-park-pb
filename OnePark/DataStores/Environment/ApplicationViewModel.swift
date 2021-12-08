//
//  ApplicationViewModel.swift
//  ApplicationViewModel
//
//  Created by Leonardo Angeli on 05/09/21.
//

import SwiftUI

class ApplicationViewModel: ObservableObject {
    
    @Published var errors: String = ""
    @Published var error: NSError?
    
    @Published var hasErrors: Bool = false
    
    @Published var isPopupActive: Bool = false

    func setErrors(_ errors: String) {
        DispatchQueue.main.async {
            self.errors = errors
        }
    }
    
    func togglePopupBg() {
        DispatchQueue.main.async {
            self.isPopupActive.toggle()
        }
    }
    
    func setApplicationError(_ error: NSError) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}

