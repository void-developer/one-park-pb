//
//  DateUtility.swift
//  DateUtility
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI

class DateUtility {
    
    static var standardDataFormat = "DD/MM/YYYY"
    
    static func convertDateToString(dob: Date) -> String {
        if #available(iOS 15.0, *) {
            return dob.formatted(.dateTime)
        } else {
            let dateFormatter = DateFormatter()
            //dateFormatter.dateStyle = .short
            dateFormatter.dateFormat = standardDataFormat
            return dateFormatter.string(from: dob)
        }
    }
}
