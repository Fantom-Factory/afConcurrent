
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
	Obj?[] val {
		get { localRef.val }
		set { 
			Utils.checkListType(it.typeof, valType)
			localRef.val = it 
		}
	}

	@NoDoc @Deprecated { msg="Use 'val' instead" }
	Obj?[] list {
		get { val }
		set { val = it }
	}
	
	** Add the specified item to the end of the list.
	** Return this. 
	@Operator
	This add(Obj? item) {
		Utils.checkType(item?.typeof, valType, "List value")
		val.add(item)
		return this
	}
	
	** Insert the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	** Size is incremented by 1.
	** Return this.
	** Throw IndexErr if index is out of range.
	** Throw ReadonlyErr if readonly. 
	This insert(Int index, Obj? item) {
		Utils.checkType(item?.typeof, valType, "List value")
		val.insert(index, item)
		return this
	}

	** Removes the specified item from the list, returning the removed item.
	** If the item was not mapped then return 'null'.
	Obj? remove(Obj item) {
		val.remove(item)
	}

	** Remove the object at the specified index. 
	** A negative index may be used to access an index from the end of the list. 
	** Return the item removed.
	Obj? removeAt(Int index) {
		val.removeAt(index)
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		if (localRef.isMapped)
			val.clear
		return this
	}
	
	This push(Obj? item) {
		val.push(item)
		return this
	}

	Obj? pop() {
		val.pop
	}

	Obj? peek() {
		val.peek
	}


	// ---- Common List Methods --------------------------------------------------------------------

	** Returns 'true' if this list contains the specified item.
	Bool contains(Obj? item) {
		localRef.isMapped ? val.contains(item) : false
	}
	
	** Call the specified function for every item in the list.
	Void each(|Obj? item, Int index| c) {
		if (localRef.isMapped)
			val.each(c)
	}
	
	** Returns the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	@Operator
	Obj? get(Int index) {
		localRef.isMapped ? val[index] : throw IndexErr(index.toStr)
	}
	
	** Return the item at index 0, or if empty return null.
	Obj? first() {
		localRef.isMapped ? val.first : null
	}
	
	** Return the item at index-1, or if empty return null.
	Obj? last() {
		localRef.isMapped ? val.last : null
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		localRef.isMapped ? val.isEmpty : true
	}
	
	** Get the number of values in the map.
	Int size() {
		localRef.isMapped ? val.size : 0
	}
	
	** Returns a string representation the list.
	override Str toStr() {
		val.toStr
	}
}
