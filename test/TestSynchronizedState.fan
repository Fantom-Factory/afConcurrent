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
		sync  := SynchronizedState(ActorPool(), Buf#)
		sync.sync |Buf buf| { buf.print("Fanny!") }
		
		size := sync->size
		verifyEq(size, 6)
	}
}

internal class T_State {
	Int data
}

