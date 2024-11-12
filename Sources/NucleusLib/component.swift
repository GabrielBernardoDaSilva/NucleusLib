import Foundation

class Component {
    let id = UUID()
    var entity: Entity?

}

protocol BasicLifeTime {
    func start()
    func update()
}

protocol AdvancedLifeTime {
    func earlyUpdate()
    func lateUpdate()
}
