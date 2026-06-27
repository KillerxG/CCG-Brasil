-- Phantom Gunners' Database
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Enviar 2 do topo do Deck do Oponente -> Buscar -> Bônus do Killer
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DECKDES + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id) -- O HOPT é travado no "id" base
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Efeito 2: Banir do GY -> Equipar Union do Deck
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id) -- Usa o exato MESMO "id" do Efeito 1 (Choose 1 per turn)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_UNION}
-- ====================================================================
-- Filtros Globais
-- ====================================================================
function s.killerfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777000960
end

-- ====================================================================
-- Efeito 1: Mill + Busca + Mill Opcional
-- ====================================================================
function s.thfilter(c)
    return c:IsSetCard(0x302) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 2
            and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 2)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    -- Tenta enviar as 2 cartas e checa quantas bateram no GY com sucesso
    local ct = Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    
    -- O "and if you do" exige que as 2 cartas cheguem ao Cemitério
    if ct > 0 and og:FilterCount(Card.IsLocation, nil, LOCATION_GRAVE) == 2 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        
        if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1 - tp, g)
            
            -- Condição Bônus: Controlar o "Leader of Phantom Gunners - Killer"
            if Duel.IsExistingMatchingCard(s.killerfilter, tp, LOCATION_MZONE, 0, 1, nil)
                and Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 2 then
                -- Pergunta se o jogador deseja mandar mais 2 cartas
                if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                    Duel.BreakEffect()
                    Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
                end
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Equipar Monstro Union do Deck
-- ====================================================================
function s.unionfilter(c, tc)
    -- Função global do EDOPro para checar se o Union pode se equipar naquele alvo específico
    return c:IsType(TYPE_UNION) and aux.CheckUnionEquip(c, tc)
end

function s.tgfilter(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x302) and Duel.IsExistingMatchingCard(s.unionfilter, tp, LOCATION_DECK, 0, 1, nil, c)
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
        and Duel.IsExistingTarget(s.tgfilter, tp, LOCATION_MZONE, 0, 1, nil, tp) end
        
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.tgfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK)
end

function s.eqlimit(e, c)
    return c == e:GetLabelObject()
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
        local g = Duel.SelectMatchingCard(tp, s.unionfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tc)
        local eqc = g:GetFirst()
        
        if eqc then
            if Duel.Equip(tp, eqc, tc) then
                -- Registra o limite do equipamento
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_EQUIP_LIMIT)
                e1:SetValue(s.eqlimit)
                e1:SetLabelObject(tc)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                eqc:RegisterEffect(e1)
                
                -- Registra a carta como estado nativo de "Union" para que ela possa usar efeitos como se desequipar ou substituir a destruição do monstro
                local e2 = Effect.CreateEffect(e:GetHandler())
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e2:SetCode(EFFECT_UNION_STATUS)
                e2:SetReset(RESET_EVENT + RESETS_STANDARD)
                eqc:RegisterEffect(e2)
                
                -- Alimenta a variável do sistema oficial se ela estiver ativada na engine
                if aux.SetUnionState then
                    aux.SetUnionState(eqc)
                end
            end
        end
    end
end