
internal class TestThreadLocal : Test {
	
	Void testDocumentation() {
		stash1 := ThreadLocalRef("def")
		stash1.val = "ever"
	 
		stash2 := ThreadLocalRef("def")
		stash2.val = "banana"

		verifyEq(stash1.val, "ever")
		verifyEq(stash2.val, "banana")		
	}
	
}
