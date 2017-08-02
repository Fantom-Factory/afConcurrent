using concurrent

internal class TestSynchronizedState : ConcurrentTest {

	Void testSync() {
		sync  := SynchronizedState(ActorPool(), T_State#)
		
		val := sync.sync |T_State state -> Obj| { ++state.data }
		verifyEq(val, 1)

		val  = sync.sync |T_State state -> Obj| { ++state.data }
		verifyEq(val, 2)
	}

	Void testAsync() {
		sync  := SynchronizedState(ActorPool(), T_State#)

		val := sync.async |T_State state -> Obj| { ++state.data }.get
		verifyEq(val, 1)

		val  = sync.async |T_State state -> Obj| { ++state.data }.get
		verifyEq(val, 2)
	}
	
	Void testTrap() {
		sync  := SynchronizedState(ActorPool(), T_State#)
		
		// used to throw "Not serializable"
		size := sync->constData
		verifyEq(size->size, 1)
	}
}

internal class T_State {
	Int data
	
	// needs to be a list for the test to fail with a: 
	//    -> sys::IOErr: Not serializable: afConcurrent::T_State2 
	T_State2[] constData() {
		T_State2[T_State2()]
	}
}

internal const class T_State2 {
	const Int data := 69
}
