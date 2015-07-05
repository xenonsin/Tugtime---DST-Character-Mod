local assets =
{ 
    Asset("ANIM", "anim/mask_two.zip"),
    Asset("ANIM", "anim/mask_two_swap.zip"), 

    Asset("ATLAS", "images/inventory/mask_two.xml"),
    Asset("IMAGE", "images/inventory/mask_two.tex"),
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

local function getitem(player, amulet, item, destroy)
    --Amulet will only ever pick up items one at a time. Even from stacks.
    local fx = SpawnPrefab("small_puff")
    fx.Transform:SetPosition(item.Transform:GetWorldPosition())
    fx.Transform:SetScale(0.5, 0.5, 0.5)

    if destroy then
        if amulet == item then
            return --#srosen Probably don't want the amulet to destroy itself, also maybe that's great?
        end
        item:Remove()
    else
        
        if item.components.stackable then
            item = item.components.stackable:Get()
        end
        
        if item.components.trap and item.components.trap:IsSprung() then
            item.components.trap:Harvest(player)
            return
        end
        
        player.components.inventory:GiveItem(item)
    end
end

local function pickup(inst, owner, destroy)
    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7)

    for k,v in pairs(ents) do
		if v.components.pickable and not v.components.pickable:IsBarren() then
		local item = SpawnPrefab(v.components.pickable.product)
		item.Transform:SetPosition(v.Transform:GetWorldPosition())
		item.Transform:SetScale(1, 1, 1)
		--bug: not supposed to be dead.
		v.components.pickable:MakeBarren()
		end
	
	
        if v.components.inventoryitem and v.components.inventoryitem.canbepickedup and v.components.inventoryitem.cangoincontainer and not
            v.components.inventoryitem:IsHeld() then

            if not owner.components.inventory:IsFull() then
                --Your inventory isn't full, you can pick something up.
                getitem(owner, inst, v, destroy)
                if not destroy then return end

            elseif v.components.stackable then
                --Your inventory is full, but the item you're trying to pick up stacks. Check for an exsisting stack.
                --An acceptable stack should: Be of the same item type, not be full already and not be in the "active item" slot of inventory.
                local stack = owner.components.inventory:FindItem(function(item) return (item.prefab == v.prefab and not item.components.stackable:IsFull()
                    and item ~= owner.components.inventory.activeitem) end)
                if stack then
                    getitem(owner, inst, v, destroy)
                    if not destroy then return end
                end
            elseif destroy then
                getitem(owner, inst, v, destroy)
            end
        end
    end
    
end

local function picky(inst,owner, destroy)
	local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7)

    for k,v in pairs(ents) do
		if v.components.pickable and not v.components.pickable:IsBarren() then
		v.components.pickable.quickpick = true
		end
	end
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "mask_two_swap", "swap_hat")
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
	
	--Pick up things automatically
	--inst.task = inst:DoPeriodicTask(1, pickup, nil, owner) 
	
	inst.task = inst:DoPeriodicTask(1, picky, nil, owner)
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

    inst.AnimState:SetBank("mask_two")
    inst.AnimState:SetBuild("mask_two")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "mask_two"
    inst.components.inventoryitem.atlasname = "images/inventory/mask_two.xml"
		    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	--SPEEEEEED
	inst.components.equippable.walkspeedmult = 2
	
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
    print("Hi!")

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





return  Prefab("common/inventory/mask_two", fn, assets, prefabs)