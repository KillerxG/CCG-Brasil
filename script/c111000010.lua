--Badlands
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
	e8:SetDescription(aux.Stringid(id,5))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.tktg)
	e8:SetOperation(s.tkop)
	c:RegisterEffect(e8)
	-- Efeito 1 (e9): Rock, Dinosaur e Reptile ganham 1000 de ATK
    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_UPDATE_ATTACK)
    e9:SetRange(LOCATION_FZONE)
    e9:SetTargetRange(LOCATION_MZONE, 0)
    -- Aplica o ganho para as 3 raças simultaneamente
    e9:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_ROCK | RACE_DINOSAUR | RACE_REPTILE))
    e9:SetValue(1000)
    c:RegisterEffect(e9)

    -- Efeito 2 (e10): Durante a End Phase, se controlar 3 ou mais monstros: Banir a mão face-down
    local e10 = Effect.CreateEffect(c)
    e10:SetDescription(aux.Stringid(id, 6))
    e10:SetCategory(CATEGORY_REMOVE)
    e10:SetType(EFFECT_TYPE_FIELD | EFFECT_TYPE_TRIGGER_F) -- Efeito Forçado/Obrigatório
    e10:SetCode(EVENT_PHASE | PHASE_END)
    e10:SetRange(LOCATION_FZONE)
    e10:SetCountLimit(1)
    e10:SetCondition(s.epcon)
    e10:SetTarget(s.eptg)
    e10:SetOperation(s.epop)
    c:RegisterEffect(e10)

    -- Efeito 3 (e11): "Gaia Plate the Earth Giant" é inafetado por efeitos de cartas
    local e11 = Effect.CreateEffect(c)
    e11:SetType(EFFECT_TYPE_FIELD)
    e11:SetCode(EFFECT_IMMUNE_EFFECT)
    e11:SetRange(LOCATION_FZONE)
    e11:SetTargetRange(LOCATION_MZONE, 0)
    e11:SetTarget(aux.TargetBoolFunction(Card.IsCode, 14258627))
    e11:SetValue(s.efilter)
    c:RegisterEffect(e11)

    -- Efeito 4 (e12): "Gaia Plate the Earth Giant" pode atacar o oponente diretamente
    local e12 = Effect.CreateEffect(c)
    e12:SetType(EFFECT_TYPE_FIELD)
    e12:SetCode(EFFECT_DIRECT_ATTACK)
    e12:SetRange(LOCATION_FZONE)
    e12:SetTargetRange(LOCATION_MZONE, 0)
    e12:SetTarget(aux.TargetBoolFunction(Card.IsCode, 14258627))
    c:RegisterEffect(e12)
end
s.af="a"
s.tableAction = {
111000011,111000012,111000013,111000014,111000015, --Traps Custom
150000010,150000011,150000016,150000017,150000021, --Spells Anime
111000201,111000202,111000203,111000204,111000205, --Spells Custom
111000206,111000207,111000208,111000209,111000210  --Spells Custom
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
		local token=Duel.CreateToken(tp,14258627)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ==========================================================
-- Efeito (e10): Banir mão na End Phase
-- ==========================================================
function s.epcon(e, tp, eg, ep, ev, re, r, rp)
    -- Dispara na sua própria End Phase se o número de monstros que você controla for 3 ou superior
    return Duel.GetTurnPlayer() == tp and Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) >= 3
end

function s.eptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, tp, LOCATION_HAND)
end

function s.epop(e, tp, eg, ep, ev, re, r, rp)
    -- Resgata toda a mão atual durante a resolução da corrente
    local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
    if #g > 0 then
        Duel.Remove(g, POS_FACEDOWN, REASON_EFFECT)
    end
end

-- ==========================================================
-- Efeito (e11): Imunidade exclusiva para o Gaia Plate
-- ==========================================================
function s.efilter(e, te)
    return te:GetOwner() ~= e:GetOwner()
end