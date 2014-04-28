using concurrent

** A wrapper around [Actor.locals]`concurrent::Actor.locals` that ensures a unique names per 
** instance. This means you don't have to worry about name clashes. 
//const class ThreadLocals {
//	static 
//	private const AtomicInt	counter	:= AtomicInt(0)
//	private const Str prefix
//	
//	private const ThreadLocal cleanupHandlers
//	
//	new make(Str prefix := "ThreadLocals") {
//		this.prefix = createPrefix(prefix, 2)
//		this.cleanupHandlers = create("cleanupHandlers") |->Obj?| { [,] }
//	}
//
//	ThreadLocal create(Str name, |->Obj?|? initFunc := null) {
//		ThreadLocal("${prefix}.${name}", initFunc)
//	}
//
//	Str[] keys() {
//		Actor.locals.keys
//			.findAll { it.startsWith(prefix) }
//			.sort
//	}
//	
//	Void addCleanUpHandler(|->| handler) {
//		((|->|[]) cleanupHandlers.val).add(handler)
//	}
//	
//	Void cleanUpThread() {
//		((|->|[]) cleanupHandlers.val).each |handler| { handler.call }
//		keys.each { Actor.locals.remove(it) }
//	}
//
//	// ---- Helper Methods ------------------------------------------------------------------------
//	
//	private Str createPrefix(Str name, Int pad) {
//		count 	:= counter.incrementAndGet
//		padded	:= Base64.toBase64(count, pad)
//		prefix 	:= "${name}.${padded}"
//		return prefix
//	}
//}
