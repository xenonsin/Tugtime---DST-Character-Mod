local assets =
{ 
    Asset("ANIM", "anim/mask_three.zip"),
    Asset("ANIM", "anim/mask_three_swap.zip"), 

    Asset("ATLAS", "images/inventory/mask_three.xml"),
    Asset("IMAGE", "images/inventory/mask_three.tex"),
}

local prefabs = 
{
	"tugtime"
}

local function turnon(inst)
    inst.Light:Enable(true)
    inst.Light:SetRadius(4)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.7)
    inst.Light:SetColour(245/255,255/255,245/255)
end
 
local function turnoff(inst)

    inst.Light:Enable(false)
end
 
local function ondropped(inst)
    turnoff(inst)   
end
 
local function onpickup(inst)
    turnon(inst)
end
 
local function onputininventory(inst)
    turnoff(inst)
end

local function nofuel(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        owner:PushEvent("torchranout", {torch = inst})
    end
 
    turnoff(inst)
end


local function manageNightVision(inst)
	if TheWorld.state.phase == "day" then
    turnoff(inst)
	elseif TheWorld.state.phase == "night"  and inst.components.equippable:IsEquipped() then
	turnon(inst)
	end
end

local function sanityfnneg(inst)
	return -10
end

local function sanityfnpos(inst)
	return 0
end

local function healowner(inst, owner)
    if (owner.components.health and owner.components.health:IsHurt())then
        owner.components.health:DoDelta(10)
    end
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "mask_three_swap", "swap_hat")
	owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
	manageNightVision(inst)	
 
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end
	--Start consuming fuel
	if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()
        end
    end
	
	--Stop draining sanity
	if owner and owner.components.sanity then
		owner.components.sanity.custom_rate_fn = sanityfnpos
	end
	
	--Increase Max HP
	if owner and owner.components.health then
		owner.components.health:SetMaxHealth(100)
        owner:PushEvent("minhealth")
    
	end
	
	--heal automatically
	--inst.task = inst:DoPeriodicTask(10, healowner, nil, owner)
	

end

local function OnUnequip(inst, owner) 
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
 
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
	
	--Stop Draining fuel.
	if inst.components.fueled then
        inst.components.fueled:StopConsuming()        
    end
	
	--Return Tugtime to his regular sanity rate.
	if owner and owner.components.sanity then
		owner.components.sanity.custom_rate_fn = sanityfnneg
	end
	
	--Decrease Max HP back to regular
	if owner and owner.components.health then
		owner.components.health:SetMaxHealth(50)
		owner:PushEvent("minhealth")
	end
	
	--Cancel all Tasks
	if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
	
	--Turn Off Light
	turnoff(inst)
     
end

local function takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        manageNightVision(inst)
    end
end

local function fn()

    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mask_three")
    inst.AnimState:SetBuild("mask_three")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "mask_three"
    inst.components.inventoryitem.atlasname = "images/inventory/mask_three.xml"
		    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = "CURSED"
	inst.components.fueled:InitializeFuelLevel(4800)
	inst.components.fueled:SetDepletedFn(nofuel)
	inst.components.fueled:SetUpdateFn(manageNightVision)
	inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled.accepting = true
	
    --inst:AddComponent("armor")
    --inst.components.armor:InitCondition(9 * 9999999999, TUNING.ARMORGRASS_ABSORPTION *  0.4)
        
    if not inst.components.characterspecific then
    inst:AddComponent("characterspecific")
	end
 
    inst.components.characterspecific:SetOwner("tugtime")
    inst.components.characterspecific:SetStorable(true)
    inst.components.characterspecific:SetComment("These seem heavier than they look.") 
 

	inst:WatchWorldState( "startday", function(inst) manageNightVision(inst) end )
	inst:WatchWorldState( "startnight", function(inst) manageNightVision(inst) end )
	
    MakeHauntableLaunch(inst)
	
	inst.entity:AddLight()
	inst.Light:SetColour(187/255, 15/255, 23/255)
	manageNightVision(inst)
	
	    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.persists = false

    return inst
end





return  Prefab("common/inventory/mask_three", fn, assets, prefabs)