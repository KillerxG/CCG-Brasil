Duel.LoadScript("VampireHunter.lua")
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- 1: Invocação-Ritual (Sem limitação de ativações/turnos)
    VampireHunter.AddSelfRitual(c,aux.Stringid(id,0))

    -- 2: Efeito 1 (Mandar para o GY)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.effcon1)
    e2:SetTarget(s.efftg1)
    e2:SetOperation(s.effop1)
    c:RegisterEffect(e2)

    -- 3: Efeito 2 (Voltar para a mão)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id+1) -- Hard Once Per Turn separado
    e3:SetCondition(s.effcon2)
    e3:SetTarget(s.efftg2)
    e3:SetOperation(s.effop2)
    c:RegisterEffect(e3)

    -- 4: Passar Efeito (Zero dano de Batalha e Efeito)
    VampireHunter.RegisterInheritedEffect(c, id, function(rc)
        -- Sem dano de batalha (apenas envolvendo esta carta)
        local e1=Effect.CreateEffect(rc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,1)) 
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1,true)
        
        -- Sem dano de efeito (global para o jogador)
        local e2=Effect.CreateEffect(rc)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetCode(EFFECT_CHANGE_DAMAGE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetTargetRange(1,0)
        e2:SetValue(function(e,re,val,r,rp,rc)
            if (r & REASON_EFFECT) ~= 0 then return 0 end
            return val
        end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e2,true)
    end)
end

-- === Filtros Comuns ===
function s.vhfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x108e) or c:IsCode(80485722))
end

-- === Funções do Efeito 1 (Mandar para o GY) ===
function s.effcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.tgfilter(c)
    return c:IsSetCard(0x8e) and c:IsAbleToGrave()
end
function s.efftg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.effop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- === Funções do Efeito 2 (Voltar para a Mão) ===
function s.effcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) 
        and Duel.IsExistingMatchingCard(s.vhfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.thfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x8e) and c:IsAbleToHand()
end
function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.effop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end