using concurrent

internal class TestCommonMapMethods : ConcurrentTest {

	Void testAtomicMap() {
		doCommonMap(AtomicMap(), ["wot", 6, "ping", "nul", "nul2"])
	}

	Void testLocalMap() {
		doCommonMap(LocalMap("localMap"), ["wot", 6, "ping", "nul", "nul2"])
	}

	Void testSynchronizedMap() {
		doCommonMap(SynchronizedMap(ActorPool()), ["wot", 6, "ping", "nul", "nul2"])
	}

	Void testSynchronizedFileMap() {
		f1 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		f2 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		f3 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		f4 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		f5 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		doCommonMap(SynchronizedFileMap(ActorPool()), [f1, f2, f3, f4, f5])
	}
	
	** We don't care so much about list specifics, we just want to exercise the methods to uncover 
	** any potential obvious oversights / typos.
	Void doCommonMap(Obj map, Obj[] key) {
		wot := key[0]; six := key[1]; ping := key[2]; nul := key[3]; nul2 := key[4]
		
		// The checklist:
		//  -getOrAdd
		//  -set
		//  -clear
		//  -remove
		
		//  -containsKey
		//  -get
		//  -isEmpty
		//  -keys
		//  -rw
		//  -size
		//  -vals

		verify(map->isEmpty)
		verifyEq(map->size, 0)
		verifyFalse(map->containsKey(ping))
		map->set(six, 9)
		map->set(wot, "ever")
		verifyFalse(map->isEmpty)
		verifyEq(map->size, 2)
		verify(map->containsKey(six))
		verify(map->containsKey(wot))
		verifyEq(map->get(six), 9)
		verifyEq(map->get(wot), "ever")
		
		verifyEq(map->getOrAdd(ping, |->Str| { "pong" }), "pong")
		verifyEq(map->getOrAdd(ping, |->Str| { "pong" }), "pong")
		verifyEq(map->get(ping), "pong")
		
		map->keys->each |Obj? v, Int i| {
			verifyNotNull(v)
			verifyNotNull(i)
		}
		map->vals->each |Obj? v, Int i| {
			verifyNotNull(v)
			verifyNotNull(i)
		}
		
		map->remove(six)
		verifyEq(map->get(six), null)
		verifyEq(map->get(wot), "ever")
		verifyEq(map->size, 2)
		verifyEq(map->rw->size, 2)

		map->clear
		verify(map->isEmpty)

		// null checks
		map->set(nul, null)
		verifyNull(map->get(nul))
		verifyEq(map->getOrAdd(nul2, |->Str?| { null }), null)
		verifyEq(map->getOrAdd(nul2, |->Str?| { null }), null)
		verify(map->containsKey(nul2))
		map->vals->each |Obj? v, Int i| {
			verifyNull(v)
			verifyNotNull(i)			
		}
	}
	
}
