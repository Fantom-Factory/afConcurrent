
internal const class SynchronizedProvider {

	private const ActorPools	actorPools

	new make(ActorPools actorPools) {
		this.actorPools = actorPools 
	}

	Bool canProvide(Obj scope, Obj ctx) {
		field		:= (Field?) ctx->field
		injectType	:= Type.find("afIoc::Inject")

		if (ctx->isFieldInjection->not)
			return false
		
		if (field.hasFacet(injectType).not)
			return false
		
		type := field.type.toNonNullable
		if (type != Synchronized# && type != SynchronizedList# && type != SynchronizedMap#)
			return false
		
		return true
	}
	
	Obj? provide(Obj scope, Obj ctx) {
		field		:= (Field?) ctx->field
		injectType	:= Type.find("afIoc::Inject")
		inject 		:= field.facet(injectType)
		poolId		:= inject->id
		type		:= field.type.toNonNullable
		
		if (poolId == null)
			throw Err("@Inject.id is not defined for: $field.qname")
		actorPool := actorPools[poolId]

		if (type == Synchronized#)
			return Synchronized(actorPool)
		
		if (type == SynchronizedList#) {
			listType := (Type?) inject?->type
			if (listType == null)
				return SynchronizedList(actorPool)

			if (listType.params["L"] == null)
				throw Err(msg_typeNotList(field, listType))
			return SynchronizedList(actorPool) {
				it.valType = listType.params["V"]
			} 
		}

		if (type == SynchronizedMap#) {
			mapType := (Type?) inject?->type
			if (mapType == null)
				return SynchronizedMap(actorPool)

			if (mapType.params["M"] == null)
				throw Err(msg_typeNotMap(field, mapType))

			return SynchronizedMap(actorPool) {
				it.keyType = mapType.params["K"]
				it.valType = mapType.params["V"]
				if (it.keyType == Str#)
					it.caseInsensitive = true
				else
					it.ordered = true
			} 
		}
		
		throw Err("What's a ${type.qname}???")
	}
	
	static Str msg_typeNotList(Field field, Type type) {
		"@Inject { type=${type.signature}# } on field ${field.qname} should be a list type, e.g. @Inject { type=Str[]# }"
	}

	static Str msg_typeNotMap(Field field, Type type) {
		"@Inject { type=${type.signature}# } on field ${field.qname} should be a map type, e.g. @Inject { type=[Int:Str]# }"
	}

}
