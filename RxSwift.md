autoscale: true

# RxSwift

# RxCocoa

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

# Basic Concepts (RxSwift)

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

# Examples (RxSwift 2.6.0)

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

# Operators [^1]

*   Creating Observables
*   Transforming Observables
*   Filtering Observables
*   Combining Observables

[^1]: <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/API.md>

---

## Rx Marbles

<http://rxmarbles.com/>

<https://github.com/RxSwiftCommunity/RxMarbles>

---

# More Examples

---

# Sequence generation

When does an Observable begin emitting its items?<br>It depends ...

"Hot" Observable:<br>may begin emitting items as soon as created

"Cold" Observabls:<br>waits until an observer subscribes before it begins to emit

See also [Hot and Cold Observables](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)

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
let pub = PublishSubject<String>()
pub.onNext("one")
let sub1 = pub.subscribe { print("1: \($0)") }
pub.onNext("two")
let sub2 = pub.subscribe { print("2: \($0)") }
pub.onNext("three")
sub2.dispose()
pub.onCompleted()
```

will print

```
1: Next(two)
1: Next(three)
2: Next(three)
1: Completed
```

---

# Schedulers

TBD

see <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md>

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

TBD

---

# Units

Examples

---

# By the way ...

Observable Sequences are Monads