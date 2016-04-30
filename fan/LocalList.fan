
** Manages a List stored in 'Actor.locals' with a unique key.
** 
** Note that 'LocalLists' are lazy; that is, no List is created or stored in 'Actor.locals' until accessed.
// @Js	- see http://fantom.org/forum/topic/1144
const class LocalList {
	
	** The 'LocalRef' this 'LocalList' wraps. 
	const LocalRef	localRef
	
	** Used to parameterize the backing list. 
	** 
	**   syntax: fantom
	**  
	**   LocalList("name") { it.valType = Str# }
	const Type valType	:= Obj?#
	
	** Makes a 'LocalList' instance. 'name' is passed to 'LocalList'.
	new make(Str name := "LocalList", |This|? f := null) {
		this.localRef = LocalRef(name) |->Obj?| { valType.emptyList.rw }.toImmutable
		f?.call(this)
	}

	** Gets or sets the thread local list
	Obj?[] list {
		get { localRef.val }
		set { 
			Utils.checkListType(it.typeof, valType)
			localRef.val = it 
		}
	}
	
	** Add the specified item to the end of the list.
	** Return this. 
	@Operator
	This add(Obj? val) {
		Utils.checkType(val?.typeof, valType, "List value")
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
		if (localRef.isMapped)
			list.clear
		return this
	}

	// ---- Common List Methods --------------------------------------------------------------------

	** Returns 'true' if this list contains the specified item.
	Bool contains(Obj? item) {
		localRef.isMapped ? list.contains(item) : false
	}
	
	** Call the specified function for every item in the list.
	Void each(|Obj? item, Int index| c) {
		if (localRef.isMapped)
			list.each(c)
	}
	
	** Returns the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	@Operator
	Obj? get(Int index) {
		localRef.isMapped ? list[index] : throw IndexErr(index.toStr)
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		localRef.isMapped ? list.isEmpty : true
	}
	
	** Get the number of values in the map.
	Int size() {
		localRef.isMapped ? list.size : 0
	}
}
