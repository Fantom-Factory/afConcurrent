using concurrent

** A 'SynchronisedMap', keyed on 'File', that updates its contents if the file is updated.
** Use as a cache based on the content of the file, see 'getOrAddOrUpdate()'.
** 
** Note that all objects held in the map have to be immutable.
// Used by efanXtra, Genesis, BsMoustache, BsEfan
const class SynchronizedFileMap {
	private const SynchronizedMap 	cache
	private const AtomicMap 		fileData
	private const Duration?			timeout

	** The default value to use for `get` when a key isn't mapped.
	const Obj? def				:= null
	
	** Used to parameterize the backing map. 
	const Type valType			:= Obj?#

	** Creates a 'SynchronizedMap' with the given 'ActorPool'.
	** 
	** 'timeout' is how long to wait between individual file checks.
	** Use to avoid excessive reads of the file system.
	** Set to 'null' to check the file *every* time.
	new make(ActorPool actorPool, Duration? timeout := 30sec, |This|? f := null) {
		f?.call(this)
		this.cache	 	= SynchronizedMap(actorPool) { it.keyType = File#; it.valType = this.valType }
		this.fileData	= AtomicMap() 				 { it.keyType = File#; it.valType = FileModState# }
		this.timeout 	= timeout
	}
	
	** Gets or sets a read-only copy of the backing map.
	[File:Obj?] map {
		get { cache.map }
		
		// private until I sync the file keys with the 'fileData' map 
		private set { cache.map = it }
	}

	** Sets the key / value pair, ensuring no data is lost during multi-threaded race conditions.
	@Operator
	Void set(File key, Obj? val) {
		Utils.checkType(val?.typeof, valType, "Map value")
		iKey := key.toImmutable
		iVal := val.toImmutable
		cache.lock.synchronized |->| {
			setFile(iKey, |->Obj?| { iVal })
		}
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		cache.lock.synchronized |->| {
			cache.map = cache.map.rw.clear
			fileData.clear
		}		
		return this
	}
	
	** Remove the key/value pair identified by the specified key
	** from the map and return the value. 
	** If the key was not mapped then return 'null'.
	Obj? remove(File key) {
		iKey := key.toImmutable
		return cache.lock.synchronized |->Obj?| {
			newMap := cache.map.rw
			val := newMap.remove(iKey)
			fileData.remove(iKey)
			cache.map = newMap
			return val 
		}
	}

	** Returns the value associated with the given key. 
	** If it doesn't exist then it is added from the value function. 
	Obj? getOrAdd(File key, |File->Obj?| valFunc) {
		if (containsKey(key))
			return get(key)
		
		iKey  := key.toImmutable
		iFunc := valFunc.toImmutable
		return cache.lock.synchronized |->Obj?| {
			// double lock
			if (containsKey(iKey))
				return get(iKey)

			return setFile(iKey, iFunc)
		}
	}
	
	** Returns the value associated with the given file. 
	** If it doesn't exist, **or the file has been updated since the last get,** then it is added from 
	** the given value function. 
	** 
	** Set 'timeout' in the ctor to avoid hitting the file system on every call to this method.
	Obj? getOrAddOrUpdate(File key, |File->Obj?| valFunc) {
		fileMod := (FileModState?) fileData[key]
		
		if (fileMod?.isTimedOut(timeout) ?: true) {
			iKey  := key.toImmutable
			iFunc := valFunc.toImmutable
			cache.lock.synchronized |->| {
				// double lock
				fileMod2 := (FileModState?) fileData[iKey]				
				if (fileMod2?.isTimedOut(timeout) ?: true) {
					
					if (fileMod2?.isModified(iKey) ?: true) 
						setFile(iKey, iFunc)
					else
						// just update the last checked
						fileData.set(iKey, FileModState(iKey.modified))
				}
			}
		}

		return cache[key]
	}

	** Returns 'true' if a subsequent call to 'getOrAddOrUpdate()' would result in the 'valFunc' 
	** being executed. This method does not modify any state and returns 'true' if the file has 
	** not been added to the map.
	Bool isModified(File key) {
		fileMod := (FileModState?) fileData[key]
		if (fileMod == null)
			return true
		if (!fileMod.isTimedOut(timeout))
			return false
		return fileMod.isModified(key)
	}
	
	private Obj? setFile(File iKey, |File->Obj?| iFunc) {
		val  := iFunc.call(iKey)
		Utils.checkType(val?.typeof, valType, "Map value")
		iVal := val.toImmutable
		newMap := cache.map.rw
		newMap.set(iKey, iVal)
		fileData.set(iKey, FileModState(iKey.modified))
		cache.map = newMap		
		return iVal
	}
	
	// ---- Common Map Methods --------------------------------------------------------------------

	** Returns 'true' if the map contains the given file
	Bool containsKey(File key) {
		map.containsKey(key)
	}
	
	** Returns the value associated with the given key. 
	** If key is not mapped, then return the value of the 'def' parameter.  
	** If 'def' is omitted it defaults to 'null'.
	@Operator
	Obj? get(File key, Obj? def := this.def) {
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

internal const class FileModState {
	const DateTime	lastChecked
	const DateTime	lastModified	// pod files have last modified info too!
	
	new make(DateTime lastModified) {
		this.lastChecked	= DateTime.now
		this.lastModified	= lastModified
	}	
	
	Bool isTimedOut(Duration? timeout) {
		timeout == null
			? true
			: (DateTime.now - lastChecked) > timeout
	}
	
	Bool isModified(File file) {
		file.modified > lastModified
	}
}
