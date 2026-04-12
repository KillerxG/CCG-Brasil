--Pumpkin Farm
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Neither Player can Special Summon Link
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1, 1)
    e2:SetTarget(s.splimit)
    c:RegisterEffect(e2)
	--(2)Unaffected
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
	--(3)You cannot activate Field Spells
	local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1, 0)
    e4:SetValue(s.aclimit)
    c:RegisterEffect(e4)
	--(4)Discard 1 card
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTarget(s.tgtg)
    e5:SetOperation(s.tgop)
    c:RegisterEffect(e5)
	--(5)Your or your opponent Lose LP
	local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 1))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetTarget(s.lptg)
    e6:SetOperation(s.lpop)
    c:RegisterEffect(e6)
	--(6)Negate directly attack
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 2))
    e7:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_ATTACK_ANNOUNCE)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1)
    e7:SetCondition(s.negcon)
    e7:SetOperation(s.negop)
    c:RegisterEffect(e7)
	--(7)Call ???
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,6))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.tktg)
	e8:SetOperation(s.tkop)
	c:RegisterEffect(e8)
	Aqui está o script para a sua Magia de Campo de suporte à Predaplant Chimerafflesia.

Como você pediu, iniciei as variáveis a partir do e9, para que você possa simplesmente colar este trecho abaixo das oito primeiras habilidades restritivas de Magia de Campo que utilizamos como base nas cartas anteriores.

Para a mudança de posição, apliquei o filtro padrão e absoluto do motor de jogo c:IsCanTurnSet(), que automaticamente já barra que o jogador escolha ilegalmente Monstros Link ou Fichas (Tokens) como alvo do efeito, impedindo qualquer bug ou travamento na partida. Na rotina de cura, usei a verificação de topologia (tc:IsType(TYPE_XYZ)) para extrair a Classe, ou tc:GetLevel() para os demais.

Lua
-- Predaplant Chimerafflesia (Field Spell Support)
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- *Cole os efeitos de e1 a e8 da sua base aqui em cima*

    -- Efeito 1 (e9): Monstros Plant e Insect ganham 500 de ATK
    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_UPDATE_ATTACK)
    e9:SetRange(LOCATION_FZONE)
    e9:SetTargetRange(LOCATION_MZONE, 0)
    -- Aplica o bônus simultaneamente usando o operador bitwise
    e9:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_PLANT | RACE_INSECT))
    e9:SetValue(500)
    c:RegisterEffect(e9)

    -- Efeito 2 (e10): Banir 1 Plant do GY, colocar monstro inimigo com face para baixo
    local e10 = Effect.CreateEffect(c)
    e10:SetDescription(aux.Stringid(id, 7))
    e10:SetCategory(CATEGORY_POSITION)
    e10:SetType(EFFECT_TYPE_IGNITION)
    e10:SetRange(LOCATION_FZONE)
    e10:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e10:SetCost(s.poscost)
    e10:SetTarget(s.postg)
    e10:SetOperation(s.posop)
    c:RegisterEffect(e10)

    -- Efeito 3 (e11): Uma vez por turno, ganhar LP igual ao Level/Rank x 200 de uma Planta
    local e11 = Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(id, 8))
    e11:SetCategory(CATEGORY_RECOVER)
    e11:SetType(EFFECT_TYPE_IGNITION)
    e11:SetRange(LOCATION_FZONE)
    e11:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e11:SetCountLimit(1)
    e11:SetTarget(s.rectg)
    e11:SetOperation(s.recop)
    c:RegisterEffect(e11)

    -- Efeito 4 (e12): "Predaplant Chimerafflesia" é inafetada por efeitos de cartas
    local e12 = Effect.CreateEffect(c)
    e12:SetType(EFFECT_TYPE_FIELD)
    e12:SetCode(EFFECT_IMMUNE_EFFECT)
    e12:SetRange(LOCATION_FZONE)
    e12:SetTargetRange(LOCATION_MZONE, 0)
    e12:SetTarget(aux.TargetBoolFunction(Card.IsCode, 25586143))
    e12:SetValue(s.efilter)
    c:RegisterEffect(e12)

    -- Efeito 5 (e13): "Predaplant Chimerafflesia" pode atacar diretamente
    local e13 = Effect.CreateEffect(c)
    e13:SetType(EFFECT_TYPE_FIELD)
    e13:SetCode(EFFECT_DIRECT_ATTACK)
    e13:SetRange(LOCATION_FZONE)
    e13:SetTargetRange(LOCATION_MZONE, 0)
    e13:SetTarget(aux.TargetBoolFunction(Card.IsCode, 25586143))
    c:RegisterEffect(e13)
