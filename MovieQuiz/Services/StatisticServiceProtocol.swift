import Foundation

protocol StatisticServiceProtocol {
    var totalGamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
    func reset()
}
