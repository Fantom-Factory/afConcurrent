
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
	
	// because local lists and maps tend to be numerous (one per thread!), 
	// try not to create loads of empty ones for useless methods
	Void testLazyLazyCreation() {
		list := LocalList("list")
		verifyFalse(list.localRef.isMapped)
		
		list.clear
		verifyFalse(list.localRef.isMapped)

		verifyFalse(list.contains(6))
		verifyFalse(list.localRef.isMapped)

		list.each { it.toStr }
		verifyFalse(list.localRef.isMapped)
		
		verifyErrMsg(IndexErr#, "0") {
			a := list[0]
		}
		verifyFalse(list.localRef.isMapped)
		
		verify(list.isEmpty)
		verifyFalse(list.localRef.isMapped)

		verifyEq(list.size, 0)
		verifyFalse(list.localRef.isMapped)
	}
	
	Void testListType() {
		verifyEq(LocalList("list") { listType = Obj?# }.list.typeof,	Obj?[]#)			
		verifyEq(LocalList("list") { listType = Obj?# }.list.of, 		Obj?#)

		verifyEq(LocalList("list") { listType = Str?# }.list.typeof,	Str?[]#)			
		verifyEq(LocalList("list") { listType = Str?# }.list.of,		Str?#)

		verifyEq(LocalList("list") { listType = Int# }.list.typeof,		Int[]#)			
		verifyEq(LocalList("list") { listType = Int# }.list.of, 		Int#)
	}
}
