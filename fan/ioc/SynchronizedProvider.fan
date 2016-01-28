
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
		
		if (field.type != Synchronized#)
			return false
		
		return true
	}
	
	Obj? provide(Obj scope, Obj ctx) {
		field		:= (Field?) ctx->field
		injectType	:= Type.find("afIoc::Inject")
		inject 		:= field.facet(injectType)
		poolId		:= inject->id
		
		if (poolId == null)
			throw Err("@Inject.id is not defined for: $field.qname")

		return actorPools[poolId]
	}
}
