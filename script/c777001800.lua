-- Thunder Force Trap (Nome provisório, já que Strike foi usado na Spell)
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Alvejar 1 "Thunder Force" -> Destruir inferiores/iguais -> Bônus na BP
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_BATTLE_START + TIMING_BATTLE_END)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Efeito 2: Início da Battle Phase no GY -> Dobrar Dano de Batalha
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE + PHASE_BATTLE_START)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.damcon)
    e2:SetCost(aux.bfgcost) -- Remove a carta do jogo automaticamente como custo
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Filtros de Destruição e Bônus
-- ====================================================================
function s.desfilter(c, lvl)
    -- Cartas Face-Down não têm Nível/Tipo/Atributo público, então ignoramos
    if c:IsFacedown() or c:IsRace(RACE_THUNDER) then return false end
    
    local rating = 0
    -- Extrai corretamente o valor independente se for Link, Xyz ou Monstro normal
    if c:IsType(TYPE_XYZ) then 
        rating = c:GetRank()
    elseif c:IsType(TYPE_LINK) then 
        rating = c:GetLink()
    else 
        rating = c:GetLevel() 
    end
    
    -- O valor deve ser menor ou igual ao nível do alvo
    return rating > 0 and rating <= lvl
end

function s.tgtfilter(c, tp)
    -- O monstro "Thunder Force" alvo precisa ter Nível
    -- E precisa existir pelo menos um monstro válido para destruir na hora de ativar
    return c:IsFaceup() and c:IsSetCard(0x301) and c:HasLevel()
        and Duel.IsExistingMatchingCard(s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, c, c:GetLevel())
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgtfilter(chkc, tp) end
    if chk == 0 then return Duel.IsExistingTarget(s.tgtfilter, tp, LOCATION_MZONE, 0, 1, nil, tp) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.tgtfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    
    -- Marca as cartas elegíveis para destruição para a engine calcular o prompt de aviso (se houver Stardust, etc)
    local dg = Duel.GetMatchingGroup(s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, g:GetFirst(), g:GetFirst():GetLevel())
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x301) and c:HasLevel()
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    
    local lvl = tc:GetLevel()
    local dg = Duel.GetMatchingGroup(s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, tc, lvl)
    
    -- Destrói todos que baterem no filtro
    if #dg > 0 and Duel.Destroy(dg, REASON_EFFECT) > 0 then
        
        -- Checa se a carta foi ativada durante a Battle Phase (Fase de Batalha)
        local ph = Duel.GetCurrentPhase()
        if ph >= PHASE_BATTLE_START and ph <= PHASE_BATTLE then
            
            local atkg = Duel.GetMatchingGroup(s.atkfilter, tp, LOCATION_MZONE, 0, nil)
            for ac in aux.Next(atkg) do
                local boost = ac:GetLevel() * 200
                
                -- ATK
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(boost)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                ac:RegisterEffect(e1)
                
                -- DEF
                local e2 = e1:Clone()
                e2:SetCode(EFFECT_UPDATE_DEFENSE)
                ac:RegisterEffect(e2)
            end
        end
    end
end

-- ====================================================================
-- Efeito 2: Dobrar Dano de Batalha (GY)
-- ====================================================================
function s.bossfilter(c)
    return c:IsFaceup() and c:GetOriginalCode() == 777001370
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    -- Só no início da SUA fase de batalha e com o Zeus
    return Duel.GetTurnPlayer() == tp 
        and Duel.IsExistingMatchingCard(s.bossfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    -- Cria um efeito contínuo que vai durar apenas este turno
    local c = e:GetHandler()
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e1:SetCondition(s.dblcon)
    e1:SetOperation(s.dblop)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)
end

function s.dblcon(e, tp, eg, ep, ev, re, r, rp)
    -- Verifica se quem vai tomar o dano é o oponente
    if ep == tp then return false end
    
    local a = Duel.GetAttacker()
    local d = Duel.GetAttackTarget()
    
    -- Checa se qualquer um dos monstros batalhando é SEU e é "Thunder Force"
    if a and a:IsControler(tp) and a:IsSetCard(0x301) then return true end
    if d and d:IsControler(tp) and d:IsSetCard(0x301) then return true end
    
    return false
end

function s.dblop(e, tp, eg, ep, ev, re, r, rp)
    -- Multiplica o dano de batalha por 2
    Duel.ChangeBattleDamage(ep, ev * 2)
end