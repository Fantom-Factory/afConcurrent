using concurrent::ActorPool
using concurrent::AtomicRef
using concurrent::Future

** A List that provides fast reads and 'synchronised' writes between threads, ensuring data integrity.
** 
** The list is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** 
** All write operations ( 'get', 'remove' & 'clear' ) are made via 'synchronized' blocks 
** ensuring no data is lost during race conditions. 
** Writing makes a 'rw' copy of the map and is thus a more expensive operation.
** 
** All values held in the list must be immutable.
const class SynchronizedList {
	private const AtomicRef atomicList := AtomicRef()
	
	** The 'lock' object should you need to 'synchronize' on the List.
	const Synchronized	lock
	
	@NoDoc @Deprecated { msg="Use 'valType' instead" }
	Type listType {
		get { valType }
		set { throw ReadonlyErr() }
	}

	@NoDoc @Deprecated { msg="Use 'val' instead" }
	Obj?[] list {
		get { val }
		set { val = it } 
	}

	** Used to parameterize the backing list. 
	** 
	**   syntax: fantom
	**   SynchronizedList(actorPool) { it.valType = Str# }
	const Type valType	:= Obj?#

	** Creates a 'SynchronizedMap' with the given 'ActorPool'.
	new make(ActorPool actorPool, |This|? f := null) {
		this.lock = Synchronized(actorPool)
		f?.call(this)
	}
	
	** Gets or sets a read-only copy of the backing map.
	Obj?[] val {
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
	This add(Obj? item) {
		Utils.checkType(item?.typeof, valType, "List value")
		lock.synchronized |->| {
			rwList := val.rw
			rwList.add(item)
			val = rwList
		}
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
		lock.synchronized |->| {
			rwList := val.rw
			rwList.insert(index, item)
			val = rwList
		}
		return this
	}

	** Removes the specified item from the list, returning the removed item.
	** If the item was not mapped then return 'null'.
	Obj? remove(Obj item) {
		lock.synchronized |->Obj?| {
			rwList := val.rw
			oVal := rwList.remove(item)
			val = rwList
			return oVal
		}
	}

	** Remove the object at the specified index. 
	** A negative index may be used to access an index from the end of the list. 
	** Return the item removed.
	Obj? removeAt(Int index) {
		lock.synchronized |->Obj?| {
			rwList := val.rw
			oVal := rwList.removeAt(index)
			val = rwList
			return oVal
		}
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		lock.synchronized |->| {
			val = val.rw.clear
		}
		return this
	}

	This push(Obj? item) {
		Utils.checkType(item?.typeof, valType, "List value")
		lock.synchronized |->| {
			rwList := val.rw
			rwList.push(item)
			val = rwList
		}
		return this
	}

	Obj? pop() {
		lock.synchronized |->Obj?| {
			rwList := val.rw
			oVal := rwList.pop
			val = rwList
			return oVal
		}
	}

	Obj? peek() {
		val.peek
	}

	// ---- Common List Methods --------------------------------------------------------------------

	** Returns 'true' if this list contains the specified item.
	Bool contains(Obj? item) {
		val.contains(item)
	}
	
	** Call the specified function for every item in the list.
	Void each(|Obj? item, Int index| c) {
		val.each(c)
	}
	
	** Returns the item at the specified index.
	** A negative index may be used to access an index from the end of the list.
	@Operator
	Obj? get(Int index) {
		val[index]
	}
	
	** Return the item at index 0, or if empty return null.
	Obj? first() {
		val.first
	}
	
	** Return the item at index-1, or if empty return null.
	Obj? last() {
		val.last
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		val.isEmpty
	}

	** Get a read-write, mutable List instance with the same contents.
	Obj?[] rw() {
		val.rw
	}
	
	** Get the number of values in the map.
	Int size() {
		val.size
	}
	
	** Returns a string representation the list.
	override Str toStr() {
		val.toStr
	}
}
