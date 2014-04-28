
const class ThreadLocal {
	
	private const ThreadLocals threadLocals
			const Str name
	
	virtual Obj? val {
		get { threadLocals[name] }
		set { threadLocals[name] = it }
	}
	
	new make(Str name, ThreadLocals? threadLocals := null) {
		this.threadLocals = threadLocals ?: ThreadLocals(typeof.name)
		this.name = name
	}
	
	Void remove() {
		threadLocals.remove(name)
	}
}
