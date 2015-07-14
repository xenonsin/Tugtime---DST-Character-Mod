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
    if not inst.components.expirable:IsEmpty() then
		local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
		if inst._light == nil or not inst._light:IsValid() then
			inst._light = SpawnPrefab("nightvision")
		end		
		
		inst._light.entity:SetParent((owner or inst).entity)
		--inst._light.Transform:SetPosition(0,2,0)
	end
end
 
local function turnoff(inst)

	if inst._light ~= nil then
        if inst._light:IsValid() then

            inst._light:Remove()
        end
        inst._light = nil
    end
end

local function fuelupdate(inst)
		if TheWorld.state.phase == "day" then
			if inst._light ~= nil then
				turnoff(inst)
			end
		elseif TheWorld.state.phase == "dusk" or TheWorld.state.phase == "night" then
				turnon(inst)
			
		end

	
end
 
local function OnRemove(inst)
    if inst._light ~= nil and inst._light:IsValid() then
        inst._light:Remove()
    end
end
 
local function ondropped(inst)
    turnoff(inst)
end

local function nofuel(inst)
	local equippable = inst.components.equippable
	if equippable ~= nil and equippable:IsEquipped() then
		local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
		if owner ~= nil then
			local data =
				{
					prefab = inst.prefab,
					equipslot = equippable.equipslot,
				}
			turnoff(inst)
			owner:PushEvent("torchranout", {torch = inst})
			return
		end
    end
	turnoff(inst)
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
 
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end
	--Start consuming fuel
	--if owner ~= nil and inst.components.equippable:IsEquipped() then
	--	if inst.components.fueled ~= nil then
	--			inst.components.fueled:StartConsuming()
	--	end
	--end
	
	--Stop draining sanity
	if owner and owner.components.sanity then
		owner.components.sanity.custom_rate_fn = sanityfnpos
	end
	
	--Give the sanity Aura boost
	if owner and owner.components.sanityaura then
		owner.components.sanityaura.aura = 3
	end
	
	--Increase Max HP
	--if owner and owner.components.health then
		--owner.components.health:SetMaxHealth(100)
        --We do this to trigger the GUI update.
		--owner.components.health:DoDelta(0)
	--end
	
	--heal automatically
	--inst.task = inst:DoPeriodicTask(10, healowner, nil, owner)
	
	fuelupdate(inst)
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
	--if inst.components.fueled then
    --    inst.components.fueled:StopConsuming()        
    --end
	
	--Return Tugtime to his regular sanity rate.
	if owner and owner.components.sanity then
		owner.components.sanity.custom_rate_fn = sanityfnneg
	end
	
	--Decrease Max HP back to regular
	--if owner and owner.components.health then
		--owner.components.health:SetMaxHealth(50)
		--We do this to trigger the GUI update.
		--owner.components.health:DoDelta(0)
	--end
	
	--Give the sanity Aura boost
	if owner and owner.components.sanityaura then
		owner.components.sanityaura.aura = 0
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
        turnon(inst)
    end
end

local function nightvisionfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetColour(245/255,255/255,245/255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
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
	
	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    --inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "mask_three"
    inst.components.inventoryitem.atlasname = "images/inventory/mask_three.xml"
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)
		    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	--inst:AddComponent("fueled")
	--inst.components.fueled.fueltype = "CURSED"
	--inst.components.fueled:InitializeFuelLevel(2400)
	--inst.components.fueled:SetDepletedFn(nofuel)
	--inst.components.fueled:SetUpdateFn(fuelupdate)
	--inst.components.fueled.ontakefuelfn = takefuel
	--inst.components.fueled.accepting = true
	
	inst:AddComponent("expirable")
    inst.components.expirable:InitializeFuelLevel(2400)
    inst.components.expirable:SetDepletedFn(--[[generic_perish]]inst.Remove)
	inst.components.expirable:SetUpdateFn(fuelupdate)
	inst.components.expirable:StartConsuming()
	
	--Sanity Aura. Negative value for insanity aura.
	--inst:AddComponent("sanityaura")
    --inst.components.equippable.sanityaura.aura = 8
	
    --inst:AddComponent("armor")
    --inst.components.armor:InitCondition(9 * 9999999999, TUNING.ARMORGRASS_ABSORPTION *  0.4)
        
    if not inst.components.characterspecific then
    inst:AddComponent("characterspecific")
	end
 
    inst.components.characterspecific:SetOwner("tugtime")
    inst.components.characterspecific:SetStorable(true)
    inst.components.characterspecific:SetComment("It's too creepy looking.") 
 
	inst._light = nil
    MakeHauntableLaunch(inst)
	inst.OnRemoveEntity = OnRemove

    return inst
end





return  Prefab("common/inventory/mask_three", fn, assets, prefabs),
Prefab ("common/inventory/nightvision", nightvisionfn)