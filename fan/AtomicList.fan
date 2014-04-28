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
	
	new make() {
		this.list = [,]
	}

	** Makes an 'AtomicList' wrapping the given immutable list. 
	new makeWithList(Obj?[] list) {
		this.list = list
	}
	
	** Gets or sets a read-only copy of the backing map.
	Obj?[] list {
		get { atomicList.val }
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

	** Returns 'true' if this list contains the specified item.
	Bool contains(Obj? item) {
		list.contains(item)
	}
	
	** Remove all key/value pairs from the map. Return this.
	This clear() {
		list = list.rw.clear
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

	** Return 'true' if size() == 0
	Bool isEmpty() {
		list.isEmpty
	}

	** Get the number of values in the map.
	Int size() {
		list.size
	}
}
