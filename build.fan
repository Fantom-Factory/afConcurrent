using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "Utility classes for synchronising and sharing data between threads"
		version = Version("1.0.24")

		meta 	= [
			"pod.dis"		: "Concurrent",
			"afIoc.module"	: "afConcurrent::ConcurrentModule",
			"repo.tags"		: "system",
			"repo.public"	: "true",

			// ---- SkySpark ----
//			"ext.name"		: "afConcurrent",
//			"ext.icon"		: "afConcurrent",
////			"ext.depends"	: "",
//			"skyarc.icons"	: "true",
		]
		
//		index	= [
//			"skyarc.ext"	: "afConcurrent"
//		]

		depends = [
			"sys        1.0.69 - 1.0",
			"concurrent 1.0.69 - 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/ioc/`, `test/`]
//		resDirs = [`doc/`, `svg/`]
		resDirs = [`doc/`]
	}
}
