using concurrent

internal class TestSynchronized : ConcurrentTest {
	
	private static const AtomicList logs := AtomicList()
	private static const |LogRec rec| handler := |LogRec rec| { logs.add(rec) }
	
	override Void setup() {
		logs.clear
		Log.addHandler(handler)
	}
	
	override Void teardown() {
		Log.removeHandler(handler)		
	}
	
	Void testNestedSync() {
		pool := ActorPool()
		verifyErrMsg(Err#, ErrMsgs.synchronized_nestedCallsNotAllowed) {
			T_Sync(pool).sync			
		}
		verify(logs.isEmpty)
	}

	Void testNestedAsync() {
		pool := ActorPool()
		
		T_Sync(pool).syncForget
		
		pool.stop.join
		rec := logs[0] as LogRec
		verifyEq(rec.msg, ErrMsgs.synchronized_silentErr)
		verifyEq(rec.err.msg, ErrMsgs.synchronized_nestedCallsNotAllowed)
	}
	
	Void testErrsInSyncAreRethrown() {
		lock := Synchronized(ActorPool())
		verifyErrMsg(Err#, "Whoops! -> synchronized") {
			lock.synchronized |->| {
				throw Err("Whoops! -> synchronized")
			}
		}
		verify(logs.isEmpty)
	}

	Void testErrsInAsyncAreLogged() {
		pool := ActorPool()
		lock := Synchronized(pool)
		
		lock.async |->| {
			throw Err("Whoops! -> syncAndForget")
		}
		
		pool.stop.join
		rec := logs[0] as LogRec
		verifyEq(rec.msg, ErrMsgs.synchronized_silentErr)
		verifyEq(rec.err.msg, "Whoops! -> syncAndForget")
	}
	
	Void testImmutableReturnValue() {
		lock := Synchronized(ActorPool())
		verifyErrMsg(IOErr#, ErrMsgs.synchronized_notImmutable(Buf#)) {
			lock.synchronized |->Buf| { Buf() }
		}
		verify(logs.isEmpty)
		
		// test sync msg doesn't hide other IOErrs
		verifyErrMsg(IOErr#, "Batman") {
			lock.synchronized |->Buf| { throw IOErr("Batman") }
		}
	}

	Void testTimeout() {
		lock := Synchronized(ActorPool(), 50ms)
		verifyErrMsg(TimeoutErr#, "Future.get timed out") {
			lock.synchronized |->| { Actor.sleep(1sec) }
		}
		verify(logs.isEmpty)
	}

}

internal const class T_Sync : Synchronized {
	new make(ActorPool pool) : super(pool) { }
	
	Void sync() {
		synchronized |->| { nested }
	}

	Void syncForget() {
		async |->| { nested }
	}

	Void nested() {
		synchronized |->| { null?.toStr }		
	}
}