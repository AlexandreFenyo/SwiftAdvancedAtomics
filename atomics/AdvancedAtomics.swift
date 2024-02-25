// Objectif :
// accès atomique à un objet de type classe depuis n'importe quel thread
// types d'objets : ceux à accès possible même dans un contexte synchrone
// types d'accès :
// - dans un contexte synchrone :
//   - accès à une copie toujours possible, mais on peut demander d'avoir une erreur si on ne veut pas faire de polling (spin lock)
//   - accès exclusif pour lecture/écriture immédiat ou avec erreur : c'est un contexte synchrone donc délai de rétention court donc les autres demandes dans un contexte synchrone rendent une erreur ou font du polling
//     on doit pouvoir faire plusieurs accès simultanés
// - dans un contexte asynchrone :
//   accès toujours possible mais faire un await obligatoirement pour avoir l'accès

// on veut faire différentes opérations quand l'objet est verrouillé (par ex. récupérer une copie), on utilise pour cela une lambda fournie en paramètre

// T est le type dont on veut manipuler une instance de manière atomique
//  class Foo {
//    var bar = 0
//  }
// - soit on fait créer un AT<T> et c'est via AT qu'on permet les manips
//   let at_foo = AT<Foo>()
//   at_foo.atomic { foo in
//     foo.bar += 1
//   }
// - soit on fait dériver T d'une classe et c'est via des méthodes de cette classe que les manips seront permises
//   class Foo : AT {
//     var bar = 0
//   }
//   let at_foo = Foo()
//   at_foo.atomic {
//     self.bar += 1
//   }
//   cette solution ne marchera pas pour une struct, par ex. un tableau, mais c'est pas un pb
//   Le problème c'est qu'on ne peut alors pas créer une classe atomique dérivant déjà d'une autre
//   La solution la plus souple est donc 'est utilisant les generics
//
// On veut que la méthode de verouillage puisse être fournie en paramètre
// On crée donc un protocole AdvancedLock pour définir cette méthode de verouillage et on fournit quelques implémentations

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html

// A AFAIRE : IMPLEMENTER AWAIT

import Foundation

protocol AdvancedLock {
    static func initialize()
    static func deinitialize()
    func lock()
    func trylock() -> Bool
    func unlock()
}

class AdvancedAtomic<T> {
    let obj: T
    let lock: AdvancedLock

    init(_ obj: T, with_lock lock: AdvancedLock = SpinLock()) {
        self.obj = obj
        self.lock = lock
    }

    @discardableResult
    func atomic(_ lambda: (_ t: T) -> Sendable) -> Sendable {
        lock.lock()
        let u = lambda(obj)
        lock.unlock()
        return u
    }

    enum ShouldRetry : Error {
        case shouldRetry
    }

    func tryAtomic(_ lambda: (_ t: T) -> Sendable) -> Result<Sendable, ShouldRetry> {
        let ret = lock.trylock()
        if ret == false {
            return .failure(.shouldRetry)
        }
        let retval = lambda(obj)
        lock.unlock()
        return .success(retval)
    }
}

class Foo {
    var bar = 0
}

func test() {
    print("début")
    
    SpinLock.initialize()
    
    let at_foo = AdvancedAtomic(Foo())

    // incrémenter foo.bar
    at_foo.atomic { foo in
        foo.bar += 1
    }

    // prendre une copie de foo.bar
    let bar = at_foo.atomic { $0.bar }
    print("bar:\(bar)")
}
