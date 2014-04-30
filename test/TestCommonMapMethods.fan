using concurrent

class Drink {
    Str beer {
		get { Actor.locals["beer"] }
		set { Actor.locals["beer"] = it }
    }
}

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
		//  getOrAdd
		//  -set
		//  -clear
		//  -remove
		//  -get
		//  -containsKey
		//  keys
		//  vals
		//  -isEmpty
		//  -size
		
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
		
//		map->each |Obj? v, Int i| {
//			verifyNotNull(v)
//			verifyNotNull(i)
//		}
		
		map->remove(6)
		verifyEq(map->get(6), null)
		verifyEq(map->get("wot"), "ever")
		verifyEq(map->size, 1)

		map->clear
		verify(map->isEmpty)

		// null checks
//		map->add(null)
//		verifyEq(map->size, 1)
//		verifyNull(map->get(0))
//		verify(map->contains(null))
//		map->each |Obj? v, Int i| {
//			verifyNull(v)
//			verifyNotNull(i)			
//		}
	}
	
}
