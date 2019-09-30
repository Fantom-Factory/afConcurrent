
@Js
internal class TestBase64 : Test {
	
	Void testToBase64() {
		verifyEq(toBase64(0), "0")
		verifyEq(toBase64(1), "1")
		verifyEq(toBase64(2), "2")
		verifyEq(toBase64(3), "3")
		
		verifyEq(toBase64(10), "A")
		verifyEq(toBase64(11), "B")
		verifyEq(toBase64(12), "C")

		verifyEq(toBase64(64), "10")
		verifyEq(toBase64(65), "11")
		verifyEq(toBase64(66), "12")

		verifyEq(toBase64(74), "1A")
		verifyEq(toBase64(75), "1B")
		verifyEq(toBase64(76), "1C")

		// Javascript Ints aren't as big as Java's!
		verifyEq(toBase64(5293177106265578496), "4br98YWC9m0")
		verifyEq(toBase64(Int.maxVal), Env.cur.runtime == "js" ? "W00000000" : "7__________")
	}
	
	Void testFromBase64() {
		verifyEq(fromBase64("0000"), 0)
		verifyEq(fromBase64("0001"), 1)
		verifyEq(fromBase64("0002"), 2)

		// Javascript Ints aren't as big as Java's!
		verifyEq(fromBase64("4br98YWC9m0"), 5293177106265578496)
		verifyEq(fromBase64(Env.cur.runtime == "js" ? "W00000000" : "7__________"), Int.maxVal)
	}
	
	private Str toBase64(Int int, Int pad := 1) {
		ConcurrentBase64.toBase64(int, pad)
	}
	
	private Int fromBase64(Str b64) {
		ConcurrentBase64.fromBase64(b64)
	}
}
