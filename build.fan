using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "(Internal) Utility classes for sharing data between threads"
		version = Version("0.0.2")

		meta = [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Concurrent",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afConcurrent",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afconcurrent",
			"license.name"	: "MIT Licence",	
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/internal/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }

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
