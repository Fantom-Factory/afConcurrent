
internal class TestLocalRef : Test {
	
	Void testDocumentation() {
		man := T_Drink()
		man.beer.val = "Ale"
		
		kid := T_Drink()
		kid.beer.val = "Ginger Ale"
		
		verifyEq("Ale", man.beer.val)		   // --> Ale
		verifyEq("Ginger Ale", kid.beer.val)   // --> Ginger Ale
		
		verify(man.beer.qname.endsWith(".beer")) // --> 0001.beer
		verify(kid.beer.qname.endsWith(".beer")) // --> 0002.beer
	}
	
	Void testInitValue() {
		ref := LocalRef("init", 0)
		verify(ref.isMapped)
		
		ref.cleanUp
		verifyFalse(ref.isMapped)
	}

	Void testNuffinSetByDefault() {
		ref := LocalRef("init", null)
		verifyFalse(ref.isMapped)

		ref.val = 0
		verify(ref.isMapped)
		
		ref.cleanUp
		verifyFalse(ref.isMapped)
	}
}

internal class T_Drink {
    LocalRef beer := LocalRef("beer")
}
