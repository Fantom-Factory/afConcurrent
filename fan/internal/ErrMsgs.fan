
internal mixin ErrMsgs {
	
	static Str synchronized_nestedCallsNotAllowed() {
		"Due to Actor semantics, nested calls to synchronized() result in a Deadlock."
	}
	
	static Str synchronized_silentErr() {
		"This Err is being logged to avoid it being swallowed as Errs thrown in async {...} blocks do not propagate to the calling thread."
	}
	
	static Str synchronized_notImmutable(Type returns) {
		stripSys("Synchronized return type ${returns.signature} is not immutable or serializable")
	}

	static Str wrongType(Type? wrong, Type right, Str type) {
		stripSys("'${wrong?.signature}' does not fit ${type} type '${right.signature}'")		
	}

	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
