using concurrent::AtomicRef

** A Map that provides fast reads and lightweight writes between threads.
** Use when *reads* far out number the *writes*.
**
** The map is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** Writing makes a 'rw' copy of the map and is thus a more expensive operation.
** 
** > **CAUTION:** 
** Write operations ( 'getOrAdd', 'set', 'remove' & 'clear' ) are not synchronised. 
** This makes them lightweight but also susceptible to **data-loss** during race conditions.
** This may be acceptable for *caching* situations where values is easily re-calculated.
** 
** Note that all objects held in the map must be immutable.
** 
** See [The Good, The Bad and The Ugly of Const Services]`http://www.fantomfactory.org/articles/good-bad-and-ugly-of-const-services#theUgly` for more details.
const class AtomicMap {
	private const AtomicRef atomicMap := AtomicRef()

	** The default value to use for `get` when a key isn't mapped.
	const Obj? def				:= null
	
	** Configures case sensitivity for maps with Str keys.
	const Bool caseInsensitive	:= false

	** If 'true' the map will maintain the order in which key/value pairs are added.
	const Bool ordered			:= false
	
	@NoDoc	// pointless ctor!
	new make(|This|? f := null) { f?.call(this) }
	
	** Gets or sets a read-only copy of the backing map.
	[Obj:Obj?] map {
		get { 
			if (atomicMap.val == null)
				atomicMap.val
					= caseInsensitive
					? [Str:Obj?][:] { it.def = this.def; it.caseInsensitive = true }.toImmutable
					: [Obj:Obj?][:] { it.def = this.def; it.ordered = this.ordered }.toImmutable
			return atomicMap.val 
		}
		set { atomicMap.val = it.toImmutable }
	}
	
	** Returns the value associated with the given key. If it doesn't exist then it is added from 
	** the value function. 
	** 
	** This method is **NOT** thread safe. If two Actors call this method at the same time, the 
	** value function will be called twice for the same key.
	Obj? getOrAdd(Obj key, |Obj key->Obj?| valFunc) {
		if (!containsKey(key)) {
			val := valFunc.call(key)
			set(key, val)
		}
		return get(key)
	}

	** Sets the key / value pair.
	@Operator
	Void set(Obj key, Obj? val) {
		iKey  := key.toImmutable
		iVal  := val.toImmutable
		rwMap := map.rw
		rwMap[iKey] = iVal
		map = rwMap
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		map = map.rw.clear
		return this
	}

	** Remove the key/value pair identified by the specified key
	** from the map and return the value. 
	** If the key was not mapped then return 'null'.
	Obj? remove(Obj key) {
		rwMap := map.rw
		oVal  := rwMap.remove(key)
		map = rwMap
		return oVal 
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
