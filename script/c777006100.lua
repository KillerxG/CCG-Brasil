-- Creature-Warden, Ursula
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Xyz (Monstros Nível 4, 2 Matérias)
    c:EnableReviveLimit()
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_BEASTWARRIOR), 4, 2)

    -- Efeito 1: Olhar 2 cartas aleatórias do Extra Deck do oponente e anexar 1
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.attcon)
    e1:SetTarget(s.atttg)
    e1:SetOperation(s.attop)
    c:RegisterEffect(e1)

    -- Efeito 2: Alvo no GY para Adicionar à Mão ou Colocar no Topo do Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND | CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Efeito 3: Ao comprar carta(s), Desanexar para Destruir, depois Invocação-Xyz
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DESTROY | CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DRAW)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCost(s.descost)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3, false, REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series = {0x251}

-- ==========================================================
-- Efeito 1: Roubar do Extra Deck
-- ==========================================================
function s.attcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.atttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local g = Duel.GetFieldGroup(tp, 0, LOCATION_EXTRA)
        return g:FilterCount(Card.IsFacedown, nil) >= 2 and e:GetHandler():IsType(TYPE_XYZ)
    end
end

function s.attop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_EXTRA):Filter(Card.IsFacedown, nil)
    if #g >= 2 then
        local sg = g:RandomSelect(tp, 2)
        Duel.ConfirmCards(tp, sg)
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
        local tg = sg:Select(tp, 1, 1, nil)
        if #tg > 0 then
            Duel.Overlay(c, tg)
        end
    end
end

-- ==========================================================
-- Efeito 2: Recuperar do Cemitério (Mão ou Topo do Deck)
-- ==========================================================
function s.thfilter(c)
    return c:IsSetCard(0x251) and (c:IsAbleToHand() or c:IsAbleToDeck())
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TODECK, g, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local b1 = tc:IsAbleToHand()
        local b2 = tc:IsAbleToDeck()
        local op = 0
        
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
        elseif b1 then
            op = 0
        else
            op = 1
        end
        
        if op == 0 then
            Duel.SendtoHand(tc, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, tc)
        else
            Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT)
        end
    end
end

-- ==========================================================
-- Efeito 3: Ao Comprar: Desanexar, Destruir e Invocar Xyz
-- ==========================================================
function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1 - tp, LOCATION_ONFIELD)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.xyzfilter(c, e, tp, mc)
    -- Removemos a exigência nativa de material (IsCanBeXyzMaterial). Apenas checa se é um Xyz do arquétipo.
    return c:IsSetCard(0x251) and c:IsType(TYPE_XYZ)
        and Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    
    if #g > 0 and Duel.Destroy(g, REASON_EFFECT) > 0 then
        -- Se a Ursula ficou sem matérias:
        if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetOverlayCount() == 0 then
            local xyzg = Duel.GetMatchingGroup(s.xyzfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, c)
            
            if #xyzg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local sc = xyzg:Select(tp, 1, 1, nil):GetFirst()
                if sc then
                    -- Emulação do Xyz Summon por Card Effect
                    -- 1: Atrelamos as identidades de material
                    sc:SetMaterial(Group.FromCards(c))
                    -- 2: Anexamos a própria Ursula ao novo monstro
                    Duel.Overlay(sc, c)
                    -- 3: Completamos a invocação formal
                    if Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP) > 0 then
                        sc:CompleteProcedure()
                    end
                end
            end
        end
    end
end