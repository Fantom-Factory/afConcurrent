using concurrent::ActorPool
using concurrent::AtomicRef
using concurrent::Future

** A Map that provides fast reads and 'synchronised' writes between threads, ensuring data integrity.
** Use when *reads* far out number the *writes*.
** 
** The map is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** 
** All write operations ( 'getOrAdd', 'set', 'remove' & 'clear' ) are made via 'synchronized' blocks 
** ensuring no data is lost during race conditions. 
** Writing makes a 'rw' copy of the map and is thus a more expensive operation.
** 
** Note that all objects held in the map have to be immutable.
const class SynchronizedMap {
	private const AtomicRef 	atomicMap := AtomicRef()
	private const Synchronized	lock
	
	new make(ActorPool actorPool) {
		this.map = [:]
		this.lock	= Synchronized(actorPool)
	}

	** Make a 'SynchronizedMap' using the given immutable map. 
	** Use when you need a case insensitive map.
	new makeWithMap(ActorPool actorPool, [Obj:Obj?] map) {
		this.map = map
		this.lock	= Synchronized(actorPool)
	}
	
	** Gets or sets a read-only copy of the backing map.
	[Obj:Obj?] map {
		get { atomicMap.val }
		set { atomicMap.val = it.toImmutable }
	}
	
	** Returns the value associated with the given key. 
	** If it doesn't exist then it is added from the value function. 
	** 
	** This method is thread safe. 'valFunc' will not be called twice for the same key.
	Obj? getOrAdd(Obj key, |Obj key->Obj?| valFunc) {
		if (containsKey(key))
			return get(key)
		
		iKey := key.toImmutable
		return lock.synchronized |->Obj?| {
			// double lock
			if (containsKey(iKey))
				return get(iKey)

			val := valFunc.call(key)
			iVal := val.toImmutable
			newMap := map.rw
			newMap.set(iKey, iVal)
			map = newMap
			return val
		}
	}

	** Sets the key / value pair, ensuring no data is lost during multi-threaded race conditions.
	** Though the same key may be overridden. Both the 'key' and 'val' must be immutable. 
	@Operator
	Void set(Obj key, Obj? val) {
		iKey := key.toImmutable
		iVal := val.toImmutable
		lock.synchronized |->| {
			newMap := map.rw
			newMap.set(iKey, iVal)
			map = newMap
		}
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		lock.synchronized |->| {
			map = map.rw.clear
		}
		return this
	}

	** Remove the key/value pair identified by the specified key
	** from the map and return the value. 
	** If the key was not mapped then return 'null'.
	Obj? remove(Obj key) {
		iKey := key.toImmutable
		return lock.synchronized |->Obj?| {
			newMap := map.rw
			val := newMap.remove(iKey)
			map = newMap
			return val 
		}
	}
	
	// ---- Common Map Methods --------------------------------------------------------------------
	
	** Returns the value associated with the given key. 
	** If 'key' is not mapped, then return 'def'.  
	@Operator
	Obj? get(Obj key, Obj? def := null) {
		map.get(key, def)
	}

	** Returns 'true' if the cache contains the given key
	Bool containsKey(Obj key) {
		map.containsKey(key)
	}
	
	** Returns a list of all the mapped keys.
	Obj[] keys() {
		map.keys
	}

	** Returns a list of all the mapped values.
	Obj?[] vals() {
		map.vals
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		map.isEmpty
	}

	** Get the number of key/value pairs in the map.
	Int size() {
		map.size
	}
}
