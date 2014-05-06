
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
		verifyEq(AtomicList() { listType = Obj?# }.list.typeof, Obj?[]#)			
		verifyEq(AtomicList() { listType = Obj?# }.list.of, 	Obj?#)

		verifyEq(AtomicList() { listType = Str?# }.list.typeof, Str?[]#)			
		verifyEq(AtomicList() { listType = Str?# }.list.of, 	Str?#)

		verifyEq(AtomicList() { listType = Int# }.list.typeof,	Int[]#)			
		verifyEq(AtomicList() { listType = Int# }.list.of, 		Int#)
	}
}
