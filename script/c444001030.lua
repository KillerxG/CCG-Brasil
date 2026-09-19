Duel.LoadScript("VampireHunter.lua")
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- 1: Invocação-Ritual
    VampireHunter.AddSelfRitual(c,aux.Stringid(id,0))

    -- 2: Ganho de ATK baseado nos materiais usados
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- 3: Dano Perfurante
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e3)

    -- 4: Passar Efeito (Proteção)
    VampireHunter.RegisterInheritedEffect(c, id, function(rc)
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,1)) 
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_UNRELEASABLE_SUM)
        e1:SetValue(s.oppval)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1,true)
        
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
        rc:RegisterEffect(e2,true)
        
        local e3=Effect.CreateEffect(rc)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
        e3:SetValue(s.matval)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e3,true)
    end)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mat=c:GetMaterial()
    if not mat or #mat==0 then return end
    
    local sum=0
    for tc in aux.Next(mat) do
        -- ADICIONADO: Conta a carta original Vampire Hunter
        if tc:IsSetCard(0x108e) or tc:IsCode(80485722) then
            local atk=tc:GetBaseAttack()
            if atk>0 then sum = sum + atk end
        end
    end
    
    if sum > 0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(sum)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

function s.oppval(e,c)
    return c:GetControler()~=e:GetHandlerPlayer()
end
function s.matval(e,c)
    if not c then return false end
    return c:GetControler()~=e:GetHandlerPlayer()
end