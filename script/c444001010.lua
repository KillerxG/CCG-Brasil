local s,id=GetID()

function s.initial_effect(c)
    -- 1. Não pode ser destruída em batalha
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    
    -- 2. Você não sofre dano de batalha
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3. Taunt: Oponente é obrigado a atacar esta carta
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_MUST_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    c:RegisterEffect(e3)
    local e3b=Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetCode(EFFECT_MUST_ATTACK_MONSTER)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetTargetRange(0,LOCATION_MZONE)
    e3b:SetValue(s.atklimit)
    c:RegisterEffect(e3b)

    -- 4. Refletir o dano (Antes do cálculo)
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetCondition(s.damcon)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)

    -- 5. Recuperar Zumbi do Cemitério ou Banido (Ignition, Soft Once per Turn)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1) 
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)

    -- 6. Ignition Effect: Mandar para o GY + Extra Normal Summon (Hard Once per Turn)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,id)
    e6:SetTarget(s.tgtg)
    e6:SetOperation(s.tgop)
    c:RegisterEffect(e6)
end

s.listed_series={0x8e}

-- ==========================================
-- TAUNT (OBRIGAR ATAQUE)
-- ==========================================
function s.atklimit(e,c)
    return c==e:GetHandler()
end

-- ==========================================
-- REFLEXÃO DE DANO (YUBEL-LIKE)
-- ==========================================
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    return bc and bc:GetControler()~=tp
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        local dam=bc:GetAttack()
        if dam>0 then
            Duel.Damage(1-tp, dam, REASON_EFFECT)
        end
    end
end

-- ==========================================
-- EFEITO 5: RECUPERAR ZUMBI DO GY / BANIDO
-- ==========================================
function s.thfilter(c)
    return c:IsRace(RACE_ZOMBIE) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end

-- ==========================================
-- EFEITO 6: MANDAR DECK -> GY E EXTRA SUMMON
-- ==========================================
function s.tgfilter(c)
    return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,2)) 
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8e))
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end