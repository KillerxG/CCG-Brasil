-- Creature-Warden Treasure Room
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Ativação Padrão da Magia Contínua
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Efeito 1: Colocar 1 "Creature-Warden" no topo do Deck e (opcionalmente) comprar 1
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id) -- Remova os traços se quiser limitar o uso por turno
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Efeito 2: Substituição de Destruição
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
	
	-- Efeito 4 (e4): Comprar, revelar e, se não for do arquétipo, banir temporariamente face-down
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DRAW | CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.drcon4)
    e4:SetTarget(s.drtg4)
    e4:SetOperation(s.drop4)
    c:RegisterEffect(e4)
end

-- Identifica a série "Creature-Warden" para otimizar as buscas 
s.listed_series = {0x251}

-- ==========================================================
-- Efeito 1: Manipulação do Deck e Compra
-- ==========================================================
function s.thfilter(c)
    return c:IsSetCard(0x251) and c:IsMonster()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    -- A compra (draw) é opcional, portanto não a usamos para bloquear a ativação caso o Deck tenha 1 carta
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0)) -- String no banco de dados para orientar a UI
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    local tc = g:GetFirst()
    
    if tc then
        -- É obrigatório embaralhar o restante do Deck antes de repousar a carta no topo
        Duel.ShuffleDeck(tp)
        Duel.MoveSequence(tc, SEQ_DECKTOP)
        Duel.ConfirmCards(1 - tp, tc)
        
        -- "...then you can draw 1 card."
        if Duel.IsPlayerCanDraw(tp, 1) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end

-- ==========================================================
-- Efeito 2: Salvar Monstros e Comprar (Dependente de Xyz/Ritual)
-- ==========================================================
function s.repfilter(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x251) and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp) and c:IsReason(REASON_BATTLE | REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.repmatfilter(c)
    -- A carta no GY deve ser um monstro Creature-Warden e estar apta a voltar para o Deck
    return c:IsSetCard(0x251) and c:IsMonster() and c:IsAbleToDeck()
end

function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return eg:IsExists(s.repfilter, 1, nil, tp)
        and Duel.IsExistingMatchingCard(s.repmatfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    -- Abre o prompt universal de substituição
    if Duel.SelectEffectYesNo(tp, c, 96) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local g = Duel.SelectMatchingCard(tp, s.repmatfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
        Duel.SetTargetCard(g)
        -- Atrela a carta escolhida temporariamente à memória do efeito para que ela seja movida na repop
        e:SetLabelObject(g:GetFirst())
        return true
    else
        return false
    end
end

function s.repval(e, c)
    return s.repfilter(c, e:GetHandlerPlayer())
end

function s.drawfilter(c)
    -- A sintaxe bitwise | varre Xyz e Rituais em um mesmo filtro instantaneamente 
    return c:IsFaceup() and c:IsSetCard(0x251) and c:IsType(TYPE_RITUAL | TYPE_XYZ)
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    -- Parâmetro SEQ_DECKTOP inserido como terceira variável (sequence) direciona a carta diretamente para o topo do Deck
    if tc and Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT | REASON_REPLACE) > 0 then
        if tc:IsLocation(LOCATION_DECK) then
            -- Condição: "...then if you control a Creature-Warden Ritual or Xyz Monster you can draw 1 card"
            local can_draw = Duel.IsPlayerCanDraw(tp, 1)
            local has_boss = Duel.IsExistingMatchingCard(s.drawfilter, tp, LOCATION_MZONE, 0, 1, nil)
            
            if can_draw and has_boss and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                Duel.BreakEffect()
                Duel.Draw(tp, 1, REASON_EFFECT)
            end
        end
    end
end

-- ==========================================================
-- Efeito 4 (e4): Gatilho de Special Summon Inimigo
-- ==========================================================
function s.cfilter4(c)
    -- Checa a presença do Ritual ou Xyz do arquétipo na sua mesa
    return c:IsFaceup() and c:IsSetCard(0x251) and c:IsType(TYPE_RITUAL | TYPE_XYZ)
end

function s.drcon4(e, tp, eg, ep, ev, re, r, rp)
    -- eg:IsExists varre o grupo invocado para confirmar se pelo menos 1 pertence ao oponente (1 - tp)
    return eg:IsExists(Card.IsControler, 1, nil, 1 - tp)
        and Duel.IsExistingMatchingCard(s.cfilter4, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.drtg4(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drop4(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    
    -- Se a compra for bem sucedida...
    if Duel.Draw(p, d, REASON_EFFECT) > 0 then
        -- Extraímos e isolamos a carta comprada
        local tc = Duel.GetOperatedGroup():GetFirst()
        
        -- Revela a carta para o oponente
        Duel.ConfirmCards(1 - tp, tc)
        
        -- Condicional: Se NÃO for um "Creature-Warden" (0x251)
        if not tc:IsSetCard(0x251) then
            Duel.BreakEffect()
            -- Bane a carta face-down com a tag REASON_TEMPORARY para que o jogo não a trate como banida eternamente
            if Duel.Remove(tc, POS_FACEDOWN, REASON_EFFECT | REASON_TEMPORARY) > 0 and tc:IsLocation(LOCATION_REMOVED) then
                -- Registra uma "marca" imutável na carta enquanto ela estiver banida
                tc:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END, 0, 1)
                
                -- Cria o efeito programado que devolverá a carta para a mão na End Phase
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
                e1:SetCode(EVENT_PHASE | PHASE_END)
                e1:SetReset(RESET_PHASE | PHASE_END)
                e1:SetLabelObject(tc)
                e1:SetCountLimit(1)
                e1:SetOperation(s.retop4)
                Duel.RegisterEffect(e1, tp)
            end
        end
        
        -- Embaralha a mão para que o estado de conhecimento das cartas volte ao normal
        Duel.ShuffleHand(tp)
    end
end

-- ==========================================================
-- Efeito Programado: Retorno à Mão na End Phase
-- ==========================================================
function s.retop4(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    -- Confirma se a carta designada continua banida perfeitamente através da marca que deixamos nela
    if tc and tc:GetFlagEffect(id) > 0 then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    end
end