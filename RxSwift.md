autoscale: true

# RxSwift

# RxCocoa

---

# About me

[@stefanscheidt](https://twitter.com/stefanscheidt)

Software Engineer @ [REWE digital](https://rewe-digital.com/)

mostly Java, some JavaScript, iOS & Swift Newbie

---

## Asynchronous Programming<br>with Observable Streams<br>for Swift and Cocoa

---

# Reactive Extentions History

*   2009: Rx.NET
*   2010: RxJS
*   2012: RxJava, RxCpp, RxRuby
*   2013: RxScala, RxClojure, RxKotlin, RxPY ... (ReactiveCocoa)
*   2015: RxSwift

---

# RxSwift Fact Sheet

*   Swift Support: 2.3, 3.0 (Beta)
*   Code Quality: see [CocoaPods](https://cocoapods.org/pods/RxSwift/quality)
*   Contributors & Activity: see [GitHub](https://github.com/ReactiveX/RxSwift/graphs/contributors)
*   External Dependencies: Non
*   Usage via CocoaPods, Carthage, Git Submodules
*   [Community Extentions](https://github.com/RxSwiftCommunity)

^ The main contributor, [Krunoslav Zaher](https://github.com/kzaher), works for Rhapsody Napster.

---

# Basic Concepts

---

# Observable Sequences:<br>Push vs. Pull [^1]

*   `Observable<Element>` eq. `SequenceType`
*   `ObservableType.subscribe`
    -   eq. `SequenceType.generate`
    -   vs. `generator.next`
*   But can also receive elements asynchronously!

[^1]: [RxSwift Getting Started](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#observables-aka-sequences)

---

# Events

`next* (error | completed)?`

*   Sequences can have 0 or more elements
*   Once an error or completed event is received, the sequence cannot produce any other element

---

# Examples[^2]

```swift
Observable.of(1, 2, 3)
    .subscribe { print($0) }
```

will print

```
next(1)
next(2)
next(3)
completed
```

[^2]: using RxSwift 3.0.0-beta.1

---

# Disposing

release all allocated resources:

```swift
Observable.of(1, 2 ,3)
    .subscribe { print($0) }
    .dispose()
```

or better

```swift
let disposeBag = DisposeBag()
Observable.of(1, 2 ,3)
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
```

---

# Operators [^3]

*   Creating
*   Transforming
*   Filtering
*   Combining

[^3]: <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/API.md>

---

## Rx Marbles

<http://rxmarbles.com/>

<https://github.com/RxSwiftCommunity/RxMarbles>

---

# Sequence Generation

*When does an Observable begin emitting its items?*[^4]

"Cold" Observable:<br>waits until an observer subscribes

"Hot" Observable:<br>may begin emitting items as soon as created

[^4]: See also [Hot and Cold Observables](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)

---

# Cold Observables

```swift
let disposeBag = DisposeBag()
let observable = Observable.of(1, 2)
observable.subscribe { print($0) }.addDisposableTo(disposeBag)
observable.subscribe { print($0) }.addDisposableTo(disposeBag)
```

will print

```
next(1)
next(2)
completed
next(1)
next(2)
completed
```

---

# "Hot" Observables

```swift
 let pub = PublishSubject<Int>()
 pub.onNext(1)
 let sub1 = pub.subscribe { print("sub1: \($0)") }
 pub.onNext(2)
 let sub2 = pub.subscribe { print("sub2: \($0)") }
 pub.onNext(3)
 sub2.dispose()
 pub.onCompleted()
```

will print

```
sub1: next(2)
sub1: next(3)
sub2: next(3)
sub1: completed
```

---

# Create Observables

```swift
func interval(_ interval: TimeInterval) -> Observable<Int> {
    return Observable.create { observer in
        print("Subscribed")
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.scheduleRepeating(deadline: DispatchTime.now() + interval, interval: interval)
        let cancel = Disposables.create {
            print("Disposed")
            timer.cancel()
        }

        var count = 0
        timer.setEventHandler {
            if cancel.isDisposed { return }
            observer.on(.next(count))
            count += 1
        }
        timer.resume()

        return cancel
    }
}
```

---

# Create Observables

```swift
let counter = interval(0.5).subscribe { print($0) }
Thread.sleep(forTimeInterval: 2.0)
counter.dispose()
```

will print

```
Subscribed
0
1
2
3
Disposed
```

---

# Cold Observables - again

```swift
let counter = interval(0.1)
let sub1 = counter.subscribe(onNext: { print("Sub1:  \($0)") })
let sub2 = counter.subscribe(onNext: { print("Sub2:  \($0)") })
Thread.sleep(forTimeInterval: 0.3)
sub1.dispose()
Thread.sleep(forTimeInterval: 0.3)
sub2.dispose()
```

will print ...

---

# Cold Observables - again

```
Subscribed
Subscribed
Sub1:  0
Sub2:  0
Sub1:  1
Sub2:  1
Sub1:  2
Sub2:  2
Disposed
Sub2:  3
Sub2:  4
Disposed
```

---

# Share Replay

```swift
let counter = interval(0.1).shareReplay(1)
let sub1 = counter.subscribe(onNext: { print("Sub1:  \($0)") })
let sub2 = counter.subscribe(onNext: { print("Sub2:  \($0)") })
Thread.sleep(forTimeInterval: 0.3)
sub1.dispose()
Thread.sleep(forTimeInterval: 0.3)
sub2.dispose()
```

will print ...

---

# Share Replay

```
Subscribed
Sub1:  0
Sub2:  0
Sub1:  1
Sub2:  1
Sub1:  2
Sub2:  2
Sub2:  3
Sub2:  4
Sub2:  5
Disposed
```

---

# Schedulers[^5]

**Schedulers abstract away the mechanism for performing work**

*   `CurrentThreadScheduler`: serial on current thread
*   `MainScheduler`: serial on main thread
*   `SerialDispatchQueueScheduler`: serial on dispatch queue
*   `ConcurrentDispatchQueueScheduler`: concurrent on dispatch queue
*   `OperationQueueScheduler`: concurrent on operation queue

[^5]: <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md>

---

# Observe On Scheduler

```swift
sequence
    .observeOn(backgroundScheduler)
    .map { _ in
        print("This is performed on backgroundScheduler")
    }
    .observeOn(MainScheduler.instance)
    .map { _ in
        print("This is performed on the main thread")
    }
```

---

# Observe On Scheduler

```swift
let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName:
    "com.rewe-digital.rxswift.interval")
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
    .map { "Simply \($0)"}
    .subscribe(onNext: { print($0) })
Thread.sleep(forTimeInterval: 1.0)
subscription.dispose()
```

will print

```
Simply 0
Simply 1
Simply 2
```

---

# Debugging

```swift
let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName:
    "com.rewe-digital.rxswift.interval")
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
    .debug("debugging ...")
    .map { "Simply \($0)"}
    .subscribe(onNext: { print($0) })
Thread.sleep(forTimeInterval: 1.0)
subscription.dispose()
```

---

# Debugging

will print

```
2016-09-09 16:42:29.871: debugging ... -> subscribed
2016-09-09 16:42:30.172: debugging ... -> Event next(0)
Simply 0
2016-09-09 16:42:30.475: debugging ... -> Event next(1)
Simply 1
2016-09-09 16:42:30.775: debugging ... -> Event next(2)
Simply 2
2016-09-09 16:42:30.873: debugging ... -> disposed
```

---

# Testing

*   [XCTestExpectation](https://developer.apple.com/reference/xctest/xctestexpectation)
*   [RxTests](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/UnitTests.md)

---

# RxSwift Examples

See [Rx.playground](https://github.com/ReactiveX/RxSwift/tree/master/Rx.playground)

---

# RxCocoa

---

# Units

Important properties when writing Cocoa/UIKit applications:

*   Subscribe to properties, events on main thread
*   Observe on main thread
*   Share events
*   Don't error out

---

# Units

Units[^6] are convenient wrapper around observables for writing UI code

*   `ControlProperty`
*   `ControlEvent`
*   `Driver`

[^6]: <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Units.md>

---

# Why Units?

```swift
let results = query.rx.text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { fetchItems($0) }

results.map { "\($0.count)" }
    .bindTo(resultCount.rx.text)
    .addDisposableTo(disposeBag)

results.bindTo(tableView.rx.itemsWithCellIdentifier("Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }.addDisposableTo(disposeBag)
```

---

# Problems with this code ...

*   If `fetchItems` errors out, everything would unbind
*   If it returns on some background thread, results would be bound to UI there
*   Results are bound to two UI elements, so two HTTP requests would be made

---

# So ...

```swift
let results = query.rx.text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { fetchItems($0)
        .observeOn(MainScheduler.instance)
        .catchErrorJustReturn([])
    }.shareReplay(1)

results.map { "\($0.count)" }
    .bindTo(resultCount.rx.text)
    .addDisposableTo(disposeBag)

results.bindTo(tableView.rx.itemsWithCellIdentifier("Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }.addDisposableTo(disposeBag)
```

---

# Therefore: Driver

```swift
let results = query.rx.text.asDriver()
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { fetchItems($0)
        .asDriver(onErrorJustReturn: [])
    }

results.map { "\($0.count)" }
    .drive(resultCount.rx.text)
    .addDisposableTo(disposeBag)

results.drive(tableView.rx.itemsWithCellIdentifier("Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }.addDisposableTo(disposeBag)
```

---

# RxCocoa Examples

See [RxExample](https://github.com/ReactiveX/RxSwift/tree/master/RxExample)

---

# Other options

*   [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) + [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
*   [Interstellar](https://github.com/JensRavens/Interstellar)
*   [FutureKit](https://github.com/FutureKit/FutureKit)
    -   [AltConf Talk by Michael Gray](https://realm.io/news/altconf-michael-gray-futures-promises-gcd/)

---

# By the way ...

Observable Sequences are Monads[^7]

[^7]: [Swift Functors, Applicatives, and Monads in Pictures](http://www.mokacoding.com/blog/functor-applicative-monads-in-pictures/)

---

# Thank you![^8]

[^8]: Slide deck sources on [GitHub](https://github.com/stefanscheidt/RxSwiftPresentation)