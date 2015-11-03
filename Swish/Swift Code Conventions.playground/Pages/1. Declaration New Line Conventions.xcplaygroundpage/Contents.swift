//: # Swift Code Conventions from Yooii Studios

//: ## 1. 선언부 다음 라인 개행
//: > 검색을 해 봐도 이 부분에 일치하는 하나의 코드 컨벤션이 존재하지 않아 우선적으로 먼저 정리를 하기로 한다. 

/*:
## **대원칙**
1. 타입이 모두 같아서 분산이 되지 않는 경우 선언부 다음 개행을 하지 않음
2. 구현부(method or computed property)가 있는 경우 선언부 하단 개행 필요
3. property나 method 선언들 사이 개행이 생긴 경우 선언부 하단 개행 필요

예외: 바디가 없는 클로져의 경우는 한 라인으로 처리
*/

import UIKit
import CoreLocation

//: ## **Protocol**

//: 대원칙 1에 따라 개행하지 않음
protocol PhotoPickable {
    func pick()
}

protocol LocationTrackable {
    func startTracking()
    func stopTracking()
}

//: 타입이 다른 조합의 선언이 있을 경우(변수 + 함수 or 다른 두 가지 이상의 조합) 개행 필요
protocol Runnable {
    
    var a: Int { get }
    
    func run()
    func stop()
}

//: ## **Struct, Class**

//: 아래와 같이 변수(var let 조합이여도) 선언만 있을 경우는 개행을 하지 말 것, 주석이 있다 하더라도 개행은 하지 말 것
struct House {
    weak var photo: Photo?
    let name: [Int]
}

//: computed property의 경우에는 하나만 있어도 개행을 해 줄 것, 그리고 computed property 사이는 개행을 넣지 않는다.
class Photo {
    
    var image: UIImage? {
        return nil
    }
    var id: Double {
        return 100
    }
}

//: 다만 아래와 같이 의도적으로 변수 선언을 나누어서 개행이 생길 경우 선언부 하단에도 개행이 필요
struct Car {
    
    let frame: CGRect
    var engine: Runnable
    var wheels: [Int]
    
    // About Driver
    let driver: Double
    var isDriverIn: Bool
}

//: protocol과 마찬가지로 변수 + 함수 조합의 경우 개행 필요
struct Location {
    
    var latitude: Double
    let longitude: Double
    
    func compute() {
        
    }
    
    func moveToPoint(point: CLLocation) {
        
    }
}

//: 다음과 같이 클로져의 바디가 없는 경우 한 라인에 처리
final class RealmObjectBuilder {
    static let realBuilder = { (object: Car) -> Void in }
    static let testBuilder = { (object: Car) -> Void in }
}

//: ## **Enumeration**

//: 구현부가 없는 경우 개행하지 말 것
enum PhotoType: String {
    case Wide
    case Narrow = "Narrrrrow"
    case Fullscreen
}

//: 구현부가 생긴 경우 선언부 하단 개행 필요
enum SeugeType: String {
    
    case Main
    case Dressing
    case ShareResult
    
    func simpleDescription() -> String {
        switch self {
        case .Main:
            return "Main Screen"
        case .Dressing:
            return "Dressing Screen"
        case .ShareResult:
            return "Share Result Screen"
        }
    }
}
