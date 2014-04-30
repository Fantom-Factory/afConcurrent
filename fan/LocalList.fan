
** Manages a List stored in 'Actor.locals' with a unique key.
** 
** Note that 'LocalLists' are lazy; that is, no List is created or stored in 'Actor.locals' until accessed.
const class LocalList {
	
	** The 'LocalRef' this 'LocalList' wraps. 
	const LocalRef	localRef
	
	** Makes a 'LocalList' instance.
	new make(Str name) {
		this.localRef = LocalRef(name)
	}

	** Gets or sets the thread local list
	Obj?[] list {
		get {
			if (localRef.val == null)
				localRef.val = [,]
			return localRef.val
		}
		set { localRef.val = it }
	}
	
	** Add the specified item to the end of the list.
	** Return this. 
	@Operator
	This add(Obj? val) {
		list.add(val)
		return this
	}

	** Removes the specified item from the list, returning the removed item.
	** If the item was not mapped then return 'null'.
	Obj? remove(Obj item) {
		list.remove(item)
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		list.clear
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