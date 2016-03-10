using build
using afBuild

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

	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		BuildTask(this).run
	}

	@Target { help = "Builds, publishes, and Hg tags a new pod release" }
	Void release() {
		ReleaseTask(this).run
	}
}
