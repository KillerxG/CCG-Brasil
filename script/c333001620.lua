
-- Mr. Grand Premiere
local s,id=GetID()
local SET_MR=0x215b

function s.initial_effect(c)
    -- So pode controlar 1
    c:SetUniqueOnField(1,0,id)

    -- Ativacao: buscar e Invocar
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Invocacoes Normais adicionais
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.sumcon)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)
end

-- =====================================
-- EFEITO 1: BUSCA + TRIBUTO ADVERSARIO
-- =====================================

function s.thfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsType(TYPE_NORMAL)
        and c:IsLevelAbove(5)
        and c:IsAbleToHand()
end

-- Impede tributar monstros de mesmo Atributo
function s.triblimit(e,c)
    return (c:GetAttribute() & e:GetLabel())~=0
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g=Duel.GetMatchingGroup(
        s.thfilter,tp,LOCATION_DECK,0,nil
    )

    if #g==0 then return end

    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()

    if not tc then return end

    if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then
        return
    end

    Duel.ConfirmCards(1-tp,tc)

    -- So permite Invocacao imediata se for Mr.
    if not tc:IsSetCard(SET_MR) then return end

    local attr=tc:GetAttribute()

    -- Permissao identica a The Monarchs Stormforth
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)

    -- Proibe Tributos do mesmo Atributo
    -- do monstro Mr. adicionado
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRIBUTE_LIMIT)
    e2:SetValue(s.triblimit)
    e2:SetLabel(attr)
    e2:SetReset(
        RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END
    )
    tc:RegisterEffect(e2)

    -- Invocacao Normal imediatamente apos a busca
    if tc:IsLocation(LOCATION_HAND)
        and tc:IsSummonable(true,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then

        Duel.Summon(tp,tc,true,nil)
    end

    -- IMPORTANTE:
    -- Nao usar e1:Reset() aqui!
    -- O motor ainda precisa desse efeito
    -- durante a selecao dos Tributos.
end

-- =====================================
-- EFEITO 2: INVOCACOES NORMAIS EXTRAS
-- =====================================

function s.attr_count(tp)
    local g=Duel.GetMatchingGroup(
        Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL
    )

    local att=0

    for tc in aux.Next(g) do
        att=att|tc:GetAttribute()
    end

    local attrs={
        ATTRIBUTE_EARTH,
        ATTRIBUTE_WATER,
        ATTRIBUTE_FIRE,
        ATTRIBUTE_WIND,
        ATTRIBUTE_LIGHT,
        ATTRIBUTE_DARK,
        ATTRIBUTE_DIVINE
    }

    local ct=0

    for _,a in ipairs(attrs) do
        if (att&a)~=0 then
            ct=ct+1
        end
    end

    return ct
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
        and Duel.IsMainPhase()
end

function s.sumfilter(c)
    return c:IsType(TYPE_NORMAL)
        and c:IsSummonable(true,nil)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=s.attr_count(tp)
    local used=e:GetHandler():GetFlagEffect(id)

    if chk==0 then
        return used<ct
            and Duel.IsExistingMatchingCard(
                s.sumfilter,tp,
                LOCATION_HAND+LOCATION_MZONE,
                0,1,nil
            )
    end

    Duel.SetOperationInfo(
        0,CATEGORY_SUMMON,nil,1,0,0
    )
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if not c:IsRelateToEffect(e) then return end

    local ct=s.attr_count(tp)
    local used=c:GetFlagEffect(id)

    if used>=ct then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)

    local g=Duel.SelectMatchingCard(
        tp,s.sumfilter,tp,
        LOCATION_HAND+LOCATION_MZONE,
        0,1,1,nil
    )

    local tc=g:GetFirst()

    if not tc then return end

    Duel.Summon(tp,tc,true,nil)

    c:RegisterFlagEffect(
        id,
        RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,
        0,1
    )
end
