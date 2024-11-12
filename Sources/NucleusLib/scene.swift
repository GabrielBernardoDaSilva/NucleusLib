import Foundation

struct Scene {
    let id: UUID = UUID()
    let world: World
    init(_ world: World) {
        self.world = world
    }
}


struct SceneManager: @unchecked Sendable {
    private var scenes: [Scene] = []
    private var currentScene: Scene? = nil
    private var _isRunning: Bool = false
    
    static let shared: SceneManager = {
        let instance = SceneManager()
        return instance
    }()
    private init() {}
    mutating func addScene(_ scene: Scene) {
        scenes.append(scene)
    }
    mutating func removeScene(_ scene: Scene) {
        scenes.removeAll { $0.id == scene.id }
    }
    mutating func getScene(_ id: UUID) -> Scene? {
        return scenes.first { $0.id == id }
    }
    func getSceneByPredicate(_ predicate: (Scene) -> Bool) -> Scene? {
        return scenes.first(where: predicate)
    }
    mutating func loadScene(_ scene: Scene) {
        currentScene = scene
    }
    mutating func unloadScene() {
        currentScene = nil
    }
    func getCurrentScene() -> Scene? {
        return currentScene
    }
    mutating func start() {
        _isRunning = true
        while _isRunning {
            if let scene = currentScene {
                // Update scene

                scene.world.update()


            }
        }
    }
    mutating func stop() {
        _isRunning = false
    }
}
