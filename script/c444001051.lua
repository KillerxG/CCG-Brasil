-- The Rose of Vampire Castle Token
local s, id = GetID()
function s.initial_effect(c)
    -- 1. Nao pode ser destruido por batalha
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- 2. Restricao: Apenas pode ser usado como Material ou Tributo para monstros "Vampire"
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2:SetValue(s.matlimit)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UNRELEASABLE_SUM)
    e3:SetValue(s.matlimit)
    c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e4)
end

function s.matlimit(e,c)
    if not c then return false end
    return not c:IsSetCard(0x8e)
end