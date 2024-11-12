import Foundation

enum SchedulerLifeTime {
    case OnlyOnce
    case Repeat(Int)
    case RepeatForever
}

class Scheduler {
    typealias Task = () -> Void

    let id: UUID = UUID()

    private var task: Task

    private var _isRunning: Bool = false
    private var _amountToWait: TimeInterval = 0.0
    private var _totalAmountToWait: TimeInterval = 0.0
    private var _lifeTime: SchedulerLifeTime = .OnlyOnce

    init(
        _ amountToWait: TimeInterval,
        _ lifeTime: SchedulerLifeTime,
        _ task: @escaping Task
    ) {
        self._amountToWait = amountToWait
        self._totalAmountToWait = amountToWait
        self._lifeTime = lifeTime
        self.task = task
        self._isRunning = true
    }

    func update(deltaTime dt: Double) {
        if _isRunning {
            _amountToWait -= dt
            
            if _amountToWait <= 0 {
                task()
                switch _lifeTime {
                case .OnlyOnce:
                    _isRunning = false
                case .Repeat(let times):
                    if times > 0 {
                        _lifeTime = .Repeat(times - 1)
                        _amountToWait = _totalAmountToWait
                    } else {
                        _isRunning = false
                    }
                case .RepeatForever:
                    _amountToWait = _totalAmountToWait
                }
            }
        }
    }

}

struct SchedulerManager {
    private var schedulers: [Scheduler] = []

    init() {}

    mutating func addScheduler(_ scheduler: Scheduler) {
        schedulers.append(scheduler)
    }
    mutating func removeScheduler(_ scheduler: Scheduler) {
        schedulers.removeAll { $0.id == scheduler.id }
    }
    mutating func getScheduler(_ id: UUID) -> Scheduler? {
        return schedulers.first { $0.id == id }
    }
    func getSchedulerByPredicate(_ predicate: (Scheduler) -> Bool) -> Scheduler? {
        return schedulers.first(where: predicate)
    }
    mutating func update(deltaTime dt: Double) {
        for scheduler in schedulers {
            scheduler.update(deltaTime: 1.0)
        }
    }

}
