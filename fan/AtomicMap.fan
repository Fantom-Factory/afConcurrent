using concurrent::AtomicRef

** A Map that provides fast reads and lightweight writes between threads.
**
** The map is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** Writing makes a 'rw' copy of the map and is thus a more expensive operation.
** 
** > **CAUTION:** 
** Write operations ( 'getOrAdd', 'set', 'remove' & 'clear' ) are not synchronised. 
** This makes them lightweight but also susceptible to **data-loss** during race conditions.
** This may be acceptable for *caching* situations where values are easily re-calculated.
** 
** All values held in the map must be immutable.
** 
** See [From One Thread to Another...]`http://www.fantomfactory.org/articles/from-one-thread-to-another#atomicMap` for more details.
@Js
const class AtomicMap {
	private const AtomicRef atomicMap := AtomicRef()

	** The default value to use for `get` when a key isn't mapped.
	const Obj? def				:= null
	
	** Configures case sensitivity for maps with 'Str' keys.
	**
	**   syntax: fantom
	**  
	**   AtomicMap() { it.keyType = Str#; it.caseInsensitive = true }
	const Bool caseInsensitive	:= false

	** If 'true' the map will maintain the order in which key/value pairs are added.
	** 
	**   syntax: fantom
	**  
	**   AtomicMap() { it.ordered = true }
	const Bool ordered			:= false
	
	** Used to parameterize the backing map.
	** Must be non-nullable.
	** 
	**   syntax: fantom
	**  
	**   AtomicMap() { it.keyType = Int# }
	const Type keyType			:= Obj#
	
	** Used to parameterize the backing map. 
	** 
	**   syntax: fantom 
	** 
	**   AtomicMap() { it.valType = Int# }
	const Type valType			:= Obj?#
	
	@NoDoc	// pointless ctor!
	new make(|This|? f := null) { 
		f?.call(this) 
		if (caseInsensitive && keyType == Obj#)
			keyType = Str#
	}
	
	** Gets or sets a read-only copy of the backing map.
	[Obj:Obj?] map {
		get { 
			if (atomicMap.val == null)
				atomicMap.val = Map.make(Map#.parameterize(["K":keyType, "V":valType])) {
					if (this.def != null)
						it.def = this.def 
					if (this.caseInsensitive) 
						it.caseInsensitive = this.caseInsensitive 
					it.ordered = this.ordered 
				}.toImmutable
			return atomicMap.val 
		}
		set {
			Utils.checkMapType(it.typeof, keyType, valType)
			atomicMap.val = it.toImmutable 
		}
	}
	
	** Returns the value associated with the given key. If it doesn't exist then it is added from 
	** the value function. 
	** 
	** This method is **NOT** thread safe. If two Actors call this method at the same time, the 
	** value function will be called twice for the same key.
	Obj? getOrAdd(Obj key, |Obj key->Obj?| valFunc) {
		Utils.checkType(key.typeof, keyType, "Map key")
		iKey := key.toImmutable
		got	 := get(iKey)		
		if (containsKey(iKey))
			return got
		val  := valFunc.call(iKey)
		Utils.checkType(val?.typeof, valType, "Map value")
		iVal := val.toImmutable
		set(iKey, iVal)
		return iVal
	}

	** Sets the key / value pair.
	@Operator
	Void set(Obj key, Obj? val) {
		Utils.checkType(key.typeof,  keyType, "Map key")
		Utils.checkType(val?.typeof, valType, "Map value")
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

	** Returns 'true' if the map contains the given key
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
