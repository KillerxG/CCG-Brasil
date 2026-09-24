-- Warforged Scouter
local s,id=GetID()
function s.initial_effect(c)
    -- 1) Procedimento Padrão de Gemini
    Gemini.AddProcedure(c)
    
    -- 2) Tratada como Magia de Equipamento na Mão
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetCondition(s.equiptypecon)
    e1:SetValue(TYPE_SPELL+TYPE_EQUIP)
    c:RegisterEffect(e1)
    
    -- Limite de Equipamento de Segurança
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- 3) Gatilho 1: Oponente adiciona carta à mão (Exceto Draw Phase)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_HAND)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
    e3:SetCountLimit(1,id) -- Restrição partilhada HOPT
    e3:SetCondition(s.thcon)
    e3:SetCost(s.cost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    
    -- 4) Gatilho 2: Oponente invoca do Deck/Extra Deck
    local e4=e3:Clone()
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- Configurações de Arquétipo e IDs
local SETCODE_WARFORGED = 0x311
local CARD_FESTOS = 333100000 -- O ID Alias correto do Festos
s.listed_names={CARD_FESTOS}

-- ==========================================
-- A LÓGICA DO FESTOS
-- ==========================================
function s.festos_exists(tp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_FESTOS),tp,LOCATION_MZONE,0,1,nil)
end
function s.equiptypecon(e)
    return s.festos_exists(e:GetHandlerPlayer())
end

-- ==========================================
-- CONDIÇÃO GERAL DOS GATILHOS
-- ==========================================
function s.effcon(e)
    local c=e:GetHandler()
    -- Ativo se for Monstro Gemini ativado na MZONE OU se for Magia equipada na SZONE
    return (c:IsLocation(LOCATION_MZONE) and Gemini.EffectStatusCondition(e))
        or (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()~=nil)
end

-- ==========================================
-- CUSTO PARTILHADO (Descartar Equip Spell)
-- ==========================================
function s.cfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end

-- ==========================================
-- LÓGICA DO GATILHO 1: ADICIONAR À MÃO
-- ==========================================
function s.thfilter(c,tp)
    return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsLocation(LOCATION_HAND) and c:IsAbleToDeck()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    -- REGRA DE OURO AQUI: Ignora completamente o evento se estiver na Draw Phase!
    return Duel.GetCurrentPhase()~=PHASE_DRAW and s.effcon(e) and eg:IsExists(s.thfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- Isola as cartas exatas que foram adicionadas à mão para a operação
    local g=eg:Filter(s.thfilter,nil,tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsLocation,nil,LOCATION_HAND)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        -- Permite ao jogador escolher baralhar uma das cartas que ativou o efeito
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

-- ==========================================
-- LÓGICA DO GATILHO 2: INVOCAR DO DECK/EXTRA
-- ==========================================
function s.spfilter_ev(c,tp)
    return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_EXTRA) 
        and c:IsLocation(LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return s.effcon(e) and eg:IsExists(s.spfilter_ev,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=eg:Filter(s.spfilter_ev,nil,tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsLocation,nil,LOCATION_MZONE)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end