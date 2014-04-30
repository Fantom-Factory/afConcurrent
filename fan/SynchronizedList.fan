using concurrent::ActorPool
using concurrent::AtomicRef
using concurrent::Future

** A List that provides fast reads and 'synchronised' writes between threads, ensuring data integrity.
** Use when *reads* far out number the *writes*.
** 
** The list is stored in an [AtomicRef]`concurrent::AtomicRef` through which all reads are made. 
** 
** All write operations ( 'get', 'remove' & 'clear' ) are made via 'synchronized' blocks 
** ensuring no data is lost during race conditions. 
** Writing makes a 'rw' copy of the map and is thus a more expensive operation.
** 
** Note that all objects held in the map have to be immutable.
const class SynchronizedList {
	private const AtomicRef 	atomicList := AtomicRef()
	private const Synchronized	lock
	
	new make(ActorPool actorPool) {
		this.lock	= Synchronized(actorPool)
		this.list 	= [,]
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
		lock.synchronized |->| {
			rwList := list.rw
			rwList.add(val)
			list = rwList
		}
		return this
	}

	** Removes the specified item from the list, returning the removed item.
	** If the item was not mapped then return 'null'.
	Obj? remove(Obj item) {
		lock.synchronized |->Obj| {
			rwList := list.rw
			oVal := rwList.remove(item)
			list = rwList
			return oVal
		}
	}

	** Remove all key/value pairs from the map. Return this.
	This clear() {
		lock.synchronized |->Obj| {
			list = list.rw.clear			
		}
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
