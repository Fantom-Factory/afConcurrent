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
** const class SyncMap {
**   const SynchronizedState  conState  := SynchronizedState(MapState#)
**   
**   ** Note that both 'key' and 'value' need to be immutable
**   @Operator
**   Obj get(Obj key) {
**     getState |MapState state -> Obj?| {
**       return state.map[key]
**     }
**   }
** 
**   ** Note that both 'key' and 'value' need to be immutable
**   @Operator
**   Void set(Obj key, Obj value) {
**     withState |MapState state| {
**       state.map[key] = value
**     }
**   }
** }
** 
** class MapState {
**   Obj:Obj  map := [:]
** }
** <pre
** 
const class SynchronizedState {
	private const Synchronized	stateLock
	private const |->Obj?| 		stateFactory
	private const LocalRef 		stateRef
	
	** The given state type must have a public no-args ctor as per [Type.make]`http://fantom.org/doc/sys/Type.html#make`.
	new makeWithStateType(ActorPool actorPool, Type stateType) {
		this.stateLock		= Synchronized(actorPool) 
		this.stateRef		= LocalRef(stateType.name)
		this.stateFactory	= |->Obj?| { stateType.make }		
	}

	new makeWithStateFactory(ActorPool actorPool, |->Obj?| stateFactory) {
		this.stateLock		= Synchronized(actorPool) 
		this.stateRef		= LocalRef(SynchronizedState#.name)
		this.stateFactory	= stateFactory
	}

	** Use to access state, effectively wrapping the given func in a Java 'synchronized { ... }' 
	** block. Call 'get()' on the returned 'Future' to ensure any Errs are rethrown. 
	virtual Future withState(|Obj?->Obj?| func) {
		iFunc := func.toImmutable
		return stateLock.async |->Obj?| { callFunc(iFunc) }
	}

	** Use to return state, effectively wrapping the given func in a Java 'synchronized { ... }' 
	** block. 
	virtual Obj? getState(|Obj?->Obj?| func) {
		iFunc := func.toImmutable
		return stateLock.synchronized |->Obj?| { callFunc(iFunc) }
	}
	
	private Obj? callFunc(|Obj?->Obj?| func) {
		if (stateRef.val == null) 
			stateRef.val = stateFactory.call		
		return func.call(stateRef.val)		
	}
}

