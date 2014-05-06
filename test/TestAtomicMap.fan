
internal class TestAtomicMap : ConcurrentTest {

	Void testDef() {
		val := AtomicMap() { it.def = 69 }.get("wotever")
		verifyEq(val, 69)
	}

	Void testOrdered() {
		map := AtomicMap() { it.ordered = true }
		map[3] = 3
		map[1] = 1
		map[2] = 2
		verifyEq(map.keys, Obj[3, 1, 2])
	}

	Void testCaseInsensitive() {
		map := AtomicMap() { it.caseInsensitive = true }
		map["wot"] = "ever"
		verifyEq(map["WOT"], "ever")
	}

	Void testMutableMap() {
		verifyErr(NotImmutableErr#) {
			AtomicMap().map = [0:Buf()]			
		}
	}

	Void testMutableSet() {
		verifyErr(NotImmutableErr#) {
			AtomicMap()[0] = Buf()			
		}
	}

	Void testMutableGetOrAdd() {
		verifyErr(NotImmutableErr#) {
			AtomicMap().getOrAdd(0) { Buf() }			
		}

		// allowed 'cos the func need not be mutable
		AtomicMap().getOrAdd(0) { datum }
	}
	
	Void testMapType() {
		verifyEq(AtomicMap() { keyType = Obj#; valType = Obj?# }.map.typeof,	[Obj:Obj?]#)			
		verifyEq(AtomicMap() { keyType = Int#; valType = Str?# }.map.typeof,	[Int:Str?]#)			
		verifyEq(AtomicMap() { keyType = Int#; valType = Str#  }.map.typeof,	[Int:Str]#)
		
		// interesting - an nullable key type! 
		verifyEq(AtomicMap() { keyType = Int?#; valType = Str# }.map.typeof.params["K"], Int?#)
	}

	private Obj datum() { 69 }
}
