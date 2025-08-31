import Foundation

struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    
    var completion: () -> Void
}
