
** Manages a List stored in 'Actor.locals' under a unique key.
const class LocalList {
	
	** The 'LocalRef' this 'LocalList' wraps. 
	const LocalRef	localRef
	
	new make(Str name) {
		this.localRef = LocalRef(name, [,])
	}

	new makeWithList(Str name, Obj?[] list) {
		this.localRef = LocalRef(name, list)
	}
	
	** Gets or sets the thread local list
	Obj?[] list {
		get { localRef.val }
		set { localRef.val = it.toImmutable }
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

	** Returns the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	Obj? get(Int index) {
		list[index]
	}
	
	** Call the specified function for every item in the list.
	Void each(|Obj? item, Int index| c) {
		list.each(c)
	}
	
	** Returns 'true' if this list contains the specified item.
	Bool contains(Obj? item) {
		list.contains(item)
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		list.isEmpty
	}

	** Get the number of values in the map.
	Int size() {
		list.size
	}
}
