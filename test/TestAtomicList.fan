
@Js
internal class TestAtomicList : ConcurrentTest {
	
	Void testMutableLists() {
		verifyErr(NotImmutableErr#) {
			AtomicList().val = [Buf()]			
		}
	}

	Void testMutableAdd() {
		verifyErr(NotImmutableErr#) {
			AtomicList().add(Buf())			
		}
	}

	Void testListType() {
		verifyEq(AtomicList() { valType = Obj?# }.val.typeof,	Obj?[]#)			
		verifyEq(AtomicList() { valType = Obj?# }.val.of, 		Obj?#)

		verifyEq(AtomicList() { valType = Str?# }.val.typeof,	Str?[]#)			
		verifyEq(AtomicList() { valType = Str?# }.val.of, 		Str?#)

		verifyEq(AtomicList() { valType = Int# }.val.typeof,	Int[]#)			
		verifyEq(AtomicList() { valType = Int# }.val.of, 		Int#)
	}
	
	Void testListTypeChecks() {
		list := AtomicList() { valType = Str# }
		
		verifyErrMsg(ArgErr#, Utils.wrongType(Int#, Str#, "List value")) {
			list.add(39)
		}
		
		verifyErrMsg(ArgErr#, Utils.wrongType(Int[]#, Str[]#, "List")) {
			list.val = Int[,]
		}

		verifyErrMsg(ArgErr#, Utils.wrongType(null, Str#, "List value")) {
			list.add(null)
		}
	}
}
