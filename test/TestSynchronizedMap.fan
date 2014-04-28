using concurrent

internal class TestSynchronizedMap : ConcurrentTest {
	
	Void testRemove() {
		cache := SynchronizedMap(ActorPool())
		cache["wot"] = 1
		cache["ever"] = 2
		verifyEq(cache.size, 2)

		cache.remove("wot")
		verifyNull(cache["wot"])
		verifyEq(cache["ever"], 2)
		verifyEq(cache.size, 1)
	}

	Void testClear() {
		cache := SynchronizedMap(ActorPool())
		cache["wot"] = "ever"
		verifyEq(cache.size, 1)
		cache.clear
		verify(cache.isEmpty)
	}

	Void testReplace() {
		cache := SynchronizedMap(ActorPool())
		cache["wot"] = 1
		verifyEq(cache.size, 1)
		
		cache.map = ["ever":2]
		verifyEq(cache["ever"], 2)
		verifyEq(cache.size, 1)
	}

	Void testGetOrAdd() {
		cache := SynchronizedMap(ActorPool())
		cache.getOrAdd("wot") { "ever" }
		verifyEq(cache.size, 1)
		verifyEq(cache["wot"], "ever")
		
		cache.getOrAdd("wot") { "ever" }
		verifyEq(cache.size, 1)
		verifyEq(cache["wot"], "ever")
	}
}
