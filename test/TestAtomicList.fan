
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
}
