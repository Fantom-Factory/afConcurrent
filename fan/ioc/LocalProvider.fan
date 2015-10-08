
internal const class LocalRefProvider {

	static	private const Type[]			localTypes		:= [LocalRef#, LocalList#, LocalMap#]	
			private const LocalRefManager	localManager

	new make(LocalRefManager localManager) {
		this.localManager = localManager 
	}

	Bool canProvide(Obj scope, Obj ctx) {
		// IoC standards dictate that field injection should be denoted by a facet
		injectType	:= Type.find("afIoc::Inject")
		if (ctx->isFieldInjection && !ctx->field->hasFacet(injectType))
			return false
		dependencyType := ctx->field?->type ?: ctx->funcParam?->type
		return localTypes.contains(dependencyType->toNonNullable) && ctx->targetType != null
	}
	
	Obj? provide(Obj scope, Obj ctx) {
		type := (ctx->field?->type ?: ctx->funcParam?->type)?->toNonNullable
		name := (ctx->targetType->qname->replace("::", ".")).toStr
		if (ctx->field != null)
			name += "." + (ctx->field->name)?.toStr
		if (ctx->funcParam != null)
			name += "." + (ctx->funcParam->name)?.toStr
		
		// let @Inject.id override the default name
		injectType	:= Type.find("afIoc::Inject")
		inject		:= ctx->field->facets->findType(injectType)->first
		if (inject?->id != null)
			name = inject->id 
		
		if (type == LocalRef#)
			return localManager.createRef(name)

		if (type == LocalList#) {
			listType := (Type?) inject?->type
			if (listType == null)
				return localManager.createList(name)

			if (listType.params["L"] == null)
				throw Err(localProvider_typeNotList(ctx->field, listType))
			return LocalList(localManager.createName(name)) {
				it.valType = listType.params["V"]
			} 
		}

		if (type == LocalMap#) {
			mapType := (Type?) inject?->type
			if (mapType == null)
				return localManager.createMap(name)

			if (mapType.params["M"] == null)
				throw Err(localProvider_typeNotMap(ctx->field, mapType))

			return LocalMap(localManager.createName(name)) {
				it.keyType = mapType.params["K"]
				it.valType = mapType.params["V"]
				if (it.keyType == Str#)
					it.caseInsensitive = true
				else
					it.ordered = true
			} 
		}

		throw Err("What's a {$type->qname}???")
	}
	
	static Str localProvider_typeNotList(Field field, Type type) {
		"@Inject { type=${type.signature}# } on field ${field.qname} should be a list type, e.g. @Inject { type=Str[]# }"
	}

	static Str localProvider_typeNotMap(Field field, Type type) {
		"@Inject { type=${type.signature}# } on field ${field.qname} should be a map type, e.g. @Inject { type=[Int:Str]# }"
	}
}
