//
//  CheckForUpdatesViewModel.swift
//  GPTSwift
//
//  Created by Elvis on 05/02/2024.
//
#if os(macOS)
import SwiftUI
import Sparkle

final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}
#endif
