using concurrent::ActorPool
using concurrent::Future
using concurrent::AtomicRef

** Lets you perform concurrent units of work. 
const class WorkerPool {
	private const AtomicRef	poolRef
	
	** Max number of threads used by this pool for concurrent actor execution.
	** 
	** May be updated.
	Int numWorkers {
		get { pool.maxThreads }
		set { switchPool(it)}
	}
	
	** Create a new 'WorkerPool' with the given number of workers.
	new make(Int maxWorkers, Str name := "WorkerPool") {
		this.poolRef = AtomicRef(ActorPool {
			it.name			= name
			it.maxThreads	= maxWorkers
		})
	}
	
	** The wrapped 'ActorPool'.
	ActorPool pool() {
		poolRef.val
	}
	
	** Runs the given func asynchronously.
	** 
	** The given func and return value must be immutable.
	Future work(|->Obj?| f) {
		Synchronized(pool).async(f)
	}

	** Runs the given func asynchronously, after the given duration has elapsed.
	** 
	** The given func and return value must be immutable.
	Future workLater(Duration d, |->Obj?| f) {
		Synchronized(pool).asyncLater(d, f)
	}
	
	** Name used by pool and associated threads.
	Str name() {
		pool.name
	}
	
	@NoDoc
	override Str toStr() {
		"${typeof.name} ${name.toCode} ${numWorkers} workers"
	}
	
	private Void switchPool(Int numWorkers) {
		if (numWorkers < 1)
			throw ArgErr("numWorkers must greater than zero : $numWorkers")
		if (numWorkers != pool.maxThreads) {
			pool.stop
			poolRef.val = ActorPool {
				it.name			= pool.name
				it.maxThreads	= numWorkers
			}
		}
	}
}
