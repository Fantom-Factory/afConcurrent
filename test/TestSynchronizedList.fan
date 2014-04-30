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
}
