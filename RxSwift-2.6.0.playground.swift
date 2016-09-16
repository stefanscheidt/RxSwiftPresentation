//: Please build the scheme 'RxSwiftPlayground' first
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import RxSwift

func exampleOf(description: String, active: Bool = false, @noescape action: Void -> Void) {
    if active {
        print("\n--- Example of:", description, "---")
        action()
    }
}

exampleOf("of") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2 ,3)
        .subscribe { event in
            print(event)
        }.addDisposableTo(disposeBag)
}

exampleOf("cold") {
    let disposeBag = DisposeBag()
    let observable = Observable.of(1, 2)
    observable
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    observable
        .subscribe { print($0)}
        .addDisposableTo(disposeBag)
}

exampleOf("hot") {
    let pub = PublishSubject<Int>()
    pub.onNext(1)
    let sub1 = pub.subscribe { print("sub1: \($0)") }
    pub.onNext(2)
    let sub2 = pub.subscribe { print("sub2: \($0)") }
    pub.onNext(3)
    sub2.dispose()
    pub.onCompleted()
}


exampleOf("interval") {
    let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.rewe-digital.rxswift.interval")
    let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
        .subscribe { event in
            print(event)
    }

    NSThread.sleepForTimeInterval(2.0)

    subscription.dispose()
}

func pulse(interval: NSTimeInterval) -> Observable<Int> {
    return Observable.create { observer in
        print("Subscribed")

        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, 0, UInt64(interval * Double(NSEC_PER_SEC)), 0)

        let cancel = AnonymousDisposable {
            print("Disposed")
            dispatch_source_cancel(timer)
        }

        var next = 0
        dispatch_source_set_event_handler(timer, {
            if cancel.disposed { return }
            observer.onNext(next)
            next += 1
        })
        dispatch_resume(timer)

        return cancel
    }
}

exampleOf("pulse") {
    let subscription = pulse(0.5)
        .subscribeNext { print($0) }
    NSThread.sleepForTimeInterval(2.0)
    subscription.dispose()
}

exampleOf("pulse - cold") {
    let counter = pulse(0.1)
    let sub1 = counter.subscribeNext { print("Sub1:  \($0)") }
    let sub2 = counter.subscribeNext { print("Sub2:  \($0)") }

    NSThread.sleepForTimeInterval(0.3)
    sub1.dispose()

    NSThread.sleepForTimeInterval(0.3)
    sub2.dispose()
}

exampleOf("share replay", active: true) {
    let counter = pulse(0.1).shareReplay(1)
    let sub1 = counter.subscribeNext { print("Sub1:  \($0)") }
    let sub2 = counter.subscribeNext { print("Sub2:  \($0)") }

    NSThread.sleepForTimeInterval(0.3)
    sub1.dispose()

    NSThread.sleepForTimeInterval(0.3)
    sub2.dispose()
}

exampleOf("debug") {
    let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.rewe-digital.rxswift.interval")
    let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
        .debug("debugging ...")
        .map { "Simply \($0)"}
        .subscribeNext { print($0) }
    NSThread.sleepForTimeInterval(1.0)
    subscription.dispose()
}
