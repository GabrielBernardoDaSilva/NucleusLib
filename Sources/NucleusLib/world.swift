import Foundation
import Synchronization

final class World : @unchecked Sendable {
    let id = UUID()

    private var entites: [Entity] = []
    private var plugins: [Plugin] = []
    private var eventManager = EventManager()
    private var schedulerManager = SchedulerManager()
    private var _isRunning: Bool = false

    static let shared: World = {
        let instance = World()

        return instance
    }()

    private init() {}

    func addEntity(_ entity: Entity) {
        entites.append(entity)
    }

    @discardableResult
    func spawnEntity() -> Entity {
        let entity = Entity(self)
        addEntity(entity)
        return entity
    }

    @discardableResult
    func spawnEntityWithComponents(components: Component...) -> Entity {
        let entity = self.spawnEntity()
        for component in components {
            entity.addComponent(component)
        }
        return entity
    }

    func removeEntity(_ entity: Entity) {
        entites.removeAll { $0.id == entity.id }
    }

    func getEntity(_ id: UUID) -> Entity? {
        return entites.first { $0.id == id }
    }

    func getEntityByPredicate(_ predicate: (Entity) -> Bool) -> Entity? {
        return entites.first(where: predicate)
    }

    func getEntityByComponent<T: Component>(_ componentType: T.Type) throws -> Entity? {
        do {
            return try entites.first { try $0.getComponent(componentType) != nil }
        } catch {
            return nil
        }
    }

    func getEntitiesByComponent<T: Component>(_ componentType: T.Type) throws -> [Entity] {
        do {
            return try entites.filter { try $0.getComponent(componentType) != nil }
        } catch {
            return []
        }
    }

    func getComponents<T: Component>(_ componentType: T.Type) throws -> [T] {
        var components: [T] = []
        for entity in entites {
            if let component = try entity.getComponent(componentType) {
                components.append(component)
            }
        }
        return components
    }

    func getSingletonComponent<T: Component>(_ componentType: T.Type) throws -> T? {
        let components = try getComponents(componentType)
        guard let component = components.first else {
            throw EntityError.componentNotFound(String(describing: T.self))
        }
        return component
    }


    func publish<T: Event>(_ event: T) {
        eventManager.publish(event)
    }

    func subscribe<T: Event>(type: T.Type, callback: @escaping EventManager.EventCallback) {
        eventManager.subscribe(type: type, callback: callback)
    }

    func addPlugin(_ plugin: Plugin) {
        plugins.append(plugin)
    }


    func addScheduler(_ scheduler: Scheduler) {
        schedulerManager.addScheduler(scheduler)
    }

}

// runnable
extension World: BasicLifeTime, AdvancedLifeTime {
    func start() {
        _isRunning = true
        for plugin in plugins {
            plugin.build(world: self)
        }

        for entity in entites {
            entity.start()
        }
    }

    func update() {
        for entity in entites {
            entity.update()
        }

        schedulerManager.update(deltaTime: 1.0)
    }

    func earlyUpdate() {
        for entity in entites {
            entity.earlyUpdate()
        }
    }

    func lateUpdate() {
        for entity in entites {
            entity.lateUpdate()
        }
    }

    func run(){
        start()
        while _isRunning {
            earlyUpdate()
            update()
            lateUpdate()
        }
    }

}
