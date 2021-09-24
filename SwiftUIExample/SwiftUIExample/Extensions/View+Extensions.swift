//
//  View+Extensions.swift
//  SwiftUIExample
//
//  Created by James Hickman on 3/3/21.
//

import SwiftUI

extension View {

    func isVisible(_ isVisible: Binding<Bool>) -> some View {
        modifier(VisibilityStyle(isVisible: isVisible))
    }

    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}

extension Binding where Value == Bool {

    var not: Binding<Bool> {
        return Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }

}

struct VisibilityStyle: ViewModifier {

   @Binding var isVisible: Bool
   func body(content: Content) -> some View {
      Group {
         if isVisible {
            content
         } else {
            content.hidden()
         }
      }
   }

}
