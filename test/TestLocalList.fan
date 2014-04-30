
internal class TestLocalList : ConcurrentTest {

	Void testLazyCreation() {
		list := LocalList("list")
		
		verifyFalse(list.localRef.isMapped)
		list.add(3)
		verify(list.localRef.isMapped)

		// Not convinced I should remove empty Lists it from Actor.locals?
		// It seems a bit underhand and unexpected - and to what performance gain?
		// And should I also do the same for Atomic and Sync lists?
//		list.clear
//		verifyFalse(list.localRef.isMapped)
	}
	
}
