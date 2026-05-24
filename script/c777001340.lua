-- Silver Fangs Magician - Irina
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Invocação-Link: 2 Monstros de Efeito, incluindo 1 "Silver Fangs"
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_LIGHT), 2, 2, s.lcheck)
    c:EnableReviveLimit()

    -- Efeito 1: Usar monstro do oponente como Material (Underworld Goddess Style)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetTargetRange(1, 1) -- Afeta o próprio campo e o campo do oponente
    e1:SetOperation(s.extracon)
    e1:SetValue(s.extraval)
    c:RegisterEffect(e1)

    -- Efeito 2: Buscar e Invocar por Invocação-Especial do Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Efeito 3: Retornar ao Extra Deck e Ganhar LP
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOEXTRA + CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.gycon)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

-- ====================================================================
-- Requisitos de Invocação-Link
-- ====================================================================
function s.lcheck(g, lc, sumtype, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, 0x307, lc, sumtype, tp)
end

-- ====================================================================
-- Efeito 1: Material Extra do Oponente (EFFECT_EXTRA_MATERIAL)
-- ====================================================================
function s.extracon(c, e, tp, sg, mg, lc, og, chk)
    -- Conta quantos materiais da seleção atual pertencem ao oponente. Limite de 1.
    return sg:FilterCount(Card.IsControler, nil, 1 - tp) <= 1
end

function s.extraval(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        -- Checa: A invocação deve ser Link, a carta invocada deve ser a Irina (sc == c)
        -- E o seu LP precisa ser maior que o do oponente
        if summon_type ~= SUMMON_TYPE_LINK or sc ~= c or Duel.GetLP(tp) <= Duel.GetLP(1 - tp) then
            return Group.CreateGroup()
        else
            -- Retorna um grupo contendo os monstros virados para cima do oponente
            return Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
        end
    elseif chk == 1 then
        -- Vazio: o consumo do material do oponente não precisa de flags adicionais
    elseif chk == 2 then
        -- Vazio
    end
end

-- ====================================================================
-- Efeito 2: Buscar e Special Summon
-- ====================================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c)
    return c:IsSetCard(0x307) and c:IsAbleToHand()
end

function s.spfilter(c, e, tp, zone)
    return c:IsSetCard(0x307) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, tp, zone)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g)
        
        local c = e:GetHandler()
        local zone = c:GetLinkedZone(tp)
        
        -- Checa a vida, a zona linkada e o limite de monstros no campo
        if Duel.GetLP(tp) > Duel.GetLP(1 - tp) and zone ~= 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            local sg = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_DECK, 0, nil, e, tp, zone)
            
            if #sg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local sc = sg:Select(tp, 1, 1, nil):GetFirst()
                if sc and Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP, zone) > 0 then
                    -- Restrição do Extra Deck para o resto do turno (exceto LIGHT)
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_FIELD)
                    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
                    e1:SetDescription(aux.Stringid(id, 3))
                    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
                    e1:SetReset(RESET_PHASE + PHASE_END)
                    e1:SetTargetRange(1, 0)
                    e1:SetTarget(s.splimit)
                    Duel.RegisterEffect(e1, tp)
                end
            end
        end
    end
end

function s.splimit(e, c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_LIGHT)
end

-- ====================================================================
-- Efeito 3: Retornar ao Extra e Curar
-- ====================================================================
function s.kyarafilter(c)
    -- Filtra a Kyara pelo ID
    return c:IsFaceup() and c:GetOriginalCode() == 777001320
end

function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.kyarafilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.gyfilter(c)
    return c:IsSetCard(0x307) and c:IsType(TYPE_MONSTER)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyfilter(chkc) and chkc ~= c end
    if chk == 0 then return c:IsAbleToExtra() and Duel.IsExistingTarget(s.gyfilter, tp, LOCATION_GRAVE, 0, 1, c) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.gyfilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, c, 1, 0, 0)
    
    -- Faz o cálculo matemático para a cura projetada (Nível x200 / Link x400).
    -- Monstros Equisid (Xyz) não têm nível nem Link, então a matemática retorna zero.
    local tc = g:GetFirst()
    local val = (tc:GetLevel() * 200) + (tc:GetLink() * 400)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, val)
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_EXTRA) then
        if tc and tc:IsRelateToEffect(e) then
            local val = (tc:GetLevel() * 200) + (tc:GetLink() * 400)
            if val > 0 then
                Duel.Recover(tp, val, REASON_EFFECT)
            end
        end
    end
end