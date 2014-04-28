using concurrent

** Manages an object reference stored in 'Actor.locals' under a unique key.
const class ThreadLocalRef {	
	static 
	private const AtomicInt	counter	:= AtomicInt(0)
	private const |->Obj?|? initFunc

	** The qualified name this 'ThreadLocal' is stored under in 'Actor.locals'. 
	** 'qname' is calculated from 'name'.
	const Str qname
	
	** The variable name given to the ctor.
	const Str name
	
	Obj? val {
		get { Actor.locals.containsKey(qname) ? Actor.locals[qname] : initFunc?.call() }
		set { Actor.locals[qname] = it }
	}
	
	new make(Str name, |->Obj?|? initFunc := null) {
		this.qname 		= createPrefix(name, 4)
		this.name 		= name
		this.initFunc	= initFunc
	}

	** Removes this object from 'Actor.locals'.
	Void purge() {
		Actor.locals.remove(qname)
	}
	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	private Str createPrefix(Str name, Int pad) {
		count 	:= counter.incrementAndGet
		padded	:= Base64.toBase64(count, pad)
		prefix 	:= "${name}.${padded}"
		return prefix
	}
}
