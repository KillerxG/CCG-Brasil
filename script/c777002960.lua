-- Pyroland Rogue
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Oponente revela monstro com Nível e você envia do topo do Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.miltg)
    e1:SetOperation(s.milop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se enviado do Deck ao GY, retornar 1 carta inimiga para a mão e Setar 1 "Pyroland" S/T
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE | EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET | EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x278}

-- ==========================================================
-- Efeito 1: Revelar (Oponente) e Enviar (Você)
-- ==========================================================
function s.revfilter(c)
    -- Apenas atesta que é uma carta de monstro e que possui Nível
    return c:IsMonster() and c:HasLevel()
end

function s.miltg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Na fase passiva, atestamos se o oponente tem alguma carta nas zonas privadas (Mão ou Extra Deck)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
        and Duel.IsExistingMatchingCard(s.revfilter, 1 - tp, LOCATION_HAND | LOCATION_EXTRA, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 1)
end

function s.milop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Abre o prompt de seleção na tela do OPONENTE (1 - tp)
    Duel.Hint(HINT_SELECTMSG, 1 - tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(1 - tp, s.revfilter, 1 - tp, LOCATION_HAND | LOCATION_EXTRA, 0, 1, 1, nil)
    local tc = g:GetFirst()
    
    if tc then
        -- Revela a carta escolhida para você
        Duel.ConfirmCards(tp, tc)
        local lv = tc:GetLevel()
        
        if lv > 0 then
            -- Envia a quantia do topo do Deck para o GY baseada no Nível
            Duel.DiscardDeck(tp, lv, REASON_EFFECT)
        end
        
        -- Embaralha a mão do oponente apenas se a carta escolhida estava lá
        if tc:IsLocation(LOCATION_HAND) then
            Duel.ShuffleHand(1 - tp)
        end
    end
end

-- ==========================================================
-- Efeito 2: Retornar para a mão (Bounce) e Setar do GY
-- ==========================================================
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.setfilter(c)
    return c:IsSetCard(0x278) and c:IsSpellTrap() and c:IsSSetable()
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    
    if tc and tc:IsRelateToEffect(e) then
        -- Se voltar para a mão ou pro Extra Deck (LOCATION_EXTRA) com sucesso
        if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND | LOCATION_EXTRA) then
            local sg = Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_GRAVE, 0, nil)
            
            if #sg > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
                local setc = sg:Select(tp, 1, 1, nil):GetFirst()
                if setc then
                    Duel.SSet(tp, setc)
                end
            end
        end
    end
end