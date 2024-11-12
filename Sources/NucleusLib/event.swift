protocol Event {

}

struct EventManager {
    typealias EventCallback = (Event) -> Void

    private var event: Event?{
        didSet {
            if let event = event {
                if let callbacks = subscribedComponents[String(describing: type(of: event))] {
                    for callback in callbacks {
                        callback(event)
                    }
                }
            }
        }
    }


    private var subscribedComponents: [String: [EventCallback]] = [:]


    mutating func publish<T: Event>(_ event: T) {
        self.event = event
    }

    mutating func subscribe<T: Event>(type: T.Type, callback: @escaping EventCallback) {
        let key = String(describing: type)
        if subscribedComponents[key] == nil {
            subscribedComponents[key] = []
        }
        subscribedComponents[key]?.append(callback)
    }




}


