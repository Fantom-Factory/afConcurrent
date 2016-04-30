using concurrent

internal class TestSynchronizedList : ConcurrentTest {
	
	Void testMutableLists() {
		verifyErr(NotImmutableErr#) {
			SynchronizedList(ActorPool()).list = [NotImmutable()]			
		}
	}

	Void testMutableAdd() {
		verifyErr(NotImmutableErr#) {
			SynchronizedList(ActorPool()).add(NotImmutable())			
		}
	}
	
	Void testListType() {
		verifyEq(SynchronizedList(ActorPool()) { valType = Obj?# }.list.typeof,	Obj?[]#)			
		verifyEq(SynchronizedList(ActorPool()) { valType = Obj?# }.list.of, 		Obj?#)

		verifyEq(SynchronizedList(ActorPool()) { valType = Str?# }.list.typeof,	Str?[]#)			
		verifyEq(SynchronizedList(ActorPool()) { valType = Str?# }.list.of,		Str?#)

		verifyEq(SynchronizedList(ActorPool()) { valType = Int# }.list.typeof,		Int[]#)			
		verifyEq(SynchronizedList(ActorPool()) { valType = Int# }.list.of, 		Int#)
	}
	
	Void testListTypeChecks() {
		list := SynchronizedList(ActorPool()) { valType = Str# }
		
		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Int#, Str#, "List value")) {
			list.add(39)
		}
		
		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Int[]#, Str[]#, "List")) {
			list.list = Int[,]
		}

		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(null, Str#, "List value")) {
			list.add(null)
		}
	}
}
