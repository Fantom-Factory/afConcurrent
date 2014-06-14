using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "Utility classes for sharing data between threads"
		version = Version("1.0.6")

		meta = [
			"proj.name"		: "Concurrent",
			"internal"		: "true",
			"tags"			: "system",
			"repo.private"	: "false"		
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/internal/`]
		resDirs = [,]
	}
}
