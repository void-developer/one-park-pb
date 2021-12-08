//
//  KeyboardPicker.swift
//  KeyboardPicker
//
//  Created by Leonardo Angeli on 08/09/21.
//

import SwiftUI

struct KeyboardPicker : UIViewRepresentable {
    
    var data : [KeyValuePair]
    var placeholder : String
    
    @Binding var selection : KeyValuePair
    @Binding var selectedText : String?
    
    private let textField = UITextField()
    private let picker = UIPickerView()
    
    func makeCoordinator() -> KeyboardPicker.Coordinator {
        Coordinator(textfield: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<KeyboardPicker>) -> UITextField {
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.backgroundColor = .gray
        picker.tintColor = .black
        textField.placeholder = placeholder
        textField.inputView = picker
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<KeyboardPicker>) {
        uiView.text = selectedText
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate {
        
            private let parent : KeyboardPicker
            
            init(textfield : KeyboardPicker) {
                self.parent = textfield
            }
            
            func numberOfComponents(in pickerView: UIPickerView) -> Int {
                return 1
            }
        
            func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                return self.parent.data.count
            }
        
            func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                return self.parent.data[row].value
            }
        
            func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                self.parent.selection = parent.data[row]
                self.parent.selectedText = self.parent.selection.value
                self.parent.textField.endEditing(true)
                
            }
        
            func textFieldDidEndEditing(_ textField: UITextField) {
                self.parent.textField.resignFirstResponder()
            }
        }
}
