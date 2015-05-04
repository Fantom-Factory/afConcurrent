using concurrent

** A 'Synchronized' cache whose values update should their associated file key be modified.
** Values are updated upon calling 'getOrAddOrUpdate()' - they do not update themselves autonomously!   
** 
** To prevent excessive polling of the file system, and given every call to 'File.exists()' typically 
** takes [at least 8ms-12ms]`http://stackoverflow.com/questions/6321180/how-expensive-is-file-exists-in-java#answer-6321277`, 
** you can set a timeout 'Duration'. Every file in the cache notes when it polled the file system 
** last, and waits at least this amount of time before polling again.
** 
** Note that values are only added to the cache should the file actually exist. Given there are an 
** infinite number of files that don't exist, this prevents your cache from growing unbounded.
** (Also, how do you tell if a file has been modified if it doesn't exist!?)
** 
** Upon calling 'set()', 'getOrAdd()' or 'getOrAddOrUpdate()' should a file not exist (or has 
** subsequently been deleted) then the value function is still executed and its result returned. 
** However nothing is stored in the cache, and any previous value keyed against the file is removed.
** This ensures that the content of the cache only relates to files that exist.
** 
** Although surprising, the above behaviour is usually what you want and works very well.  
** 
** Note that all objects held in the cache have to be immutable.
// Used by efanXtra, Genesis, BsMoustache, BsEfan
const class SynchronizedFileMap {
	private const SynchronizedMap 	cache
	private const AtomicMap 		fileData

	** The duration between individual file checks.
	** Use to avoid excessive reads of the file system.
	** Set to 'null' to check the file *every* time.
	const Duration?		timeout

	** The 'lock' object should you need to 'synchronize' on the file map.
	const Synchronized	lock
	
	** The default value to use for `get` when a key isn't mapped.
	const Obj? def				:= null
	
	** Used to parameterize the backing map. 
	const Type valType			:= Obj?#

	** Creates a 'SynchronizedMap' with the given 'ActorPool' and 'timeout'.
	new make(ActorPool actorPool, Duration? timeout := 30sec, |This|? f := null) {
		this.timeout 	= timeout
		f?.call(this)
		this.cache	 	= SynchronizedMap(actorPool) { it.keyType = File#; it.valType = this.valType  }
		this.fileData	= AtomicMap() 				 { it.keyType = File#; it.valType = FileModState# }
		this.lock		= cache.lock
	}
	
	** Gets or sets a read-only copy of the backing map.
	[File:Obj?] map {
		get { cache.map }
		
		// private until I sync the file keys with the 'fileData' map 
		private set { cache.map = it }
	}

	** Sets the key / value pair, ensuring no data is lost during multi-threaded race conditions.
	** 
	** Nothing is added should the file not exist.
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
	** If the key is not mapped then it is added from the value function.
	** 
	** If the file does not exist, the 'valFunc' is executed but nothing is added to the cache. 
	**  
	** Note that 'valFunc' should be immutable and, if used, is executed in a different thread to the calling thread.
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
	** If it doesn't exist, **or the file has been modified** since the last call to 'getOrAddOrUpdate()', 
	** then it is added from the given value function. 
	** 
	** Set 'timeout' in the ctor to avoid hitting the file system on every call to this method.
	** 
	** If the file does not exist, the 'valFunc' is executed but nothing is added to the cache.
	**  
	** Note that 'valFunc' should be immutable and, if used, is executed in a different thread to the calling thread.
	Obj? getOrAddOrUpdate(File key, |File->Obj?| valFunc) {
		fileMod := (FileModState?) fileData[key]
		
		if (fileMod?.isTimedOut(timeout) ?: true) {
			iKey  := key.toImmutable
			iFunc := valFunc.toImmutable
			return cache.lock.synchronized |->Obj?| {
				// double lock
				fileMod2 := (FileModState?) fileData[iKey]				
				if (fileMod2?.isTimedOut(timeout) ?: true) {

					if (fileMod2?.isModified(iKey) ?: true)
						return setFile(iKey, iFunc)

					if (!iKey.exists)
						return setFile(iKey, iFunc)				

					// just update the last checked
					fileData.set(iKey, FileModState(iKey.modified))
				}
				return cache[key]
			}
		}

		return cache[key]
	}

	** Returns 'true' if a subsequent call to 'getOrAddOrUpdate()' would result in the 'valFunc' 
	** being executed. 
	** This method does not modify any state.
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
		
		// only cache when the file exists
		if (iKey.exists) {
			newMap := cache.map.rw
			newMap.set(iKey, iVal)
			fileData.set(iKey, FileModState(iKey.modified))
			cache.map = newMap
		
		} else if (cache.containsKey(iKey)) {
			newMap := cache.map.rw
			newMap.remove(iKey)
			fileData.remove(iKey)
			cache.map = newMap
		}

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
	
	** Returns 'false' when the file doesn't exist
	Bool isModified(File file) {
		file.modified > lastModified
	}
}