end
s.af="a"
s.tableAction = {
150000024,150000001,150000002,150000003,150000004,150000020,150000021,150000030,
150000033,150000005,150000006,150000009,150000010,150000022,150000023,150000031,
150000042,150000011,150000012,150000014,150000015,150000025,150000026,150000032,
150000071,150000016,150000017,150000018,150000019,150000028,150000029,150000035,
150000013,150000038,150000040
}
--(1)Neither Player can Special Summon Link
function s.splimit(e, c)
    return c:IsType(TYPE_LINK)
end
--(3)You cannot activate Field Spells
function s.aclimit(e, re, tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_FIELD)
end
--(4)Discard 1 card
function s.tgfilter(c)
    return c:IsAbleToGrave()
end
function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND)
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
--(5)Your or your opponent Lose LP
function s.lptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NUMBER)
    local num = Duel.AnnounceNumber(tp, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200)
    Duel.SetTargetParam(num)
end
function s.lpop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end    
    local num = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)    
    local op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
    local target_player = (op == 0) and tp or (1 - tp)    
    local current_lp = Duel.GetLP(target_player)
    local new_lp = math.max(0, current_lp - num)
    Duel.SetLP(target_player, new_lp)
end
--(6)Negate directly attack
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp) and Duel.GetAttackTarget() == nil
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
end
--(7)Call ???
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local token=Duel.CreateToken(tp,25586143)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ==========================================================
-- Efeito (e10): Custo e Mudança de Posição
-- ==========================================================
function s.cfilter(c)
    return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end

function s.poscost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.posfilter(c)
    -- IsCanTurnSet() assegura matematicamente e pelas regras que Links/Tokens sejam ignorados
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.postg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.posfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.posfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local g = Duel.SelectTarget(tp, s.posfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end

function s.posop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
    end
end

-- ==========================================================
-- Efeito (e11): Recuperar LP Baseado em Classificação
-- ==========================================================
function s.recfilter(c)
    -- HasLevel garante que ele consiga ler monstros sem bugar, e IsType resolve para monstros Xyz
    return c:IsFaceup() and c:IsRace(RACE_PLANT) and (c:HasLevel() or c:IsType(TYPE_XYZ))
end

function s.rectg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.recfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.recfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.recfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    
    -- Calcula a promessa de vida na janela de pré-resolução caso alguma carta possa responder à quantia de cura
    local tc = g:GetFirst()
    local val = 0
    if tc:IsType(TYPE_XYZ) then
        val = tc:GetRank() * 200
    else
        val = tc:GetLevel() * 200
    end
    
    Duel.SetTargetParam(val)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, val)
end

function s.recop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Recalcula para garantir o ganho correto de LP caso o Rank/Level tenha mudado na Corrente
        local val = 0
        if tc:IsType(TYPE_XYZ) then
            val = tc:GetRank() * 200
        else
            val = tc:GetLevel() * 200
        end
        Duel.Recover(tp, val, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito (e12): Imunidade da Predaplant Chimerafflesia
-- ==========================================================
function s.efilter(e, te)
    return te:GetOwner() ~= e:GetOwner()
end