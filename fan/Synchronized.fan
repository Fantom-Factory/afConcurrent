using concurrent

** Provides 'synchronized' access to blocks of code. Example usage:
** 
** pre>
** const class Example : Synchronized {
** 
**   new make(ActorPool actorPool) : super(actorPool) { }
** 
**   Void main() {
** 
**     val := synchronized |->Obj?| {
**       // ...
**       // important stuff
**       // ...
**       return 69
**     }
**   }
** }
** <pre
const class Synchronized {
	private static const Log	log 	:= Utils.getLog(Synchronized#)
	
	private const Actor 		actor
	private const LocalRef		insync	:= LocalRef("synchronized")

	** Create a 'Synchronized' class that uses the given 'ActorPool'.
	new make(ActorPool actorPool) {
		this.actor	= Actor(actorPool, |Obj? obj -> Obj?| { receive(obj) })
	}

	** This effectively wraps the given func in a Java 'synchronized { ... }' block that gets executed in it's own good time!
	** Err's that occur within the block are logged but not rethrown unless you call 'get()' on 
	** the returned 'Future'. 
	virtual Future syncAndForget(|->Obj?| f) {
		// explicit call to .toImmutable() - see http://fantom.org/sidewalk/topic/1798#c12190
		func	:= f.toImmutable
		future 	:= actor.send([true, func].toImmutable)
		try {
			return future.get
		} catch (NotImmutableErr err) {
			throw NotImmutableErr("Return value not immutable", err)
		}
	}

	** This effectively wraps the given func in a Java 'synchronized { ... }' block and returns a
	** value. 
	virtual Obj? synchronized(|->Obj?| f) {
		if (insync.val == true)
			throw Err(ErrMsgs.synchronized_nestedCallsNotAllowed)

		// explicit call to .toImmutable() - see http://fantom.org/sidewalk/topic/1798#c12190
		func	:= f.toImmutable
		future := actor.send([false, func].toImmutable)
		return get(future)
	}

	private Obj? get(Future future) {
		try {
			return future.get
		} catch (NotImmutableErr err) {
			throw NotImmutableErr("Return value not immutable", err)
		}
	}

	private Obj? receive(Obj[] msg) {
		logErr	:= msg[0] as Bool
		func 	:= msg[1] as |->Obj?|

		insync.val = true
		try {
			return func.call()

		} catch (Err e) {
			// if the func has a return type, then an the Err is rethrown on assignment
			// else we log the Err so the Thread doesn't fail silently
			if (logErr)
				log.err("receive()", e)
			throw e

		} finally {
			insync.cleanUp
		}
	}	
}
