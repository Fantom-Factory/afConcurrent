#Concurrent v1.0.8
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.0.8](http://img.shields.io/badge/pod-v1.0.8-yellow.svg)](http://www.fantomfactory.org/pods/afConcurrent)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`Concurrent` builds upon the standard Fantom [concurrent library](http://fantom.org/doc/concurrent/index.html) and provides a collection of utility classes for sharing data between threads.

## Install

Install `Concurrent` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afConcurrent

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afConcurrent 1.0+"]

## Documentation

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afConcurrent/#overview).

## Usage

The `Concurrent` library provides a few strategies for sharing data:

### Synchronized

[Synchronized](http://repo.status302.com/doc/afConcurrent/Synchronized.html) provides synchronized serial access to a block of code, akin to Java's `synchronized` keyword. Extend the `Synchronized` class to use the familiar syntax:

```
const class Example : Synchronized {
    new make() : super(ActorPool()) { }

    Void main() {
        synchronized |->| {
            // ...
            // important stuff
            // ...
        }
    }
}
```

`Synchronized` works by calling the function from within the `receive()` method of an [Actor](http://fantom.org/doc/concurrent/Actor.html), which has important implications. First, the passed in function needs to be an [immutable func](http://fantom.org/doc/sys/Func.html). Next, any object returned also has to be immutable (preferably) or serializable.

Instances of `Synchronized` may also be used as a mechanism for exclusive locking. For example:

```
class Example {
    Synchronized lock := Synchronized(ActorPool())

    Void main() {
        lock.synchronized |->| {
            // ...
            // important stuff
            // ...
        }
    }
}
```

### Atomic

Atomic Lists and Maps are similar to their Synchronized counterparts in that they are backed by an object held in an `AtomicRef`. But their write operations are *not* synchronized. This means they are much more *lightweight* but it also means they are susceptible to **data-loss** during race conditions between multiple threads. If used for caching situations where it is not essential for values to exist, this may be acceptable.

### Local

Local Refs, Lists and Maps do not share data between threads, in fact, quite the opposite!

They wrap data stored in `Actor.locals()` thereby constraining it to only be accessed by the executing thread. The data is said to be *local* to that thread.

But data held in `Actor.locals()` is susceptible to being overwritten due to name clashes. Consider:

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

To prevent this, [LocalRef](http://repo.status302.com/doc/afConcurrent/LocalRef.html) creates a unique qualified name to store the data under:

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

While `LocalRefs` are not too exciting on their own, [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) and [IoC](http://www.fantomfactory.org/pods/afIoc) use them to keep track of data to be cleaned up at the end of HTTP web requests.

