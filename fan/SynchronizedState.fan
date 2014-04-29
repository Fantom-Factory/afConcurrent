using concurrent::Actor
using concurrent::ActorPool
using concurrent::AtomicInt
using concurrent::Future

** Provides 'synchronized' access to a (non- 'const') mutable object.
** 
** In Java terms, the 'getState() { ... }' method behaves in a similar fashion to the 
** 'synchronized' keyword, only allowing one thread through at a time.
** 
** 'SynchronizedState' wraps a state object in an Actor, and provides access to it via the 
** 'withState' and 'getState' methods. Note that by their nature, these methods are immutable 
** boundaries. Meaning that while data in the State object can be mutable, data passed to 
** and from these methods can not be. 
** 
** 'SynchronizedState' has been designed to be *type safe*, that is you cannot accidently call 
** methods on your State object. The compiler forces all access to the state object to be made 
** through the 'withState()' and 'getState()' methods.
** 
** A fully usable example of a mutable const map class is as follows:
** 
** pre>
** const class ConstMap {
**   const ConcurrentState  conState  := ConcurrentState(ConstMapState#)
**   
**   ** Note that both 'key' and 'value' need to be immutable
**   @Operator
**   Obj get(Obj key) {
**     getState |ConstMapState state -> Obj?| {
**       return state.map[key]
**     }
**   }
** 
**   ** Note that both 'key' and 'value' need to be immutable
**   @Operator
**   Void set(Obj key, Obj value) {
**     withState |ConstMapState state| {
**       state.map[key] = value
**     }
**   }
** }
** 
** class ConstMapState {
**   Obj:Obj  map := [:]
** }
** <pre
** 
const class SynchronizedState {
	private static const Log 	log 	:= Utils.getLog(SynchronizedState#)
	
	private const Actor 		stateActor
	private const |->Obj?| 		stateFactory
	private const LocalRef 		stateRef
	
	** The given state type must have a public no-args ctor as per `sys::Type.make`
	new makeWithStateType(ActorPool actorPool, Type stateType) {
		this.stateRef		= LocalRef(stateType.name)
		this.stateFactory	= |->Obj?| { stateType.make }		
		this.stateActor		= Actor(actorPool, |Obj? obj -> Obj?| { receive(obj) })
	}

	new makeWithStateFactory(ActorPool actorPool, |->Obj?| stateFactory) {
		this.stateRef		= LocalRef(SynchronizedState#.name)
		this.stateFactory	= stateFactory
		this.stateActor		= Actor(actorPool, |Obj? obj -> Obj?| { receive(obj) })
	}

	** Use to access state, effectively wrapping the given func in a Java 'synchronized { ... }' 
	** block. Call 'get()' on the returned 'Future' to ensure any Errs are rethrown. 
	virtual Future withState(|Obj?->Obj?| f) {
		// explicit call to .toImmutable() - see http://fantom.org/sidewalk/topic/1798#c12190
		func	:= f.toImmutable
		future 	:= stateActor.send([true, func].toImmutable)
		return future
	}

	** Use to return state, effectively wrapping the given func in a Java 'synchronized { ... }' 
	** block. 
	virtual Obj? getState(|Obj?->Obj?| f) {
		// explicit call to .toImmutable() - see http://fantom.org/sidewalk/topic/1798#c12190
		func	:= f.toImmutable
		future := stateActor.send([false, func].toImmutable)
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
		func 	:= msg[1] as |Obj->Obj?|

		try {
			if (stateRef.val == null) 
				stateRef.val = stateFactory.call
			
			// lazily create our state
			return func.call(stateRef.val)

		} catch (Err e) {
			// if the func has a return type, then an the Err is rethrown on assignment
			// else we log the Err so the Thread doesn't fail silently
			if (logErr || func.returns == Void#)
				log.err("receive()", e)
			throw e
		}
	}	
}

