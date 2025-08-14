import Foundation

extension QuizQuestion {
    static func mocks() -> [QuizQuestion] {
        [
            QuizQuestion(imageName: "The Godfather",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(imageName: "The Dark Knight",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(imageName: "Kill Bill",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(imageName: "The Avengers",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(imageName: "Deadpool",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(imageName: "The Green Knight",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(imageName: "Old",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false),
            QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false),
            QuizQuestion(imageName: "Tesla",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false),
            QuizQuestion(imageName: "Vivarium",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false)
        ]
    }
}
