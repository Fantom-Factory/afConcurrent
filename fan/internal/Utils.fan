using concurrent

@Js
internal class Utils {
	
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
	
	static Void checkType(Type? actual, Type expected, Str type) {
		if (actual == null && !expected.isNullable)
			throw ArgErr(wrongType(actual, expected, type))
		if (actual != null && !actual.fits(expected))
			throw ArgErr(wrongType(actual, expected, type))
	}

	static Void checkListType(Type actual, Type expected) {
		if (!actual.params["V"].fits(expected))
			throw ArgErr(wrongType(actual, expected.toListOf, "List"))
	}

	static Void checkMapType(Type actual, Type keyType, Type valType) {
		if (!actual.params["K"].fits(keyType) || !actual.params["V"].fits(valType))
			throw ArgErr(wrongType(actual, Map#.parameterize(["K":keyType, "V":valType]), "Map"))
	}
	
	static Str wrongType(Type? wrong, Type right, Str type) {
		"'${wrong?.signature}' does not fit ${type} type '${right.signature}'".replace("sys::", "")
	}
}
