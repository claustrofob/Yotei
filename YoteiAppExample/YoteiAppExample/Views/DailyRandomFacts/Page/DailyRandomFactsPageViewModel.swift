//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Combine
import Foundation
import FoundationModels

@MainActor
final class DailyRandomFactsPageViewModel: ObservableObject {
    struct UnavailableError: LocalizedError {
        let text: String
        var errorDescription: String? {
            text
        }
    }

    enum State {
        case loading
        case loaded(String)
        case error(Error)
    }

    @Published var state: State = .loading

    private var task: Task<Void, Never>?

    init() {}

    @available(iOS 26.0, *)
    private func checkLLMAvailability() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(.appleIntelligenceNotEnabled):
            throw UnavailableError(text: "Apple Intelligence is not enabled. Turn it on in Settings.")
        case .unavailable(.deviceNotEligible):
            throw UnavailableError(text: "This device does not support Apple Intelligence.")
        case .unavailable(.modelNotReady):
            throw UnavailableError(text: "The on-device model is not ready yet. Please try again later.")
        case let .unavailable(other):
            throw UnavailableError(text: "The on-device model is unavailable (\(other)).")
        }
    }

    @available(iOS 26.0, *)
    private func generateRandomFact(date: Date) {
        state = .loading
        task?.cancel()
        task = Task { [weak self] in
            do {
                try self?.checkLLMAvailability()

                let session = LanguageModelSession(instructions: """
                    Pretend to be a historian sharing a single interesting random fact about the given date. \
                    Do not find real facts but rather fabricate some harmless fun fact for that date about some fiction event.
                    Respond only with the fact in one or two sentences, no preface.
                """)
                let response = try await session.respond(to: "Share a random historical or fun fact for \(date.formatted()).")

                try Task.checkCancellation()
                self?.state = .loaded(response.content)
            } catch is CancellationError {
                return
            } catch {
                self?.state = .error(error)
            }
        }
    }

    func viewDidAppear(date: Date) {
        if #available(iOS 26.0, *) {
            generateRandomFact(date: date)
        } else {
            state = .error(UnavailableError(text: "This example only works on iOS 26.0 and above"))
        }
    }
}
