local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),8,2)
	c:EnableReviveLimit()
    -- Invocação Especial alternativa do Extra Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    e1:SetValue(SUMMON_TYPE_SPECIAL)
    c:RegisterEffect(e1)

	    -- Efeito: banir topo do deck do oponente
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetCondition(s.banishcon_gy)
    e4:SetCost(s.banishcost)
    e4:SetTarget(s.banishtg)
    e4:SetOperation(s.banishop)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCondition(s.banishcon_sp)
    c:RegisterEffect(e5)
	
	--self destroy
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetCondition(s.sdcon)
	c:RegisterEffect(e6)
		--destroy top
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_LEAVE_FIELD)
    e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCountLimit(1,id+2)
	e7:SetCondition(s.dmcon)
	e7:SetOperation(s.nogyop)
	c:RegisterEffect(e7)
end

-- Condição da Invocação Especial alternativa
function s.spcon(e,c)
    if c==nil then return true end
    return s.windzombiethisturn>=5
        and Duel.GetLocationCountFromEx(c:GetControler(),c:GetControler(),nil,c)>0
        and Duel.IsExistingMatchingCard(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,1,nil,RACE_ZOMBIE)
end

-- Operação da Invocação Especial alternativa
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_GRAVE,0,1,1,nil,RACE_ZOMBIE)
    if #g>0 then
        Duel.Overlay(c,g)
	    -- Voltar ao Extra Deck na End Phase se foi invocado dessa forma
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
    end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

-- 🌪️ GLOBAL CHECK: Conta WIND Zumbis Invocados ou enviados ao GY
if not s.global_check then
    s.global_check=true
    s.windzombiethisturn=0

    -- Enviados ao GY
    local ge1=Effect.GlobalEffect()
    ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    ge1:SetCode(EVENT_TO_GRAVE)
    ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        for tc in eg:Iter() do
            if tc:IsRace(RACE_ZOMBIE) and tc:IsAttribute(ATTRIBUTE_WIND) then
                s.windzombiethisturn = s.windzombiethisturn + 1
                -- Debug opcional:
                -- Duel.Hint(HINT_MESSAGE,tp,"GY WIND Z: "..s.windzombiethisturn)
            end
        end
    end)
    Duel.RegisterEffect(ge1,0)

    -- Invocados especialmente
    local ge2=Effect.GlobalEffect()
    ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
    ge2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        for tc in eg:Iter() do
            if tc:IsRace(RACE_ZOMBIE) and tc:IsAttribute(ATTRIBUTE_WIND) then
                s.windzombiethisturn = s.windzombiethisturn + 1
                -- Debug opcional:
                -- Duel.Hint(HINT_MESSAGE,tp,"SP WIND Z: "..s.windzombiethisturn)
            end
        end
    end)
    Duel.RegisterEffect(ge2,0)

    -- Reset no começo do turno
    local ge3=Effect.GlobalEffect()
    ge3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
    ge3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        s.windzombiethisturn = 0
    end)
    Duel.RegisterEffect(ge3,0)
end
--triger
function s.banishcon_gy(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c)
        return c:IsRace(RACE_ZOMBIE) and c:IsControler(tp) and c~=e:GetHandler()
    end,1,nil)
end
function s.banishcon_sp(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c)
        return c:IsRace(RACE_ZOMBIE) and c:IsPreviousLocation(LOCATION_GRAVE)
            and c:IsControler(tp) and c~=e:GetHandler()
    end,1,nil)
end
function s.banishcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_ZOMBIE)
    if chk==0 then return ct>0 and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=ct end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_ZOMBIE)
    if ct<=0 then return end
    local g=Duel.GetDecktopGroup(1-tp,ct)
    if #g>0 then
        Duel.DisableShuffleCheck()
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
--auto destroy
-- Operação: Destrói este card e depois as 3 do topo do próprio Deck
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,RACE_ZOMBIE)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rg=Duel.GetDecktopGroup(tp,3)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and #rg>2
end
function s.nogyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
        local g=Duel.GetDecktopGroup(tp,3)
        if #g>2 then
            Duel.Destroy(g,REASON_EFFECT)
        end
end