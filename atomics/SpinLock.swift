
import Foundation

class SpinLock : AdvancedLock {
    var locked: Bool = false
    
    static func initialize() {
        let ret = pthread_locks_init()
        if ret < 0 { fatalError() }
    }

    static func deinitialize() {
        let ret = pthread_locks_deinit()
        if ret < 0 { fatalError() }
    }

    func lock() {
        var must_retry = true
        repeat {
            var ret = pthread_locks_lock()
            if ret < 0 { fatalError() }
            
            if locked == false {
                must_retry = false
                locked = true
            }

            ret = pthread_locks_unlock()
            if ret < 0 { fatalError() }
        } while must_retry == true
    }
    
    // retval:
    // true: locked
    // false: should retry
    func trylock() -> Bool {
        var ret = pthread_locks_trylock()
        if ret < 0 { fatalError() }
        if ret == 1 { return false }
        if locked == true {
            ret = pthread_locks_unlock()
            if ret < 0 { fatalError() }
            return false
        }
        locked = true
        ret = pthread_locks_unlock()
        if ret < 0 { fatalError() }
        return true
    }
    
    func unlock() {
        var ret = pthread_locks_lock()
        if ret < 0 { fatalError() }
            
        locked = false

         ret = pthread_locks_unlock()
         if ret < 0 { fatalError() }
    }
}
