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

	** The default timeout to use when waiting for 'synchronized' blocks to complete.
	const Duration? timeout
	
	** Create a 'Synchronized' class that uses the given 'ActorPool' and timeout.
	new make(ActorPool actorPool, Duration? timeout := null) {
		this.actor	 = Actor(actorPool, |Obj? obj -> Obj?| { receive(obj) })
		this.timeout = timeout
	}

	** Runs the given func asynchronously, using this Synchronized's 'ActorPool'.
	** 
	** Errs that occur within the block are logged but not rethrown unless you call 'get()' on 
	** the returned 'Future'. 
	** 
	** The given func must be immutable.
	Future async(|->Obj?| f) {
		// explicit call to .toImmutable() - see http://fantom.org/sidewalk/topic/1798#c12190
		func	:= f.toImmutable
		future 	:= actor.send([true, func].toImmutable)
		return future	// sounds cool, huh!?
	}

	** This effectively wraps the given func in a Java 'synchronized { ... }' block and returns its
	** calculated value. 
	** 
	** The given func must be immutable.
	Obj? synchronized(|->Obj?| f) {
		if (insync.val == true)
			throw Err(ErrMsgs.synchronized_nestedCallsNotAllowed)

		// explicit call to .toImmutable() - see http://fantom.org/sidewalk/topic/1798#c12190
		func	:= f.toImmutable
		future	:= actor.send([false, func].toImmutable)

		try {
			return future.get(timeout)
		} catch (IOErr err) {
			throw IOErr(ErrMsgs.synchronized_notImmutable(f.returns), err)
		}
	}

	private Obj? receive(Obj[] msg) {
		logErr	:= msg[0] as Bool
		func 	:= msg[1] as |->Obj?|

		insync.val = true
		try {
			return func.call()

		} catch (Err e) {
			// log the Err so the thread doesn't fail silently
			if (logErr)
				log.err(ErrMsgs.synchronized_silentErr, e)
			throw e

		} finally {
			insync.cleanUp
		}
	}	
}
