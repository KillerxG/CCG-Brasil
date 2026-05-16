-- Cute Shinob Beast - The Master
-- Scripted by Gemini
local s, id = GetID()

-- Definir o filtro do Link antes do initial_effect para evitar leituras nulas durante a inicialização
function s.matfilter(c)
    return c:IsSetCard(0x267) and not c:IsType(TYPE_LINK)
end

function s.initial_effect(c)
    -- Habilita Invocação Link e Define os Materiais
    c:EnableReviveLimit()
    Link.AddProcedure(c, s.matfilter, 1, 1)

    -- Efeito 1: Embaralhar 1 monstro "Cute Shinob" do GY no Deck e baixar 1 Magia/Armadilha do Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)

    -- Efeito 2: Se um ou mais monstros "Cute Shinob" seriam destruídos, banir esta carta do GY em vez disso
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end

s.listed_series = {0x267}
s.listed_names = {555000080} -- Cute Shinob Village

-- ==========================================================
-- Efeito 1: Embaralhar no Deck e Baixar S/T
-- ==========================================================
function s.tdfilter(c)
    return c:IsSetCard(0x267) and c:IsMonster() and c:IsAbleToDeck()
end

function s.setfilter(c)
    return c:IsSetCard(0x267) and c:IsSpellTrap() and c:IsSSetable()
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.tdfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    -- Confirma se a carta ainda existe e se foi embaralhada no Main Deck ou Extra Deck com sucesso
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        if tc:IsLocation(LOCATION_DECK | LOCATION_EXTRA) then
            local g = Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_DECK, 0, nil)
            -- Interrompe a chain com BreakEffect para resolver o "then" e pergunta se o jogador quer baixar
            if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
                local sg = g:Select(tp, 1, 1, nil)
                Duel.SSet(tp, sg:GetFirst())
            end
        end
    end
end

-- ==========================================================
-- Efeito 2: Substituição de Destruição e Ativação de Field Spell
-- ==========================================================
function s.repfilter(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x267) and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp) and c:IsReason(REASON_BATTLE | REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Verifica se existem monstros adequados sendo destruídos e se a carta no GY pode ser banida
    if chk == 0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter, 1, nil, tp) end
    -- Prompt 96 exibe o aviso padrão universal do jogo para efeitos de substituição de destruição do cemitério
    if Duel.SelectEffectYesNo(tp, c, 96) then
        return true
    end
    return false
end

function s.repval(e, c)
    return s.repfilter(c, e:GetHandlerPlayer())
end

function s.actfilter(c)
    return c:IsCode(555000080) and not c:IsForbidden()
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Se o custo de banir a própria carta para salvar os monstros der certo
    if Duel.Remove(c, POS_FACEUP, REASON_EFFECT | REASON_REPLACE) > 0 then
        -- Verifica se o jogador não controla Magia de Campo
        local fc = Duel.GetFieldCard(tp, LOCATION_FZONE, 0)
        local g = Duel.GetMatchingGroup(s.actfilter, tp, LOCATION_DECK, 0, nil)
        
        -- Pergunta se quer ativar a "Cute Shinob Village" (Stringid 2)
        if not fc and #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
            local tc = g:Select(tp, 1, 1, nil):GetFirst()
            -- Para "ativar" campos direto do deck de forma 100% segura e limpa, os scripts modernos utilizam MoveToField como faceup.
            Duel.MoveToField(tc, tp, tp, LOCATION_FZONE, POS_FACEUP, true)
        end
    end
end