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
	
	Void testNestingSyncInsideSync() {
		pool := ActorPool()
		verifyErrMsg(Err#, ErrMsgs.synchronized_nestedCallsNotAllowed) {
			T_Sync(pool) { it.reentrant = false }.syncToSync			
		}
		verify(logs.isEmpty)
	}

	Void testNestingSyncInsideSyncReentrant() {
		pool := ActorPool()
		tada := T_Sync(pool).syncToSync
		verifyEq(tada, "Ta daa!")
		verify(logs.isEmpty)
	}

	Void testNestingSyncInsideAsync() {
		pool := ActorPool()
		
		T_Sync(pool) { it.reentrant = false }.asyncToSync
		
		pool.stop.join
		rec := logs[0] as LogRec
		verifyEq(rec.msg, ErrMsgs.synchronized_silentErr)
		verifyEq(rec.err.msg, ErrMsgs.synchronized_nestedCallsNotAllowed)
	}

	Void testNestingSyncInsideAsyncReentrant() {
		pool := ActorPool()
		
		T_Sync(pool).asyncToSync
		
		pool.stop.join
		verify(logs.isEmpty)
	}

	Void testNestedAsyncInsideAsyncIsOkay() {
		pool := ActorPool()
		
		sync := T_Sync(pool)
		sync.asyncToAsync
		Actor.sleep(100ms)
		pool.stop.join

		verifyEq(sync.asyncDone.val, "DONE")
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
		verifyErrMsg(NotImmutableErr#, ErrMsgs.synchronized_notImmutable(T_State#)) {
			lock.synchronized |->Obj| { T_State() }
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
			lock.synchronized |->| { Actor.sleep(100ms) }
		}
		verify(logs.isEmpty)
	}

	Void testInSync() {
		lock := Synchronized(ActorPool())
		verifyFalse(lock.inSync)
		
		wasInSync := lock.synchronized |->Bool| { lock.inSync }
		verify(wasInSync)
	}
}

internal const class T_Sync : Synchronized {
	new make(ActorPool pool, |This|? in := null) : super(pool, null, in) { }
	const AtomicRef asyncDone	:= AtomicRef() 
	
	Str syncToSync() {
		synchronized |->Str| { syncAgain }
	}

	Void asyncToSync() {
		async |->| { syncAgain }
	}

	Void asyncToAsync() {
		async |->| { asyncAgain }
	}

	Str syncAgain() {
		synchronized |->Str| { "Ta daa!" }		
	}

	Void asyncAgain() {
		async |->| { asyncDone.val = "DONE" }		
	}
}