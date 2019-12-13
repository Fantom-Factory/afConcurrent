# Concurrent v1.0.26
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v1.0.26](http://img.shields.io/badge/pod-v1.0.26-yellow.svg)](http://eggbox.fantomfactory.org/pods/afConcurrent)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## <a name="overview"></a>Overview

Concurrent builds upon the Fantom's core [concurrent library](https://fantom.org/doc/concurrent/index.html) and provides a collection of utility classes for sharing data in and between threads.

## <a name="Install"></a>Install

Install `Concurrent` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afConcurrent

Or install `Concurrent` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afConcurrent

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afConcurrent 1.0"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afConcurrent/) - the Fantom Pod Repository.

## Usage

The `Concurrent` library provides strategies for sharing data between threads:

### Synchronized

The [Synchronized](http://eggbox.fantomfactory.org/pods/afConcurrent/api/Synchronized) class provides synchronized serial access to a block of code, akin to Java's `synchronized` keyword. It can be used as a mechanism for exclusive locking. For example:

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
    

`Synchronized` works by calling the thread safe function from within the `receive()` method of an [Actor](https://fantom.org/doc/concurrent/Actor.html), which has some important implications:

1. The passed in function needs to be an [immutable func](https://fantom.org/doc/sys/Func.html).
2. Any object returned also has to be immutable.


Alien-Factory's Concurrent library uses this *synchronized* construct to supply the following useful classes:

* [SynchronizedState](http://eggbox.fantomfactory.org/pods/afConcurrent/api/SynchronizedState)
* [SynchronizedList](http://eggbox.fantomfactory.org/pods/afConcurrent/api/SynchronizedList)
* [SynchronizedMap](http://eggbox.fantomfactory.org/pods/afConcurrent/api/SynchronizedMap)
* [SynchronizedFileMap](http://eggbox.fantomfactory.org/pods/afConcurrent/api/SynchronizedFileMap)
* [SynchronizedBuf](http://eggbox.fantomfactory.org/pods/afConcurrent/api/SynchronizedBuf)


All *Synchronized* classes are `const`, mutable, and may be shared between threads.

See the individual class documentation for more details.

### Atomic

Atomic Lists and Maps are backed by an object held in an `AtomicRef`. They do not perform any processing in a separate thread, hence are more *lightweight* than their synchronized counterparts.

But write operations make a copy the backing object before appling changes, and are *not* synchronized. This means they are susceptible to **data-loss** during race conditions between multiple threads. If used for caching situations where values may be calcuated on the fly, then this may be acceptable.

See:

* [AtomicList](http://eggbox.fantomfactory.org/pods/afConcurrent/api/AtomicList)
* [AtomicMap](http://eggbox.fantomfactory.org/pods/afConcurrent/api/AtomicMap)


The atomic classes are also available in Javascript.

### Local

Local Refs, Lists and Maps do not share data between threads, in fact, quite the opposite!

They wrap data stored in `Actor.locals()` thereby constraining it to only be accessed by the executing thread. The data is said to be *local* to that thread.

The problem is that data held in `Actor.locals()` is susceptible to being overwritten due to name clashes. Consider:

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
    

To prevent this, [LocalRef](http://eggbox.fantomfactory.org/pods/afConcurrent/api/LocalRef) creates a unique qualified name to store the data under:

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
    

While `LocalRefs` are not too exciting on their own, [BedSheet](http://eggbox.fantomfactory.org/pods/afBedSheet) and [IoC](http://eggbox.fantomfactory.org/pods/afIoc) use them to keep track of data to be cleaned up at the end of HTTP web requests.

See:

* [LocalRef](http://eggbox.fantomfactory.org/pods/afConcurrent/api/LocalRef)
* [LocalList](http://eggbox.fantomfactory.org/pods/afConcurrent/api/LocalList)
* [LocalMap](http://eggbox.fantomfactory.org/pods/afConcurrent/api/LocalMap)


`LocalRef` is also available in Javascript (as from Fantom 1.0.68) but `LocalList` and `LocalMap` are blocked on [js: Func.toImmutable not implemented](http://fantom.org/forum/topic/1144#c4).

## IoC

When Concurrent is added as a dependency to an IoC enabled application, such as [BedSheet](http://eggbox.fantomfactory.org/pods/afBedSheet) or [Reflux](http://eggbox.fantomfactory.org/pods/afReflux), then the following services are automatically made available to IoC:

* [ActorPools](http://eggbox.fantomfactory.org/pods/afConcurrent/api/ActorPools) - takes contributions of `Str:ActorPool`
* [LocalRefManager](http://eggbox.fantomfactory.org/pods/afConcurrent/api/LocalRefManager)


A `DependencyProvider` then allows you to inject instances of:

* `LocalRefs`
* `LocalLists`
* `LocalMaps`


    @Inject { type=[Str:Slot?]# }
    const LocalMap localMap
    

Another provider allows you to name an `ActorPool` and inject instances of:

* `ActorPool`
* `Synchronized`
* `SynchronizedList`
* `SynchronizedMap`
* `SynchronizedState`


    @Inject { id="<actorPool.id>" type=[Str:Slot?]# }
    const SynchronizedMap syncMap
    

All the above makes use of the non-invasive module feature of IoC 3.

