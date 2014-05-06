using concurrent

internal class TestSynchronizedMap : ConcurrentTest {

	Void testDef() {
		val := SynchronizedMap(ActorPool()) { it.def = 69 }.get("wotever")
		verifyEq(val, 69)
	}

	Void testOrdered() {
		map := SynchronizedMap(ActorPool()) { it.ordered = true }
		map[3] = 3
		map[1] = 1
		map[2] = 2
		verifyEq(map.keys, Obj[3, 1, 2])
	}

	Void testCaseInsensitive() {
		map := SynchronizedMap(ActorPool()) { it.caseInsensitive = true }
		map["wot"] = "ever"
		verifyEq(map["WOT"], "ever")
	}

	Void testMutableMap() {
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool()).map = [0:Buf()]			
		}
	}

	Void testMutableSet() {
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool())[0] = Buf()			
		}
	}

	Void testMutableGetOrAdd() {
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool()).getOrAdd(0) { Buf() }			
		}

		// funcs need be to immutable too
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool()).getOrAdd(0) { datum }
		}
	}
	
	Void testMapType() {
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Obj#; valType = Obj?# }.map.typeof,	[Obj:Obj?]#)			
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Int#; valType = Str?# }.map.typeof,	[Int:Str?]#)			
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Int#; valType = Str#  }.map.typeof,	[Int:Str]#)
		
		// interesting - an nullable key type! 
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Int?#; valType = Str# }.map.typeof.params["K"], Int?#)
	}
	
	private Obj datum() { 69 }
}
