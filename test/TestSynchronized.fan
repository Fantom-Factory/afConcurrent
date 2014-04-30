using concurrent

internal class TestSynchronized : ConcurrentTest {
	
	Void testNestedSync() {
		verifyErrMsg(Err#, ErrMsgs.synchronized_nestedCallsNotAllowed) {
			T_Sync().sync			
		}
	}

	Void testNestedSyncAndForget() {
		verifyErrMsg(Err#, ErrMsgs.synchronized_nestedCallsNotAllowed) {
			T_Sync().syncForget			
		}
	}
}

internal const class T_Sync : Synchronized {
	new make() : super(ActorPool()) { }
	
	Void sync() {
		synchronized |->| { nested }
	}

	Void syncForget() {
		syncAndForget |->| { nested }
	}

	Void nested() {
		synchronized |->| { null?.toStr }		
	}
}