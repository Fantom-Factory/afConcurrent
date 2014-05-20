using concurrent

internal class TestSynchronizedList : ConcurrentTest {
	
	Void testMutableLists() {
		verifyErr(NotImmutableErr#) {
			SynchronizedList(ActorPool()).list = [Buf()]			
		}
	}

	Void testMutableAdd() {
		verifyErr(NotImmutableErr#) {
			SynchronizedList(ActorPool()).add(Buf())			
		}
	}
	
	Void testListType() {
		verifyEq(SynchronizedList(ActorPool()) { listType = Obj?# }.list.typeof,	Obj?[]#)			
		verifyEq(SynchronizedList(ActorPool()) { listType = Obj?# }.list.of, 		Obj?#)

		verifyEq(SynchronizedList(ActorPool()) { listType = Str?# }.list.typeof,	Str?[]#)			
		verifyEq(SynchronizedList(ActorPool()) { listType = Str?# }.list.of,		Str?#)

		verifyEq(SynchronizedList(ActorPool()) { listType = Int# }.list.typeof,		Int[]#)			
		verifyEq(SynchronizedList(ActorPool()) { listType = Int# }.list.of, 		Int#)
	}
	
	Void testListTypeChecks() {
		list := SynchronizedList(ActorPool()) { listType = Str# }
		
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
