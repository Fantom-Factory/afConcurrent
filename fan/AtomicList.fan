using concurrent::AtomicRef

** A List that provides fast reads and lightweight writes between threads using the copy on write paradigm.
**
** The list is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** Writing makes a 'rw' copy of the list and is thus a more expensive operation.
** 
** > **CAUTION:** 
** Write operations ( 'add', 'remove' & 'clear' ) are not synchronised. 
** This makes them lightweight but also susceptible to **data-loss** during race conditions.
** Though this may be acceptable for *caching* situations where values are re-calculated on demand.
** 
** All values held in the list must be immutable.
@Js
const class AtomicList {
	private const AtomicRef atomicList := AtomicRef()
	
	** Used to parameterize the backing list.
	** 
	**   syntax: fantom
	**  
	**   AtomicList() { it.valType = Str# }
	const Type valType	:= Obj?#
	
	@NoDoc	// it's a boring ctor!
	new make(|This|? f := null) { f?.call(this) }

	** Gets or sets a read-only copy of the backing map.
	Obj?[] list {
		get {
			if (atomicList.val == null)
				atomicList.val = valType.emptyList
			return atomicList.val 
		}
		set {
			Utils.checkListType(it.typeof, valType)
			atomicList.val = it.toImmutable 
		}
	}
	
	** Add the specified item to the end of the list.
	** Return this. 
	@Operator
	This add(Obj? val) {
		Utils.checkType(val?.typeof, valType, "List value")
		rwList := list.rw
		rwList.add(val)
		list = rwList
		return this
	}
	
	** Insert the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	** Size is incremented by 1.
	** Return this.
	** Throw IndexErr if index is out of range.
	** Throw ReadonlyErr if readonly. 
	This insert(Int index, Obj? val) {
		Utils.checkType(val?.typeof, valType, "List value")
		rwList := list.rw
		rwList.insert(index, val)
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

	** Remove the object at the specified index. 
	** A negative index may be used to access an index from the end of the list. 
	** Return the item removed.
	Obj? removeAt(Int index) {
		rwList := list.rw
		oVal  := rwList.removeAt(index)
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
	
	** Return the item at index 0, or if empty return null.
	Obj? first() {
		list.first
	}
	
	** Return the item at index-1, or if empty return null.
	Obj? last() {
		list.last
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
