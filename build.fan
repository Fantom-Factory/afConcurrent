using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "Utility classes for synchronising and sharing data between threads"
		version = Version("1.0.17")

		meta = [
			"pod.displayName"	: "Concurrent",
			"afIoc.module"		: "afConcurrent::ConcurrentModule",
			"repo.tags"			: "system",
			"repo.public	"	: "true"
		]

		depends = [
			"sys        1.0.67 - 1.0",
			"concurrent 1.0.67 - 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/ioc/`, `test/`]
		resDirs = [`doc/`]
	}
}
