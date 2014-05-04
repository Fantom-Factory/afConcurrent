using concurrent

internal class TestCommonListMethods : ConcurrentTest {
	

	Void testAtomicList() {
		doCommonList(AtomicList(), true)
	}

	Void testLocalList() {
		doCommonList(LocalList("localList"), false)
	}

	Void testSynchronizedList() {
		doCommonList(SynchronizedList(ActorPool()), true)
	}
	
	** We don't care so much about list specifics, we just want to exercise the methods to uncover 
	** any potential obvious oversights / typos.
	Void doCommonList(Obj list, Bool rw) {

		// The checklist:
		//  -add
		//  -remove
		//   clear
		
		//  -contains
		//  -each
		//  -get
		//  -isEmpty
		//  -rw
		//  -size
		
		verify(list->isEmpty)
		verifyEq(list->size, 0)
		verifyFalse(list->contains(6))
		list->add(6)
		list->add(9)
		verifyFalse(list->isEmpty)
		verifyEq(list->size, 2)
		verify(list->contains(6))
		verifyEq(list->get(0), 6)
		verifyEq(list->get(1), 9)
		
		list->each |Obj? v, Int i| {
			verifyNotNull(v)
			verifyNotNull(i)
		}
		
		list->remove(6)
		verifyEq(list->get(0), 9)
		verifyEq(list->size, 1)
		if (rw)
			verifyEq(list->rw->size, 1)

		list->clear
		verify(list->isEmpty)

		// null checks
		list->add(null)
		verifyEq(list->size, 1)
		verifyNull(list->get(0))
		verify(list->contains(null))
		list->each |Obj? v, Int i| {
			verifyNull(v)
			verifyNotNull(i)			
		}
	}
	
}
