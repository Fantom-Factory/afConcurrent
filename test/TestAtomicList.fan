
internal class TestAtomicList : ConcurrentTest {
	
	Void testMutableLists() {
		verifyErr(NotImmutableErr#) {
			AtomicList().list = [Buf()]			
		}
	}

	Void testMutableAdd() {
		verifyErr(NotImmutableErr#) {
			AtomicList().add(Buf())			
		}
	}

	Void testListType() {
		verifyEq(AtomicList() { valType = Obj?# }.list.typeof,	Obj?[]#)			
		verifyEq(AtomicList() { valType = Obj?# }.list.of, 		Obj?#)

		verifyEq(AtomicList() { valType = Str?# }.list.typeof,	Str?[]#)			
		verifyEq(AtomicList() { valType = Str?# }.list.of, 		Str?#)

		verifyEq(AtomicList() { valType = Int# }.list.typeof,	Int[]#)			
		verifyEq(AtomicList() { valType = Int# }.list.of, 		Int#)
	}
	
	Void testListTypeChecks() {
		list := AtomicList() { valType = Str# }
		
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
