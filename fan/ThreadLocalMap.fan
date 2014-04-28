
//ThreadLocalMap
//LocalMap
//
//LocalList
//LocalBool
//LocalObj
//LocalRef

** Manages a Map stored in 'Actor.locals' under a unique key.
class ThreadLocalMap {
	private const ThreadLocalRef	threadLocal
	
	** The qualified name this 'ThreadLocal' is stored under in 'Actor.locals'. 
	** 'qname' is calculated from 'name'.
	const Str qname
	
	** The variable name given to the ctor.
	const Str name

	new make(Str name) {
		this.threadLocal = ThreadLocalRef(name) |->Obj?| { [:] }
		this.qname	= threadLocal.qname
		this.name	= threadLocal.name
	}

	** Use when you need a case insensitive map.
	new makeWithMap(Str name, [Obj:Obj?] map) {
		this.threadLocal = ThreadLocalRef(name) |->Obj?| { map }
		this.qname	= threadLocal.qname
		this.name	= threadLocal.name
	}
	
	** Removes this object from 'Actor.locals'.
	Void purge() {
		threadLocal.purge
	}
	
	** Gets or sets the thread local map
	[Obj:Obj?] map {
		get { threadLocal.val }
		set { threadLocal.val = it.toImmutable }
	}
	
	** Returns the value associated with the given key. 
	** If it doesn't exist then it is added from the value function. 
	** 
	** This method is thread safe. 'valFunc' will not be called twice for the same key.
	Obj? getOrAdd(Obj key, |Obj key->Obj?| valFunc) {
		map.getOrAdd(key, valFunc)
	}

	** Sets the key / value pair, ensuring no data is lost during multi-threaded race conditions.
	** Though the same key may be overridden. Both the 'key' and 'val' must be immutable. 
	@Operator
	Void set(Obj key, Obj? val) {
		map[key] = val
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		map.clear
		return this
	}

	** Remove the key/value pair identified by the specified key
	** from the map and return the value. 
	** If the key was not mapped then return 'null'.
	Obj? remove(Obj key) {
		map.remove(key)
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