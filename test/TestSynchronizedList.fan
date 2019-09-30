using concurrent

internal class TestSynchronizedList : ConcurrentTest {
	
	Void testMutableLists() {
		verifyErr(NotImmutableErr#) {
			SynchronizedList(ActorPool()).val = [NotImmutable()]			
		}
	}

	Void testMutableAdd() {
		verifyErr(NotImmutableErr#) {
			SynchronizedList(ActorPool()).add(NotImmutable())			
		}
	}
	
	Void testListType() {
		verifyEq(SynchronizedList(ActorPool()) { valType = Obj?# }.val.typeof,	Obj?[]#)			
		verifyEq(SynchronizedList(ActorPool()) { valType = Obj?# }.val.of, 		Obj?#)

		verifyEq(SynchronizedList(ActorPool()) { valType = Str?# }.val.typeof,	Str?[]#)			
		verifyEq(SynchronizedList(ActorPool()) { valType = Str?# }.val.of,		Str?#)

		verifyEq(SynchronizedList(ActorPool()) { valType = Int# }.val.typeof,	Int[]#)			
		verifyEq(SynchronizedList(ActorPool()) { valType = Int# }.val.of, 		Int#)
	}
	
	Void testListTypeChecks() {
		list := SynchronizedList(ActorPool()) { valType = Str# }
		
		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(Int#, Str#, "List value")) {
			list.add(39)
		}
		
		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(Int[]#, Str[]#, "List")) {
			list.val = Int[,]
		}

		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(null, Str#, "List value")) {
			list.add(null)
		}
	}
}
