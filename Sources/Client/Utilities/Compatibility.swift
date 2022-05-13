//
//  Compatibility.swift
//  Client
//
//  Created by liang2kl on 2022/5/10.
//

import SwiftUI

// Some fallback for macOS 11 (and iOS 14)
extension View {
    @ViewBuilder func blurBackground() -> some View {
        if #available(iOS 15.0, *) {
            self.background(.ultraThinMaterial)
        } else {
            self.background(Color(UIColor.systemBackground))
        }
    }
    
    @ViewBuilder func topSafeAreaInset<Content: View>(content: () -> Content) -> some View {
        if #available(iOS 15.0, *) {
            self.safeAreaInset(edge: .top, content: content)
        } else {
            VStack(spacing: 0) {
                content()
                self
            }
        }
    }
    
    @ViewBuilder func bottomSafeAreaInset<Content: View>(content: () -> Content) -> some View {
        if #available(iOS 15.0, *) {
            self.safeAreaInset(edge: .bottom, content: content)
        } else {
            VStack(spacing: 0) {
                self
                content()
            }
        }
    }

}
