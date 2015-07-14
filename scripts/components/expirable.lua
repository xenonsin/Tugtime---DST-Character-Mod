local Expirable = Class(function(self, inst)
    self.inst = inst
	self.consuming = false

    self.maxfuel = 0
    self.currentfuel = 0
    self.rate = 1
	self.sections = 1
    self.sectionfn = nil
    self.period = 1
    self.bonusmult = 1
	self.depleted = nil
end)

function Expirable:StartConsuming()
	self.consuming = true
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(self.period, function() self:DoUpdate(self.period) end)
    end
end

function Expirable:GetSectionPercent()
    local section = self:GetCurrentSection()
    return (self:GetPercent() - (section - 1)/self.sections) / (1/self.sections)
end

function Expirable:ChangeSection(amount)
    local fuelPerSection = self.maxfuel / self.sections
    self:DoDelta((amount * fuelPerSection)-1)
end

function Expirable:GetPercent()
    return self.maxfuel > 0 and math.max(0, math.min(1, self.currentfuel / self.maxfuel)) or 0
end

function Expirable:SetPercent(amount)
    local target = (self.maxfuel * amount)
    self:DoDelta(target - self.currentfuel)
end

function Expirable:InitializeFuelLevel(fuel)
    local oldsection = self:GetCurrentSection()
    if self.maxfuel < fuel then
        self.maxfuel = fuel
    end
    self.currentfuel = fuel

    local newsection = self:GetCurrentSection()
    if oldsection ~= newsection and self.sectionfn then
        self.sectionfn(newsection, oldsection, self.inst)
    end
end

function Expirable:SetDepletedFn(fn)
    self.depleted = fn
end

function Expirable:IsEmpty()
    return self.currentfuel <= 0
end

function Expirable:SetSections(num)
    self.sections = num
end

function Expirable:GetCurrentSection()
    if self:IsEmpty() then
        return 0
    else
        return math.min( math.floor(self:GetPercent()* self.sections)+1, self.sections)
    end
end

function Expirable:DoDelta(amount)
    local oldsection = self:GetCurrentSection()

    self.currentfuel = math.max(0, math.min(self.maxfuel, self.currentfuel + amount) )

    local newsection = self:GetCurrentSection()

    if oldsection ~= newsection then
        if self.sectionfn then
            self.sectionfn(newsection, oldsection, self.inst)
        end
        if self.currentfuel <= 0 and self.depleted then
            self.depleted(self.inst)
        end
    end

    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
end

function Expirable:SetUpdateFn(fn)
    self.updatefn = fn
end

function Expirable:DoUpdate(dt)
    if self.consuming then
        self:DoDelta(-dt*self.rate)
    end

    if self:IsEmpty() then
        self:StopConsuming()
    end

    if self.updatefn ~= nil then
        self.updatefn(self.inst)
    end
end

function Expirable:StopConsuming()
    self.consuming = false
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

Expirable.LongUpdate = Expirable.DoUpdate

return Expirable