using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "(Internal) Utility classes for sharing data between threads"
		version = Version("1.0.1")

		meta = [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Concurrent",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afConcurrent",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afconcurrent",
			"license.name"	: "MIT Licence",	
			"repo.private"	: "true",
			
			"tags"			: "system"
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"build 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/internal/`]
		resDirs = [`licence.txt`, `doc/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// test src & res excluded by "stripTest" in etc/build/config.props

		super.compile
		
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)
		
		log.indent
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}
}
