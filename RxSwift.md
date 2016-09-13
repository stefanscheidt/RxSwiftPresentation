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
*   2013: RxScala, RxClojure, RxGroovy, RxJRuby, RxPY, RxPHP, RxKotlin, ReactiveCocoa
*   2015: RxSwift

---

# RxSwift Fact Sheet

*   Swift Support: 2.3, 3.0 (Alpha)
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

*   `Obeservable<Element>` eq. `SequenceType`
*   `ObservableType.subscribe` eq. `SequenceType.generate`
*   `observable.subscribe(observer)` vs. `generator.next`
*   But an observable can also receive elements asynchronously

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
    .subscribe { event in
        print(event)
    }
```

will print

```
Next(1)
Next(2)
Next(3)
Completed
```

[^2]: using RxSwift 2.6

---

# Disposing

release all allocated resources:

```swift
let disposeBag = DisposeBag()
Observable.of(1, 2 ,3)
    .subscribe { event in
        print(event)
    }.addDisposableTo(disposeBag)
```

---

# Operators [^3]

*   Creating Observables
*   Transforming Observables
*   Filtering Observables
*   Combining Observables

[^3]: <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/API.md>

---

## Rx Marbles

<http://rxmarbles.com/>

<https://github.com/RxSwiftCommunity/RxMarbles>

---

# Sequence Generation

When does an Observable begin emitting its items?[^4]

"Cold" Observable:<br>waits until an observer subscribes

"Hot" Observable:<br>may begin emitting items as soon as created

[^4]: See also [Hot and Cold Observables](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)

---

# Cold Observables

```swift
let disposeBag = DisposeBag()
let observable = Observable.of(1, 2)
observable
    .subscribe { print($0) }
    .addDisposableTo(disposeBag)
observable
    .subscribe { print($0)}
    .addDisposableTo(disposeBag)
```

will print

```
Next(1)
Next(2)
Completed
Next(1)
Next(2)
Completed
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
sub1: Next(2)
sub1: Next(3)
sub2: Next(3)
sub1: Completed
```

---

# Create Observables

```swift
func pulse(interval: NSTimeInterval) -> Observable<Int> {
    return Observable.create { observer in
        print("Subscribed")

        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, 0, UInt64(interval * Double(NSEC_PER_SEC)), 0)

        var next = 0
        let cancel = AnonymousDisposable {
            print("Disposed")
            dispatch_source_cancel(timer)
        }
        dispatch_source_set_event_handler(timer, {
            if cancel.disposed { return }
            observer.onNext(next)
            next += 1
        })
        dispatch_resume(timer)
        return cancel
    }
}
```

---

# Create Observables

```swift
let subscription = pulse(0.5)
    .subscribeNext { print($0) }
NSThread.sleepForTimeInterval(2.0)
subscription.dispose()
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
 let counter = pulse(0.1)
 let sub1 = counter.subscribeNext { print("Sub1:  \($0)") }
 let sub2 = counter.subscribeNext { print("Sub2:  \($0)") }

 NSThread.sleepForTimeInterval(0.3)
 sub1.dispose()

 NSThread.sleepForTimeInterval(0.3)
 sub2.dispose()
```

will print ...

---

# Cold Observables - again

```
Subscribed
Sub1:  0
Subscribed
Sub2:  0
Sub1:  1
Sub2:  1
Sub1:  2
Sub2:  2
Disposed
Sub2:  3
Sub2:  4
Sub2:  5
Disposed
```

---

# Share Replay

```swift
 let counter = pulse(0.1).shareReplay(1)
 let sub1 = counter.subscribeNext { print("Sub1:  \($0)") }
 let sub2 = counter.subscribeNext { print("Sub2:  \($0)") }

 NSThread.sleepForTimeInterval(0.3)
 sub1.dispose()

 NSThread.sleepForTimeInterval(0.3)
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
Sub2:  6
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

# Observe on Scheduler

```swift
sequence
    .observeOn(backgroundScheduler)
    .map { n in
        print("This is performed on backgroundScheduler")
    }
    .observeOn(MainScheduler.instance)
    .map { n in
        print("This is performed on the main thread")
    }
```

---

# Examples

See [Rx.playground](https://github.com/ReactiveX/RxSwift/tree/master/Rx.playground)

---

# Testing

TBD

---

# Debugging

```swift
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
    .debug("debugging ...")
    .map { "Simply \($0)"}
    .subscribeNext { print($0) }
NSThread.sleepForTimeInterval(1.0)
subscription.dispose()
```

will print

```
2016-09-09 16:42:29.871: debugging ... -> subscribed
2016-09-09 16:42:30.172: debugging ... -> Event Next(0)
Simply 0
2016-09-09 16:42:30.475: debugging ... -> Event Next(1)
Simply 1
2016-09-09 16:42:30.775: debugging ... -> Event Next(2)
Simply 2
2016-09-09 16:42:30.873: debugging ... -> disposed
```

---

# RxCocoa

---

# Units

**Important properties when writing Cocoa/UIKit applications:**

*   Subscribe on main scheduler (properties, events)
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
let results = query.rx_text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { fetchItems($0) }

results.map { "\($0.count)" }
    .bindTo(resultCount.rx_text)
    .addDisposableTo(disposeBag)

results.bindTo(tableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
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

# Driver

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

# Examples

See [RxExample](https://github.com/ReactiveX/RxSwift/tree/master/RxExample)

---

# What's new in RxSwift 3.0?

See [the changelog](https://github.com/ReactiveX/RxSwift/blob/master/CHANGELOG.md).

---

# By the way ...

Observable Sequences are Monads[^7]

[^7]: [Swift Functors, Applicatives, and Monads in Pictures](http://www.mokacoding.com/blog/functor-applicative-monads-in-pictures/)

---

# Thank you![^8]

[^8]: Slidedeck Sources on [GitHub](https://github.com/stefanscheidt/RxSwiftPresentation)