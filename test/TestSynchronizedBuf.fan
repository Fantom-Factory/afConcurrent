using concurrent::ActorPool

class TestSynchronizedBuf : Test {
	
	Void testSynchronizedBuf() {
		tsBuf	:= SynchronizedBuf(ActorPool())
		in		:= tsBuf.in
		out		:= tsBuf.out
		
		out.write(69)
		byte	:= in.read
		verifyNull(byte)
		
		out.flush
		byte	= in.read
		verifyEq(byte, 69)
		
		out.writeBuf("Hello".toBuf)
		buf		:= Buf()
		size	:= in.readBuf(buf, 4)
		verifyEq(size, 0)
		verifyEq(buf.size, 0)
		
		out.flush
		size	= in.readBuf(buf, 4)
		verifyEq(size, 4)
		verifyEq(buf.flip.readAllStr, "Hell")

		buf.clear
		size	= in.readBuf(buf, 4)
		verifyEq(size, 1)
		verifyEq(buf.flip.readAllStr, "o")
	}
	
}
