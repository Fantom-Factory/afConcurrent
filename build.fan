using build

class Build : BuildPod {

	new make() {
		podName = "afConcurrent"
		summary = "(Internal) Utility classes for sharing data between threads"
		version = Version("1.0.3")

		meta = [
			"proj.name"		: "Concurrent",
			"tags"			: "system",
			"repo.private"	: "true"		
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/internal/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
