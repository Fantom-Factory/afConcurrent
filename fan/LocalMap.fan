
** Manages a Map stored in 'Actor.locals' with a unique key.
** 
** 'LocalMaps' are lazy, that is, no Map is created or stored in 'Actor.locals' until you try to access it.
const class LocalMap {
	
	** The 'LocalRef' this 'LocalMap' wraps. 
	const LocalRef	localRef

	** The default value to use for `get` when a key isn't mapped.
	const Obj? def				:= null
	
	** Configures case sensitivity for maps with Str keys.
	const Bool caseInsensitive	:= false

	** If 'true' the map will maintain the order in which key/value pairs are added.
	const Bool ordered			:= false
	
	** Makes a 'LocalMap' instance.
	new make(Str name, |This|? f := null) {
		f?.call(this)
		this.localRef = LocalRef(name)
	}
	
	** Gets or sets the thread local map
	[Obj:Obj?] map {
		get { 
			if (localRef.val == null)
				localRef.val
					= caseInsensitive
					? [Str:Obj?][:] { it.def = this.def; it.caseInsensitive = true }
					: [Obj:Obj?][:] { it.def = this.def; it.ordered = this.ordered }
			return localRef.val 
		}
		set { localRef.val = it }
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

	** Returns 'true' if the cache contains the given key
	Bool containsKey(Obj key) {
		map.containsKey(key)
	}
	
	** Returns the value associated with the given key. 
	** If key is not mapped, then return the value of the 'def' parameter.  
	** If 'def' is omitted it defaults to 'null'.
	@Operator
	Obj? get(Obj key, Obj? def := this.def) {
		map.get(key, def)
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		map.isEmpty
	}

	** Returns a list of all the mapped keys.
	Obj[] keys() {
		map.keys
	}

	** Get a read-write, mutable Map instance with the same contents.
	[Obj:Obj?] rw() {
		map.rw
	}

	** Get the number of key/value pairs in the map.
	Int size() {
		map.size
	}

	** Returns a list of all the mapped values.
	Obj?[] vals() {
		map.vals
	}
}
