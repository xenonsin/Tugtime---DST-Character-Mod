local assets =
{
    Asset("ANIM", "anim/cursed_fuel.zip"),
	
	Asset("ATLAS", "images/inventory/cursed_fuel.xml"),
    Asset("IMAGE", "images/inventory/cursed_fuel.tex"),
}
 
local function fn()
    local inst = CreateEntity()
 
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
     
    MakeInventoryPhysics(inst)
 
    inst.AnimState:SetBank("cursed_fuel")
    inst.AnimState:SetBuild("cursed_fuel")
    inst.AnimState:PlayAnimation("idle")
 
    if not TheWorld.ismastersim then
        return inst
    end
 
    inst.entity:SetPristine()
	
    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = "CURSED"
    inst.components.fuel.fuelvalue = 4800

 
    inst:AddComponent("inspectable")
 
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "cursed_fuel"
    inst.components.inventoryitem.atlasname = "images/inventory/cursed_fuel.xml"
     
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
 
    return inst
end
 
return Prefab("common/inventory/cursed_fuel", fn, assets)