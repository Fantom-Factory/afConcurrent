
internal class TestThreadLocals : Test {
	
	Void testDocumentation() {
		stash1 := ThreadLocals("def")
		stash1["wot"] = "ever"
	 
		stash2 := ThreadLocals("def")
		stash2["wot"] = "banana"

		verifyEq(stash1["wot"], "ever")
		
		stash1["ever"] = "apple"

		verify(stash1.keys.sort[0].endsWith("ever"))
		verify(stash1.keys.sort[1].endsWith("wot"))
		verifyEq(stash1.keys.size, 2)
		
		verify(stash2.keys[0].endsWith("wot"))
		verifyEq(stash2.keys.size, 1)
	}
	
}
