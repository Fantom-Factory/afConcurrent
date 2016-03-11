using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "Utility classes for sharing data between threads"
		version = Version("1.0.12")

		meta = [
			"proj.name"		: "Concurrent",
			"afIoc.module"	: "afConcurrent::ConcurrentModule",
			"repo.tags"		: "system",
			"repo.public"	: "false"
		]

		depends = [
			"sys        1.0",
			"concurrent 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/ioc/`, `test/`]
		resDirs = [`doc/`]
	}
}
