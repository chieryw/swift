// RUN: %target-parse-verify-swift

protocol Observer {
    associatedtype Value
    
    func onNext(_ item: Value) -> Void
    func onCompleted() -> Void
    func onError(_ error: String) -> Void
}

protocol Observable {
    associatedtype Value

    func subscribe<O: Observer where O.Value == Value>(_ observer: O) -> Any
}

class Subject<T>: Observer, Observable {
    typealias Value = T
    
    // Observer implementation
    
    var onNextFunc: ((T) -> Void)? = nil
    var onCompletedFunc: (() -> Void)? = nil
    var onErrorFunc: ((String) -> Void)? = nil
    
    func onNext(_ item: T) -> Void {
        onNextFunc?(item)
    }
    
    func onCompleted() -> Void {
        onCompletedFunc?()
    }
    
    func onError(_ error: String) -> Void {
        onErrorFunc?(error)
    }
    
    // Observable implementation
    
    func subscribe<O: Observer where O.Value == T>(_ observer: O) -> Any {
        self.onNextFunc = { (item: T) -> Void in
            observer.onNext(item)
        }
        
        self.onCompletedFunc = {
            observer.onCompleted()
        }
        
        self.onErrorFunc = { (error: String) -> Void in
            observer.onError(error)
        }
        
        return self
    }
}

protocol P {
    associatedtype A
    
    func onNext(_ item: A) -> Void
}

struct IP<T> : P {
    typealias A = T

    init<O:P>(x:O) where O.A == IP.A {
       _onNext = { (item: A) in x.onNext(item) }
    }

    func onNext(_ item: A) { _onNext(item) }

    var _onNext: (A) -> ()
}
