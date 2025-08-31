import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
        case correctAnswers
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let bestGameCorrect = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let bestGameTotal = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let bestGameDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: bestGameCorrect, total: bestGameTotal, date: bestGameDate)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        return Double(correctAnswers) / Double(totalQuestionsAsked) * 100.0
    }
    
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
            }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
            }
        }
    private var totalQuestionsAsked: Int {
        get {
            return storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
            }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
            }
        }
    
    func store(correct count: Int, total amount: Int) {
            if bestGame.correct < count {
                bestGame = GameResult(correct: count, total: amount, date: Date())
            }
            gamesCount += 1
            correctAnswers += count
            totalQuestionsAsked += amount
        }

}
