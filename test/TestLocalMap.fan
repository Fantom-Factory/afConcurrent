
@Js
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

	// because local lists and maps tend to be numerous (one per thread!), 
	// try not to create loads of empty ones for useless methods
	Void testLazyLazyCreation() {
		map := LocalMap("map")
		verifyFalse(map.localRef.isMapped)
		
		map.clear
		verifyFalse(map.localRef.isMapped)

		verifyFalse(map.containsKey(6))
		verifyFalse(map.localRef.isMapped)

		verifyNull(map[6])
		verifyFalse(map.localRef.isMapped)
		
		verify(map.isEmpty)
		verifyFalse(map.localRef.isMapped)

		verify(map.keys.isEmpty)
		verifyFalse(map.localRef.isMapped)

		verifyEq(map.size, 0)
		verifyFalse(map.localRef.isMapped)

		verify(map.vals.isEmpty)
		verifyFalse(map.localRef.isMapped)
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
	
	Void testMapType() {
		verifyEq(LocalMap("map") { keyType = Obj#; valType = Obj?# }.map.typeof,	[Obj:Obj?]#)			
		verifyEq(LocalMap("map") { keyType = Int#; valType = Str?# }.map.typeof,	[Int:Str?]#)			
		verifyEq(LocalMap("map") { keyType = Int#; valType = Str#  }.map.typeof,	[Int:Str]#)
		
		empty := LocalMap("map") { keyType = Int#; valType = Str#  }
		verifyEq(empty.keys.of, Int#)
		verifyEq(empty.vals.of, Str#)
	}
	
	Void testMapTypeChecks() {
		map := LocalMap("map") { keyType = Int#; valType = Str# }
		
		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Str#, Int#, "Map key")) {
			map["str"] = "str"
		}

		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Str#, Int#, "Map key")) {
			map.getOrAdd("str") { "str" }
		}
		
		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Int#, Str#, "Map value")) {
			map[13] = 13
		}

		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Int#, Str#, "Map value")) {
			map.getOrAdd(13) { 13 }
		}
		
		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(Int:Obj#, Int:Str#, "Map")) {
			map.map = Int:Obj[:]
		}

		verifyErrMsg(ArgErr#, ErrMsgs.wrongType(null, Str#, "Map value")) {
			map[13] = null
		}
	}
}
