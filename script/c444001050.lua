-- The Gardener of Vampire Castle
local s, id = GetID()

function s.initial_effect(c)
    -- 1. Redução de Tributo: Exige apenas 1 Tributo para Invocação-Tributo (Nível 8 -> 1 Tributo)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_DECREASE_TRIBUTE)
    e0:SetValue(0x10001)
    c:RegisterEffect(e0)

    -- 2. Restrição: Apenas para Invocações de "Vampire"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1:SetValue(s.matlimit)
    c:RegisterEffect(e1)
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1b:SetValue(s.matlimit)
    c:RegisterEffect(e1b)
    local e1c=e1b:Clone()
    e1c:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e1c)

    -- 3. Revelar da mão e realizar Invocação-Normal por efeito
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.normcost)
    e2:SetTarget(s.normtg)
    e2:SetOperation(s.normop)
    c:RegisterEffect(e2)

    -- 4. Invocar 2 Tokens ao ser Invocada (Normal ou Especial)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetTarget(s.tokentg)
    e3:SetOperation(s.tokenop)
    c:RegisterEffect(e3)
    local e3b=e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)

    -- 5. Cemitério: Olhar o topo, Zerar ATK/DEF e embaralhar no Deck
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCondition(s.topcon)
    e4:SetTarget(s.toptg)
    e4:SetOperation(s.topop)
    c:RegisterEffect(e4)
end

s.listed_series = {0x8e}

-- Limite de Material
function s.matlimit(e,c)
    if not c then return false end
    return not c:IsSetCard(0x8e)
end

-- Efeito 3: Invocação-Normal da Mão por Efeito (Revelar)
function s.normcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return not c:IsPublic() end
    Duel.ConfirmCards(1-tp,c)
    Duel.ShuffleHand(tp)
end

function s.normtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsSummonable(true,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end

function s.normop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSummonable(true,nil) then
        Duel.Summon(tp,c,true,nil)
    end
end

-- Efeito 4: Invocação de Tokens
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,0)
end

function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
    for i=1, 2 do
        local b1 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        local b2 = Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
        if not b1 and not b2 then break end
        
        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,4))
        elseif b1 then
            op = 0
        else
            op = 1
        end
        
        local target_p = (op==0) and tp or 1-tp
        local token = Duel.CreateToken(tp, id+1)
        Duel.SpecialSummonStep(token,0,tp,target_p,false,false,POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
end

-- Efeito 5: Cemitério (Ataque do Oponente -> Olhar topo -> Zerar ATK/DEF -> Embaralhar no Deck)
function s.topcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsControler(1-tp)
end

function s.toptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and e:GetHandler():IsAbleToDeck() end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end

function s.topop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local at=Duel.GetAttacker() 
    
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
    
    Duel.ConfirmDecktop(tp, 1)
    local g = Duel.GetDecktopGroup(tp, 1)
    local tc = g:GetFirst()
    
    if tc then
        local is_valid = tc:IsType(TYPE_MONSTER) and (tc:IsRace(RACE_ZOMBIE) or tc:IsRace(RACE_FIEND) or tc:IsSetCard(0x8e))
        if is_valid then
            if at and at:IsRelateToBattle() and at:IsFaceup() and not at:IsImmuneToEffect(e) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                e1:SetValue(0)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                at:RegisterEffect(e1)
                
                local e2=e1:Clone()
                e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
                at:RegisterEffect(e2)
                
                if c:IsRelateToEffect(e) then
                    Duel.SendtoDeck(c, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
                end
            end
        end
    end
end