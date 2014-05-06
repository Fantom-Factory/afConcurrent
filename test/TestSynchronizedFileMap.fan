using concurrent

internal class TestSynchronizedFileMap : ConcurrentTest {

	private static const AtomicInt	counter := AtomicInt()
	
	Void testGetOrAddOrUpdate() {
		f1 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		f2 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		
		sfm := SynchronizedFileMap(ActorPool(), 100ms)
		
		v1 := sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 0)
		v1 = sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 0)
		v1 = sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 0)

		v2 := sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 1)
		v2 = sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 1)
		v2 = sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 1)
		
		// cater for the FAT32, 2 second rounding
		Actor.sleep(2sec)	
		f1.open.writeChars("Porn!").close
		f2.open.writeChars("Porn!").close

		v1 = sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 2)
		v2 = sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 3)		

		v1 = sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 2)
		v2 = sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 3)		
	}
	
	Void testMapType() {
		verifyEq(SynchronizedFileMap(ActorPool(), 100ms) { valType = Obj?# }.map.typeof,	[File:Obj?]#)			
		verifyEq(SynchronizedFileMap(ActorPool(), 100ms) { valType = Str#  }.map.typeof,	[File:Str]#)
	}
}
