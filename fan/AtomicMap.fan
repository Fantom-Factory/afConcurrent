using concurrent::AtomicRef

** A Map that provides fast reads and lightweight writes between threads using the copy on write paradigm. 
**
** The map is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** Writing makes a 'rw' copy of the map and is thus a more expensive operation.
** 
** > **CAUTION:** 
** Write operations ( 'getOrAdd', 'set', 'remove' & 'clear' ) are not synchronised. 
** This makes them lightweight but also susceptible to **data-loss** during race conditions.
** Though this may be acceptable for *caching* situations where values are re-calculated on demand.
** 
** All values held in the map must be immutable, except if you're caching funcs in a Javascipt environment. 
** 
** See the article [From One Thread to Another...]`http://www.fantomfactory.org/articles/from-one-thread-to-another#atomicMap` for more details.
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
	
	@NoDoc @Deprecated { msg="Use 'val' instead" }
	[Obj:Obj?] map {
		get { val }
		set { val = it }
	}

	** Gets or sets a read-only copy of the backing map.
	[Obj:Obj?] val {
		get { 
			if (atomicMap.val == null)
				atomicMap.val = Map.make(Map#.parameterize(["K":keyType, "V":valType])) {
					if (this.def != null)
						it.def = this.def 
					if (this.caseInsensitive) 
						it.caseInsensitive = this.caseInsensitive 
					it.ordered = this.ordered 
				}.toImmutable
			val := (Map) atomicMap.val
			if (Env.cur.runtime == "js")
				val = val.map { _unwrap(it) }
			return val
		}
		set {
			ConcurrentUtils.checkMapType(it.typeof, keyType, valType)
			val := it
			if (Env.cur.runtime == "js")
				val = val.map { _wrap(it) }
			atomicMap.val = val.toImmutable 
		}
	}
	
	** Returns the value associated with the given key. If it doesn't exist then it is added from 
	** the value function. 
	** 
	** This method is **NOT** thread safe. If two Actors call this method at the same time, the 
	** value function will be called twice for the same key.
	Obj? getOrAdd(Obj key, |Obj key->Obj?| valFunc) {
		ConcurrentUtils.checkType(key.typeof, keyType, "Map key")
		iKey := key.toImmutable
		got	 := get(iKey)		
		if (containsKey(iKey))
			return got
		val  := valFunc.call(iKey)
		ConcurrentUtils.checkType(val?.typeof, valType, "Map value")
		iVal := (Env.cur.runtime == "js") ? val : val?.toImmutable
		set(iKey, iVal)
		return iVal
	}

	** Sets the key / value pair.
	@Operator
	Void set(Obj key, Obj? item) {
		ConcurrentUtils.checkType(key.typeof,  keyType, "Map key")
		ConcurrentUtils.checkType(item?.typeof, valType, "Map value")
		iKey  := key.toImmutable
		iVal  := (Env.cur.runtime == "js") ? item : item?.toImmutable
		rwMap := val.rw
		rwMap[iKey] = iVal
		val = rwMap
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		val = val.rw.clear
		return this
	}

	** Remove the key/value pair identified by the specified key
	** from the map and return the value. 
	** If the key was not mapped then return 'null'.
	Obj? remove(Obj key) {
		rwMap := val.rw
		oVal  := rwMap.remove(key)
		val = rwMap
		return oVal 
	}

	// ---- Common Map Methods --------------------------------------------------------------------

	** Returns 'true' if the map contains the given key
	Bool containsKey(Obj key) {
		val.containsKey(key)
	}
	
	** Call the specified function for every key/value in the map.
	Void each(|Obj? item, Obj key| c) {
		val.each(c)
	}

	** Returns the value associated with the given key. 
	** If key is not mapped, then return the value of the 'def' parameter.  
	** If 'def' is omitted it defaults to 'null'.
	@Operator
	Obj? get(Obj key, Obj? def := this.def) {
		val.get(key, def)
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		val.isEmpty
	}

	** Returns a list of all the mapped keys.
	Obj[] keys() {
		val.keys
	}

	** Get a read-write, mutable Map instance with the same contents.
	[Obj:Obj?] rw() {
		val.rw
	}

	** Get the number of key/value pairs in the map.
	Int size() {
		val.size
	}

	** Returns a list of all the mapped values.
	Obj?[] vals() {
		val.vals
	}
	
	** Returns a string representation the map.
	override Str toStr() {
		val.toStr
	}
	
	private Obj? _unwrap(Obj? obj) {
		(obj is Unsafe && ((Unsafe) obj).val is Func) ? ((Unsafe) obj).val : obj
	}

	private Obj? _wrap(Obj? obj) {
		(obj is Func) ? Unsafe(obj) : obj
	}
}
