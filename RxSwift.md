# RxSwift

# RxCocoa

---

## Asynchronous Programming<br>with Observable Streams<br>for Cocoa

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

^ The main contributor works for Rhapsody Napster.

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

# Sequence generation

When an observable is created, it doesn't perform any work simply because it has been created

**Sequence generation starts when the subscribe method is called**

**Every subscriber upon subscription usually generates it's own separate sequence of elements**

But see also [Hot and Cold Observables](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)

---

# Events

`next* (error | completed)?`

*   Sequences can have 0 or more elements
*   Once an error or completed event is received, the sequence cannot produce any other element

---

# Disposing

TBD

see <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#disposing>

---

# Examples (RxSwift 2.6.0)

```swift
let disposeBag = DisposeBag()
Observable.just(42)
    .subscribe { event in
        print(event)
    }.addDisposableTo(disposeBag)
```

will output

```
Next(42)
Completed
```

---

# Operators [^1]

*   Creating Observables
*   Transforming Observables
*   Filtering Observables
*   Combining Observables

[^1]: <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/API.md>

---

# More Examples

---

# Schedulers

TBD

see <https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md>

---

# Testing

TBD

---

# Debugging

TBD

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