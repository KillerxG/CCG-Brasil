-- Celestial Guardian - Eatos
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Habilita Invocação-Ritual
    c:EnableReviveLimit()

    -- Efeito 2: Inafetada por efeitos ativados do oponente se você não tiver monstros no GY
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.immcon)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- Efeito 3: Início da Battle Phase: Enviar Equip Spells para ganhar ataques adicionais
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE | PHASE_BATTLE_START)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(s.atkcost)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)

    -- Efeito 4: (Efeito Rápido) Destruir cartas até o número de Equip Spells equipadas
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E | TIMING_MAIN_END)
    e4:SetCountLimit(1, {id, 2})
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)

    -- Efeito 5: End Phase: Equipar até 2 Equip Spells do GY
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_EQUIP)
    e5:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetCode(EVENT_PHASE | PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, {id, 3})
    e5:SetTarget(s.eqtg)
    e5:SetOperation(s.eqop)
    c:RegisterEffect(e5)
end

-- Lista a Magia de Ritual e a Guardian Eatos original para o motor de busca do jogo
s.listed_names = {777006130, 34022290}

-- ==========================================================
-- Efeito 2: Imunidade a Efeitos Ativados
-- ==========================================================
function s.immcon(e)
    return Duel.GetMatchingGroupCount(Card.IsMonster, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, nil) == 0
end

function s.efilter(e, te)
    -- Checa se o efeito pertence ao oponente e se foi ativado, ignorando assim Efeitos Contínuos
    local type = te:GetType()
    local is_activated = (type & (EFFECT_TYPE_ACTIVATE | EFFECT_TYPE_IGNITION | EFFECT_TYPE_QUICK_O | EFFECT_TYPE_QUICK_F | EFFECT_TYPE_TRIGGER_O | EFFECT_TYPE_TRIGGER_F)) ~= 0
    return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and is_activated
end

-- ==========================================================
-- Efeito 3: Ganho de Ataques Extras
-- ==========================================================
function s.atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    -- Filtra as cartas equipadas que podem ser enviadas para o cemitério
    local g = c:GetEquipGroup():Filter(Card.IsAbleToGraveAsCost, nil)
    if chk == 0 then return #g > 0 end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    -- Permite selecionar qualquer número
    local sg = g:Select(tp, 1, #g, nil)
    Duel.SendtoGrave(sg, REASON_COST)
    -- Salva o número de cartas enviadas para aplicar o bônus
    e:SetLabel(#sg)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() and ct > 0 then
        -- Concede os ataques suplementares correspondentes
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(ct)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- ==========================================================
-- Efeito 4: Destruição (Efeito Rápido)
-- ==========================================================
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    -- Conta quantas cartas estão equipadas a esta carta
    local ct = e:GetHandler():GetEquipCount()
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsOnField() end
    if chk == 0 then return ct > 0 and Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    -- Seleciona até o número de equipamentos (de 1 até ct)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito 5: Equipar na End Phase
-- ==========================================================
function s.eqfilter(c, ec)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:CheckEquipTarget(ec)
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc, c) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
        and Duel.IsExistingTarget(s.eqfilter, tp, LOCATION_GRAVE, 0, 1, nil, c) end
        
    -- Garante que o jogo não tente selecionar mais cartas do que existem espaços livres nas S&T Zones
    local ft = Duel.GetLocationCount(tp, LOCATION_SZONE)
    if ft > 2 then ft = 2 end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.eqfilter, tp, LOCATION_GRAVE, 0, 1, ft, nil, c)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    
    local g = Duel.GetTargetCards(e)
    local ft = Duel.GetLocationCount(tp, LOCATION_SZONE)
    if ft < #g then return end
    
    for tc in aux.Next(g) do
        -- Duel.Equip usa true, true no final para preparar a alocação múltipla sem interrupções
        Duel.Equip(tp, tc, c, true, true)
    end
    Duel.EquipComplete() -- Finaliza a rotina de equipamentos simultâneos de forma oficial
end