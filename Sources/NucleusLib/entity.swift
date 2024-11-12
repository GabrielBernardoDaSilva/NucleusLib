import Foundation

struct WeakEntity {
    weak var entity: Entity?
}

final class Entity: BasicLifeTime, AdvancedLifeTime {

    unowned let world: World
    private var components: [Component] = []
    private let _id: UUID = UUID()

    var id: UUID {
        return _id
    }

    private var name: String = ""

    private var userData: [String: Any] = [:]

    private var children: [WeakEntity] = []

    private var parent: WeakEntity? = nil

    init(_ world: World) {
        self.world = world
    }

    func addComponent(_ component: Component) {
        component.entity = self
        components.append(component)
    }

    func removeComponent(_ component: Component) {
        components.removeAll { $0.id == component.id }
    }

    func getComponent<T: Component>(_ type: T.Type) throws -> T? {
        guard let component = components.first(where: { $0 is T }) as? T else {
            throw EntityError.componentNotFound(String(describing: T.self))
        }
        return component
    }

    func addChild(_ entity: Entity) {
        let weakEntity = WeakEntity(entity: entity)
        entity.parent = WeakEntity(entity: self)
        children.append(weakEntity)
    }

    func removeChild(_ entity: Entity) {
        children.removeAll { $0.entity?.id == entity.id }
    }

    func getChildren() -> [WeakEntity] {
        return children
    }

    func getChildByName(_ name: String) -> Entity? {
        return children.first { $0.entity?.name == name }?.entity
    }

    func addUserData<T>(_ key: String, _ value: T) {
        userData[key] = value
    }

    func getUserData<T>(_ key: String) -> T? {
        return userData[key] as? T
    }
    func start() {
        for component in components {
            if let component = component as? BasicLifeTime {
                component.start()
            }
        }
    }

    func update() {
        for component in components {
            if let component = component as? BasicLifeTime {
                component.update()
            }
        }
    }

    func earlyUpdate() {
        for component in components {
            if let component = component as? AdvancedLifeTime {
                component.earlyUpdate()
            }
        }
    }

    func lateUpdate() {
        for component in components {
            if let component = component as? AdvancedLifeTime {
                component.lateUpdate()
            }
        }
    }

}
