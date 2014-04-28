
internal mixin ErrMsgs {
	
	static Str synchronized_nestedCallsNotAllowed() {
		"Due to Actor semantics, nested calls to synchronized() result in a Deadlock."
	}
}
