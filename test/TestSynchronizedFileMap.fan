using concurrent

internal class TestSynchronizedFileMap : ConcurrentTest {

	private static const AtomicInt	counter := AtomicInt()
	
	Void testGetOrAddOrUpdate() {
		f1 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		f2 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		
		sfm := SynchronizedFileMap(ActorPool(), 100ms)
		
		verify(sfm.isModified(f1))
		verify(sfm.isModified(f2))

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
		
		verifyFalse(sfm.isModified(f1))
		verifyFalse(sfm.isModified(f2))

		// cater for the FAT32, 2 second rounding
		Actor.sleep(2sec)	
		f1.open.writeChars("Porn!").close
		f2.open.writeChars("Porn!").close

		verify(sfm.isModified(f1))
		verify(sfm.isModified(f2))
	
		v1 = sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 2)
		v2 = sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 3)		

		v1 = sfm.getOrAddOrUpdate(f1) { counter.getAndIncrement }
		verifyEq(v1, 2)
		v2 = sfm.getOrAddOrUpdate(f2) { counter.getAndIncrement }
		verifyEq(v2, 3)

		verifyFalse(sfm.isModified(f1))
		verifyFalse(sfm.isModified(f2))
	}
	
	Void testMapType() {
		verifyEq(SynchronizedFileMap(ActorPool(), 100ms) { valType = Obj?# }.val.typeof,	[File:Obj?]#)			
		verifyEq(SynchronizedFileMap(ActorPool(), 100ms) { valType = Str#  }.val.typeof,	[File:Str]#)
	}
	
	Void testMapTypeChecks() {
		map := SynchronizedFileMap(ActorPool(), null) { valType = Str# }
		f1 := File.createTemp("afConcurrent", ".txt").deleteOnExit
		
		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(Int#, Str#, "Map value")) {
			map[f1] = 13
		}

		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(Int#, Str#, "Map value")) {
			map.getOrAdd(f1) { 13 }
		}

		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(Int#, Str#, "Map value")) {
			map.getOrAddOrUpdate(f1) { 13 }
		}

		verifyErrMsg(ArgErr#, ConcurrentUtils.wrongType(null, Str#, "Map value")) {
			map[f1] = null
		}
	}
	
	Void testOnlyCachesIfExists() {
		f1 := `asdf-donotexist-asdf.txt`.toFile
		f2 := File.createTemp("afConcurrent", ".txt").deleteOnExit

		sfm := SynchronizedFileMap(ActorPool(), 100ms)
		
		v1 := sfm.getOrAddOrUpdate(f1) { "File1" }
		v2 := sfm.getOrAddOrUpdate(f2) { "File2" }
		
		verifyEq(v1, "File1")	// return a result as if all went okay
		verifyEq(v2, "File2")
		
		verifyEq(sfm.get(f1), null)
		verifyEq(sfm.get(f2), "File2")

		// now what happens when we delete a file that's already cached!!??
		f2.delete

		// cater for the FAT32, 2 second rounding
		Actor.sleep(2sec)	

		v2 = sfm.getOrAddOrUpdate(f2) { "File2 Again" }
		verifyEq(v2, "File2 Again")
		verifyEq(sfm.get(f2), null)

		verifyEq(sfm.size, 0)
	}
}
