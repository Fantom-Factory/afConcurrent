
internal class TestLocalMap : ConcurrentTest {

	Void testLazyCreation() {
		map := LocalMap("map")
		
		verifyFalse(map.localRef.isMapped)
		map[6] = 9
		verify(map.localRef.isMapped)

		// Not convinced I should remove empty Maps it from Actor.locals?
		// It seems a bit underhand and unexpected - and to what performance gain?
		// And should I also do the same for Atomic and Sync maps?
//		map.clear
//		verifyFalse(map.localRef.isMapped)
	}

	Void testDef() {
		val := LocalMap("map") { it.def = 69 }.get("wotever")
		verifyEq(val, 69)
	}

	Void testOrdered() {
		map := LocalMap("map") { it.ordered = true }
		map[3] = 3
		map[1] = 1
		map[2] = 2
		verifyEq(map.keys, Obj[3, 1, 2])
	}

	Void testCaseInsensitive() {
		map := LocalMap("map") { it.caseInsensitive = true }
		map["wot"] = "ever"
		verifyEq(map["WOT"], "ever")
	}
}
