using concurrent

internal class Utils {
	
//	static Obj:Obj? makeMap(Type keyType, Type valType) {
//		mapType := Map#.parameterize(["K":keyType, "V":valType])
//		return keyType.fits(Str#) ? Map.make(mapType) { caseInsensitive = true } : Map.make(mapType) { ordered = true }
//	}
	
	static Log getLog(Type type) {
//		Log.get(type.pod.name + "." + type.name)
		type.pod.log
	}
	
	** A read only copy of the 'Actor.locals' map with the keys sorted alphabetically. Handy for 
	** debugging. Example:
	** 
	**   IocHelper.locals.each |value, key| { echo("$key = $value") }
	** 
	static Str:Obj? locals() {
		Str:Obj? map := [:] { ordered = true }
		Actor.locals.keys.sort.each { map[it] = Actor.locals[it] }
		return map
	}
}
