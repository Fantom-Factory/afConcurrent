
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
	
}

internal class T_Drink {
    LocalRef beer := LocalRef("beer")
}
