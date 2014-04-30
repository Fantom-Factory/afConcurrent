using concurrent

internal class TestSynchronizedState : ConcurrentTest {

	Void testWithState() {
		sync  := SynchronizedState(ActorPool(), T_State#)
		
		val := sync.getState |T_State state -> Obj| { ++state.data }
		verifyEq(val, 1)

		val  = sync.getState |T_State state -> Obj| { ++state.data }
		verifyEq(val, 2)
	}

	Void testGetState() {
		sync  := SynchronizedState(ActorPool(), T_State#)

		val := sync.withState |T_State state -> Obj| { ++state.data }.get
		verifyEq(val, 1)

		val  = sync.withState |T_State state -> Obj| { ++state.data }.get
		verifyEq(val, 2)		
	}

}

internal class T_State {
	Int data
}