local texture = "fx/torchfire.tex"
local shader = "shaders/particle.ksh"
local colour_envelope_name = "firecolourenvelope"
local scale_envelope_name = "firescaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}


local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()



    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddTag("FX")
    inst.persists = false

    inst.Light:Enable(true)
    inst.Light:SetRadius(6)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.7)
    inst.Light:SetColour(245/255,255/255,245/255)

    return inst
end

return Prefab("common/fx/nightvision", fn, assets)