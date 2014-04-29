using concurrent

** Manages an object reference stored in 'Actor.locals' under a unique key.
const class LocalRef {	
	static 
	private const AtomicInt	counter	:= AtomicInt(0)
	
	** The qualified name this 'ThreadLocal' is stored under in 'Actor.locals'. 
	** 'qname' is calculated from 'name'.
	const Str qname
	
	** The variable name given to the ctor.
	const Str name

	Obj? val {
		get { Actor.locals[qname] }
		set { Actor.locals[qname] = it }
	}
	
	** Creates an entry in 'Actor.locals' using the given name.
	new make(Str name, Obj? initVal := null) {
		this.qname 	= createPrefix(name, 4)
		this.name 	= name
		if (initVal != null)
			this.val	= initVal
	}

	** Returns 'true' if 'Actor.locals' holds an entry for this 'qname'.
	Bool isMapped() {
		Actor.locals.containsKey(qname)
	}
	
	** Removes this object from 'Actor.locals'.
	Void cleanUp() {
		Actor.locals.remove(qname)
	}
	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	private Str createPrefix(Str name, Int pad) {
		count 	:= counter.incrementAndGet
		padded	:= Base64.toBase64(count, pad)
		inter	:= name.contains("\${id}") ? name : "\${id}.${name}"
		prefix 	:= inter.replace("\${id}", padded)
		return prefix
	}
}
