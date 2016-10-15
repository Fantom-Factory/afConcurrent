#Concurrent v1.0.16
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.0.16](http://img.shields.io/badge/pod-v1.0.16-yellow.svg)](http://www.fantomfactory.org/pods/afConcurrent)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

Concurrent builds upon the Fantom's core [concurrent library](http://fantom.org/doc/concurrent/index.html) and provides a collection of utility classes for sharing data in and between threads.

## Install

Install `Concurrent` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://pods.fantomfactory.org/fanr/ afConcurrent

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afConcurrent 1.0"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afConcurrent/).

## Usage

The `Concurrent` library provides strategies for sharing data between threads:

### Synchronized

The [Synchronized](http://pods.fantomfactory.org/pods/afConcurrent/api/Synchronized) class provides synchronized serial access to a block of code, akin to Java's `synchronized` keyword. It can be used as a mechanism for exclusive locking. For example:

```
class Example {
    Synchronized lock := Synchronized(ActorPool())

    Void main() {
        lock.synchronized |->| {
            // ...
            // put important thread safe code here
            // ...
        }
    }
}
```

`Synchronized` works by calling the thread safe function from within the `receive()` method of an [Actor](http://fantom.org/doc/concurrent/Actor.html), which has some important implications:

1. The passed in function needs to be an [immutable func](http://fantom.org/doc/sys/Func.html).
2. Any object returned also has to be immutable.

Alien-Factory's Concurrent library uses this *synchronized* construct to supply the following useful classes:

- [SynchronizedState](http://pods.fantomfactory.org/pods/afConcurrent/api/SynchronizedState)
- [SynchronizedList](http://pods.fantomfactory.org/pods/afConcurrent/api/SynchronizedList)
- [SynchronizedMap](http://pods.fantomfactory.org/pods/afConcurrent/api/SynchronizedMap)
- [SynchronizedFileMap](http://pods.fantomfactory.org/pods/afConcurrent/api/SynchronizedFileMap)

See the individual class documentation for more details.

### Atomic

Atomic Lists and Maps are similar to their Synchronized counterparts in that they are backed by an object held in an `AtomicRef`. But their write operations are *not* synchronized. This means they are much more *lightweight* but it also means they are susceptible to **data-loss** during race conditions between multiple threads. If used for caching situations where it is not essential for values to exist, this may be acceptable.

See:

- [AtomicList](http://pods.fantomfactory.org/pods/afConcurrent/api/AtomicList)
- [AtomicMap](http://pods.fantomfactory.org/pods/afConcurrent/api/AtomicMap)

The atomic classes are also available in Javascript.

### Local

Local Refs, Lists and Maps do not share data between threads, in fact, quite the opposite!

They wrap data stored in `Actor.locals()` thereby constraining it to only be accessed by the executing thread. The data is said to be *local* to that thread.

The problem is that data held in `Actor.locals()` is susceptible to being overwritten due to name clashes. Consider:

```
class Drink {
    Str beer {
      get { Actor.locals["beer"] }
      set { Actor.locals["beer"] = it }
    }
}

man := Drink()
man.beer = "Ale"

kid := Drink()
kid.beer = "Ginger Ale"

echo(man.beer)  // --> Ginger Ale (WRONG!)
echo(kid.beer)  // --> Ginger Ale
```

To prevent this, [LocalRef](http://pods.fantomfactory.org/pods/afConcurrent/api/LocalRef) creates a unique qualified name to store the data under:

```
class Drink {
    LocalRef beer := LocalRef("beer")
}

man := Drink()
man.beer.val = "Ale"

kid := Drink()
kid.beer.val = "Ginger Ale"

echo(man.beer.val)   // --> Ale
echo(kid.beer.val)   // --> Ginger Ale

echo(man.beer.qname) // --> 0001.beer
echo(kid.beer.qname) // --> 0002.beer
```

While `LocalRefs` are not too exciting on their own, [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) and [IoC](http://pods.fantomfactory.org/pods/afIoc) use them to keep track of data to be cleaned up at the end of HTTP web requests.

See:

- [LocalRef](http://pods.fantomfactory.org/pods/afConcurrent/api/LocalRef)
- [LocalList](http://pods.fantomfactory.org/pods/afConcurrent/api/LocalList)
- [LocalMap](http://pods.fantomfactory.org/pods/afConcurrent/api/LocalMap)

`LocalRef` is also available in Javascript (as from Fantom 1.0.68) but `LocalList` and `LocalMap` are blocked on [js: Func.toImmutable not implemented](http://fantom.org/forum/topic/1144#c4).

## IoC

When Concurrent is added as a dependency to an IoC enabled application, such as [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) or [Reflux](http://pods.fantomfactory.org/pods/afReflux), then the following services are automatically made available to IoC:

- [ActorPools](http://pods.fantomfactory.org/pods/afConcurrent/api/ActorPools) - takes contributions of `Str:ActorPool`
- [LocalRefManager](http://pods.fantomfactory.org/pods/afConcurrent/api/LocalRefManager)

A `DependencyProvider` allows you to inject instances of `LocalRefs`, `LocalLists`, and `LocalMaps`. See [LocalRefManager](http://pods.fantomfactory.org/pods/afConcurrent/api/LocalRefManager) for details.

A `SynchronizedProvider` also allows you to inject instances of `Synchronized` with a named `ActorPool`.

The above makes use of the non-invasive module feature of IoC 3.

