
internal mixin ErrMsgs {
	
	static Str synchronized_nestedCallsNotAllowed() {
		"Due to Actor semantics, nested calls to synchronized() result in a Deadlock."
	}
	
	static Str synchronized_silentErr() {
		"This Err is being logged to avoid it being swallowed as Errs thrown in async {...} blocks do not propagate to the calling thread."
	}
	
	static Str synchronized_notImmutable(Type returns) {
		"Synchronized return type ${returns} is not immutable or serializable"
	}
}
