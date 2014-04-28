using concurrent::Actor

** A wrapper around [Actor.locals]`concurrent::Actor.locals` that ensures a unique names per 
** instance. This means you don't have to worry about name clashes. 
** 
** Example usage:
** 
** pre>
**   stash1 := ThreadStash("name")
**   stash1["wot"] = "top"
** 
**   stash2 := ThreadStash("name")
**   stash2["wot"] = "banana"
** 
**   echo(stash1["wot"])  // --> top
**   echo(stash2["wot"])  // --> banana
** <pre
** 
** Though typically you would create calculated field wrappers for your variables:
** 
** pre>
** const class Example
**   private const ThreadStash stash := LocalStash(typeof.name)
**   
**   MyService wotever {
**     get { stash["wotever"] }
**     set { stash["wotever"] = it }
**   }
** }
** <pre
**
** Also see `ThreadStashManager` to ensure your thread values get cleaned up, say, at the end of a 
** HTTP web request.
const class ThreadLocals {

	** The prefix used to identify all keys used with this 'ThreadLocals' instance.
	** This 'prefix' is an enhanced version to the one passed into the ctor. 
	const Str prefix

	// FIXME: counter leaks!
	private Int? counter {
		get { Actor.locals["${typeof.qname}.counter"] }
		set { Actor.locals["${typeof.qname}.counter"] = it }
	}
	
	new make(Str prefix) {
		this.prefix = createPrefix(prefix)
	}

	** Returns the value associated with the given name. 
	** If it doesn't exist then it is added from the value function. 
	Obj? getOrAdd(Str name, |Obj key ->Obj?| defFunc) {
		key := key(name)
		
		if (Actor.locals.containsKey(key))
			return Actor.locals[key] 
		
		val := defFunc(name)
		Actor.locals[key] = val
		return val
	}
	
	** Returns the value associated with the given name. 
	** If name is not mapped, then return 'def'.  
	@Operator
	Obj? get(Str name, Obj? def := null) {
		key := key(name)
		return Actor.locals.containsKey(key) ? Actor.locals[key] : def 
	}

	** Set the value for the specified name.
	@Operator
	Void set(Str name, Obj? value) {
		Actor.locals[key(name)] = value
	}
	
	** Returns 'true' if this 'ThreadLocals' instance contains the given name.
	Bool containsKey(Str name) {
		keys.contains(key(name))
	}
	
	** Returns all (fully qualified) keys associated / used with this 'ThreadLocals' instance.
	** The keys are sorted alphabetically. 
	Str[] keys() {
		Actor.locals.keys
			.findAll { it.startsWith(prefix) }
			.sort
	}
	
	** Returns a list of all the mapped values.
	Obj[] vals() {
		keys.map { Actor.locals[it] }
	}
	
	** Removes all key/value pairs associated with this 'ThreadLocals' instance.
	Void clear() {
		keys.each { Actor.locals.remove(it) }
	}

	** Remove the name/value pair from the 'ThreadLocals' instance and returns the mapped value.
	** If the name was not mapped then return null.
	Obj? remove(Str name) {
		Actor.locals.remove(key(name))
	}
	
	** Return 'true' if size() == 0
	Bool isEmpty() {
		keys.isEmpty
	}

	** Get the number of key/value pairs in this 'ThreadLocals' instance.
	Int size() {
		keys.size
	}



	// ---- Helper Methods ------------------------------------------------------------------------

	private Str createPrefix(Str strPrefix) {
		count 	:= counter ?: 1
		padded	:= count.toStr.padl(4, '0')
		prefix 	:= "${strPrefix}.${padded}."
		counter = count + 1
		return prefix
	}

	private Str key(Str name) {
		return "${prefix}${name}"
	}
}
