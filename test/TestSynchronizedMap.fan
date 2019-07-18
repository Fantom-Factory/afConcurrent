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
			SynchronizedMap(ActorPool()).val = [0:NotImmutable()]			
		}
	}

	Void testMutableSet() {
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool())[0] = NotImmutable()			
		}
	}

	Void testMutableGetOrAdd() {
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool()).getOrAdd(0) { NotImmutable() }			
		}

		// funcs need be to immutable too
		verifyErr(NotImmutableErr#) {
			SynchronizedMap(ActorPool()).getOrAdd(0) { datum }
		}
		
		// allow nulls to be added - surprisingly, 'null.toImmutable' doesn't throw an Err!
		SynchronizedMap(ActorPool()).getOrAdd(69) { null }		
	}
	private Obj datum() { 69 }
	
	Void testMapType() {
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Obj#; valType = Obj?# }.val.typeof,	[Obj:Obj?]#)			
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Int#; valType = Str?# }.val.typeof,	[Int:Str?]#)			
		verifyEq(SynchronizedMap(ActorPool()) { keyType = Int#; valType = Str#  }.val.typeof,	[Int:Str]#)
	}
	
	Void testMapTypeChecks() {
		map := SynchronizedMap(ActorPool()) { keyType = Int#; valType = Str# }
		
		verifyErrMsg(ArgErr#, Utils.wrongType(Str#, Int#, "Map key")) {
			map["str"] = "str"
		}

		verifyErrMsg(ArgErr#, Utils.wrongType(Str#, Int#, "Map key")) {
			map.getOrAdd("str") { "str" }
		}
		
		verifyErrMsg(ArgErr#, Utils.wrongType(Int#, Str#, "Map value")) {
			map[13] = 13
		}

		verifyErrMsg(ArgErr#, Utils.wrongType(Int#, Str#, "Map value")) {
			map.getOrAdd(13) { 13 }
		}
		
		verifyErrMsg(ArgErr#, Utils.wrongType(Int:Obj#, Int:Str#, "Map")) {
			map.val = Int:Obj[:]
		}

		verifyErrMsg(ArgErr#, Utils.wrongType(null, Str#, "Map value")) {
			map[13] = null
		}
	}
}
