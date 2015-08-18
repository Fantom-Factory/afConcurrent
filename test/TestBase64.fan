
@Js
internal class TestBase64 : Test {
	
	Void testToBase64() {
		verifyEq(Base64.toBase64(0), "0")
		verifyEq(Base64.toBase64(1), "1")
		verifyEq(Base64.toBase64(2), "2")
		verifyEq(Base64.toBase64(3), "3")
		
		verifyEq(Base64.toBase64(10), "A")
		verifyEq(Base64.toBase64(11), "B")
		verifyEq(Base64.toBase64(12), "C")

		verifyEq(Base64.toBase64(64), "10")
		verifyEq(Base64.toBase64(65), "11")
		verifyEq(Base64.toBase64(66), "12")

		verifyEq(Base64.toBase64(74), "1A")
		verifyEq(Base64.toBase64(75), "1B")
		verifyEq(Base64.toBase64(76), "1C")

		// TODO: Javascript Ints don't get this big!
		verifyEq(Base64.toBase64(5293177106265578783), "4br98YWC9qV")
		verifyEq(Base64.toBase64(Int.maxVal), "7__________")
	}
	
	Void testFromBase64() {
		verifyEq(Base64.fromBase64("0000"), 0)
		verifyEq(Base64.fromBase64("0001"), 1)
		verifyEq(Base64.fromBase64("0002"), 2)

		// TODO: Javascript Ints don't get this big!
		verifyEq(Base64.fromBase64("4br98YWC9qV"), 5293177106265578783)
		verifyEq(Base64.fromBase64("7__________"), Int.maxVal)
	}
}
