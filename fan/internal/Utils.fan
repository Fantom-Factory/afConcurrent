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
			throw ArgErr(ErrMsgs.wrongType(actual, expected, type))
		if (actual != null && !actual.fits(expected))
			throw ArgErr(ErrMsgs.wrongType(actual, expected, type))
	}

	static Void checkListType(Type actual, Type expected) {
		if (!actual.params["V"].fits(expected))
			throw ArgErr(ErrMsgs.wrongType(actual, expected.toListOf, "List"))
	}

	static Void checkMapType(Type actual, Type keyType, Type valType) {
		if (!actual.params["K"].fits(keyType) || !actual.params["V"].fits(valType))
			throw ArgErr(ErrMsgs.wrongType(actual, Map#.parameterize(["K":keyType, "V":valType]), "Map"))
	}
}
