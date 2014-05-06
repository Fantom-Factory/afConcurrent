using concurrent::AtomicRef

** A List that provides fast reads and lightweight writes between threads.
** Use when *reads* far out number the *writes*.
**
** The list is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** Writing makes a 'rw' copy of the list and is thus a more expensive operation.
** 
** > **CAUTION:** 
** Write operations ( 'add', 'remove' & 'clear' ) are not synchronised. 
** This makes them lightweight but also susceptible to **data-loss** during race conditions.
** This may be acceptable for *caching* situations where values is easily re-calculated.
** 
** Note that all values held in the list must be immutable.
const class AtomicList {
	private const AtomicRef atomicList := AtomicRef()
	
	** Used to parameterize the backing list. 
	const Type listType	:= Obj?#
	
	@NoDoc	// it's a boring ctor!
	new make(|This|? f := null) { f?.call(this) }

	** Gets or sets a read-only copy of the backing map.
	Obj?[] list {
		get {
			if (atomicList.val == null)
				atomicList.val = listType.emptyList
			return atomicList.val 
		}
		set { atomicList.val = it.toImmutable }
	}
	
	** Add the specified item to the end of the list.
	** Return this. 
	@Operator
	This add(Obj? val) {
		rwList := list.rw
		rwList.add(val)
		list = rwList
		return this
	}

	** Removes the specified item from the list, returning the removed item.
	** If the item was not mapped then return 'null'.
	Obj? remove(Obj item) {
		rwList := list.rw
		oVal  := rwList.remove(item)
		list = rwList
		return oVal 
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		list = list.rw.clear
		return this
	}

	// ---- Common List Methods --------------------------------------------------------------------

	** Returns 'true' if this list contains the specified item.
	Bool contains(Obj? item) {
		list.contains(item)
	}
	
	** Call the specified function for every item in the list.
	Void each(|Obj? item, Int index| c) {
		list.each(c)
	}
	
	** Returns the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	@Operator
	Obj? get(Int index) {
		list[index]
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		list.isEmpty
	}

	** Get a read-write, mutable List instance with the same contents.
	Obj?[] rw() {
		list.rw
	}
	
	** Get the number of values in the map.
	Int size() {
		list.size
	}
}
