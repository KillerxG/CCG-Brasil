-- Phantom Gunners Operator - Bianca
-- Scripted by Gemini
local s, id = GetID()
Duel.LoadScript("proc_union_mod.lua")
function s.initial_effect(c)
	-- Union Procedure
	aux.AddUnionProcedureMod(c,s.unionfilter,true,true)
    -- Efeito 1: Normal / Special Summon -> Buscar Magia/Armadilha e Setar Opcional
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    local e2 = e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Efeito 2: Enviado do Campo para o GY -> Mill 2, Reviver -> Restrição
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DECKDES + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1, id + 1)
    e3:SetCondition(s.gycon)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end
-- Union Procedure
function s.unionfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ====================================================================
-- Efeito 1: Busca e Set Adicional
-- ====================================================================
function s.thfilter(c)
    -- Confere se é do arquétipo e se é Magia ou Armadilha
    return c:IsSetCard(0x302) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end

function s.setfilter(c)
    return c:IsSetCard(0x302) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSSetable()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    
    if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, g)
        
        -- Confere se o oponente controla MAIS monstros que você
        local op_monsters = Duel.GetMatchingGroupCount(nil, tp, 0, LOCATION_MZONE, nil)
        local my_monsters = Duel.GetMatchingGroupCount(nil, tp, LOCATION_MZONE, 0, nil)
        
        if op_monsters > my_monsters then
            local sg = Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_DECK, 0, nil)
            if #sg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
                local setg = sg:Select(tp, 1, 1, nil)
                Duel.SSet(tp, setg)
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Mill, Reviver e Trava do Extra Deck
-- ====================================================================
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 2
            and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) 
    end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 2)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.killerfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000960
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    -- Trava a Invocação que vier do Extra Deck SE a carta não for (TREVAS e Guerreiro)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR))
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    
    local ct = Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    
    -- "and if you do": exige que as cartas cheguem ao GY para reviver
    if ct > 0 and og:FilterCount(Card.IsLocation, nil, LOCATION_GRAVE) == 2 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
    
    -- Checagem da Trava: independentemente de a Special Summon ter sucesso ou não,
    -- o texto diz "when this effect resolves". 
    if not Duel.IsExistingMatchingCard(s.killerfilter, tp, LOCATION_MZONE, 0, 1, nil) then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id, 3))
        e1:SetTargetRange(1, 0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end