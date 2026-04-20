//
//  DailyRandomFactsViewModel.swift
//  YoteiAppExample
//
//  Created by Mikalai Zmachynski on 20/04/2026.
//

import Combine
import Foundation

final class DailyRandomFactsViewModel: ObservableObject {
    @Published var focusedDate = Date()
    
    init() {}
}
