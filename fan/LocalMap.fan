
** Manages a Map stored in 'Actor.locals' with a unique key.
** 
** Note that 'LocalMaps' are lazy; that is, no Map is created or stored in 'Actor.locals' until accessed.
const class LocalMap {
	
	** The 'LocalRef' this 'LocalMap' wraps. 
	const LocalRef	localRef

	** The default value to use for `get` when a key isn't mapped.
	const Obj? def				:= null
	
	** Configures case sensitivity for maps with Str keys.
	** 
	**   LocalMap("name") { it.keyType = Str#; it.caseInsensitive = true }
	const Bool caseInsensitive	:= false

	** If 'true' the map will maintain the order in which key/value pairs are added.
	** 
	**   LocalMap("name") { it.ordered = true }
	const Bool ordered			:= false
	
	** Used to parameterize the backing map.
	** Must be non-nullable.
	** 
	**   LocalMap("name") { it.keyType = Int# }
	const Type keyType			:= Obj#
	
	** Used to parameterize the backing map. 
	** 
	**   LocalMap("name") { it.valType = Str# }
	const Type valType			:= Obj?#

	** Makes a 'LocalMap' instance. 'name' is passed to 'LocalRef'.
	new make(Str name := "LocalMap", |This|? f := null) {
		this.localRef = LocalRef(name) |->Obj?| {
			Map.make(Map#.parameterize(["K":keyType, "V":valType])) {
				if (this.def != null)
					it.def = this.def
				if (this.caseInsensitive) 
					it.caseInsensitive = this.caseInsensitive 
				it.ordered = this.ordered 
			}
		}
		f?.call(this)
		if (caseInsensitive && keyType == Obj#)
			keyType = Str#
	}
	
	** Gets or sets the thread local map
	[Obj:Obj?] map {
		get { localRef.val }
		set { 
			Utils.checkMapType(it.typeof, keyType, valType)
			localRef.val = it 
		}
	}
	
	** Returns the value associated with the given key. 
	** If it doesn't exist then it is added from the value function. 
	** 
	** This method is thread safe. 'valFunc' will not be called twice for the same key.
	Obj? getOrAdd(Obj key, |Obj key->Obj?| valFunc) {
		Utils.checkType(key.typeof,  keyType, "Map key")
		return map.getOrAdd(key) |Obj k1->Obj?| {
			val := valFunc(k1)
			Utils.checkType(val?.typeof, valType, "Map value")
			return val
		}
	}

	** Sets the key / value pair, ensuring no data is lost during multi-threaded race conditions.
	** Though the same key may be overridden. Both the 'key' and 'val' must be immutable. 
	@Operator
	Void set(Obj key, Obj? val) {
		Utils.checkType(key.typeof,  keyType, "Map key")
		Utils.checkType(val?.typeof, valType, "Map value")
		map[key] = val
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		if (localRef.isMapped)
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

	** Returns 'true' if the map contains the given key
	Bool containsKey(Obj key) {
		localRef.isMapped ? map.containsKey(key) : false
	}
	
	** Returns the value associated with the given key. 
	** If key is not mapped, then return the value of the 'def' parameter.  
	** If 'def' is omitted it defaults to 'null'.
	@Operator
	Obj? get(Obj key, Obj? def := this.def) {
		localRef.isMapped ? map.get(key, def) : def
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		localRef.isMapped ? map.isEmpty : true
	}

	** Returns a list of all the mapped keys.
	Obj[] keys() {
		localRef.isMapped ? map.keys : keyType.emptyList
	}

	** Get the number of key/value pairs in the map.
	Int size() {
		localRef.isMapped ? map.size : 0
	}

	** Returns a list of all the mapped values.
	Obj?[] vals() {
		localRef.isMapped ? map.vals : valType.emptyList
	}
}
