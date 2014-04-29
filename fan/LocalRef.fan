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

	** The default value for `val` when 'qname' isn't mapped.
	const Obj? def
	
	Obj? val {
		get { Actor.locals.get(qname, def) }
		set { Actor.locals[qname] = it }
	}
	
	** Creates an entry in 'Actor.locals' using the given name.
	** 
	** 'def' is an immutable value that is returned in place of 'val', should 'qname' not yet be mapped.
	new make(Str name, Obj? def := null) {
		this.qname 	= createPrefix(name, 4)
		this.name 	= name
		this.def	= def
	}

	** Removes this object from 'Actor.locals'.
	Void cleanUp() {
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
