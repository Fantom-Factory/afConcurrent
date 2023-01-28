using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "Utility classes for synchronising and sharing data between threads"
		version = Version("1.0.29")

		meta 	= [
			"pod.dis"		: "Concurrent",
			"pod.proj"		: "Fantom Factory Libraries",
			"afIoc.module"	: "afConcurrent::ConcurrentModule",
			"repo.tags"		: "system",
			"repo.public"	: "true",

			// ---- SkySpark ----
			"ext.name"		: "afConcurrent",
			"ext.icon"		: "afConcurrent",
//			"ext.depends"	: "",
			"skyarc.icons"	: "true",
		]

		// this NEEDS to be a SkySpark extension so the pod will be loaded in JS UI Views
		// a requirement for development before we UberPod everything
		index	= [
			"skyarc.ext"	: "afConcurrent"
		]

		depends = [
			"sys        1.0.69 - 1.0",
			"concurrent 1.0.69 - 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/ioc/`, `test/`]
		resDirs = [`doc/`, `svg/`]
	}
}
