using concurrent

internal class TestCommonMapMethods : ConcurrentTest {

	Void testAtomicMap() {
		doCommonMap(AtomicMap())
	}

	Void testLocalMap() {
		doCommonMap(LocalMap("localMap"))
	}

	Void testSynchronizedMap() {
		doCommonMap(SynchronizedMap(ActorPool()))
	}
	
	** We don't care so much about list specifics, we just want to exercise the methods to uncover 
	** any potential obvious oversights / typos.
	Void doCommonMap(Obj map) {

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
		verifyFalse(map->containsKey(6))
		map->set(6, 9)
		map->set("wot", "ever")
		verifyFalse(map->isEmpty)
		verifyEq(map->size, 2)
		verify(map->containsKey(6))
		verify(map->containsKey("wot"))
		verifyEq(map->get(6), 9)
		verifyEq(map->get("wot"), "ever")
		
		verifyEq(map->getOrAdd("ping", |->Str| { "pong" }), "pong")
		verifyEq(map->getOrAdd("ping", |->Str| { "pong" }), "pong")
		verifyEq(map->get("ping"), "pong")
		
		map->keys->each |Obj? v, Int i| {
			verifyNotNull(v)
			verifyNotNull(i)
		}
		map->vals->each |Obj? v, Int i| {
			verifyNotNull(v)
			verifyNotNull(i)
		}
		
		map->remove(6)
		verifyEq(map->get(6), null)
		verifyEq(map->get("wot"), "ever")
		verifyEq(map->size, 2)
		verifyEq(map->rw->size, 2)

		map->clear
		verify(map->isEmpty)

		// null checks
		map->set("nul", null)
		verifyNull(map->get("nul"))
		verifyEq(map->getOrAdd("nul2", |->Str?| { null }), null)
		verifyEq(map->getOrAdd("nul2", |->Str?| { null }), null)
		verify(map->containsKey("nul2"))
		map->vals->each |Obj? v, Int i| {
			verifyNull(v)
			verifyNotNull(i)			
		}
	}
	
}
