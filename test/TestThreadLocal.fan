
internal class TestThreadLocal : Test {
	
	Void testDocumentation() {
		stash1 := LocalRef("def")
		stash1.val = "ever"
	 
		stash2 := LocalRef("def")
		stash2.val = "banana"

		verifyEq(stash1.val, "ever")
		verifyEq(stash2.val, "banana")		
	}
	
}
