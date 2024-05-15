--Necromorph Tormentor
local s,id=GetID()
function s.initial_effect(c)
  --Enable Necro counters collection
  c:EnableCounterPermit(0x1ff)
	--xyz summon
	Xyz.AddProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Get bonus attack from Necro counters and become inmune to activated effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atcost)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--add Necro counters on special summon
  local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
  --Destruction replacement
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)
end
--alternate XYZ summon condition
s.listed_series={0x1ff}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x1ff,lc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:GetRank()==4
end
--inmunity effect
--inmunity conditions
function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
--attack increase value
function s.atkval(e,c)
	return c:GetCounter(0x1ff)*400
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsCanRemoveCounter(tp,1,0,0x1ff,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
  Duel.RemoveCounter(tp,1,0,0x1ff,2,REASON_COST)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END, 2)
		c:RegisterEffect(e1)
    --Unaffected by opponent's activated effects
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(s.immval)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END, 2)
		c:RegisterEffect(e2)
	end
end
--add list to count Necro Counters
s.counter_place_list={0x1ff}
--specify to add Necro counters
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1ff)
end
--add the 'label' amount of Necro counters to this card
function s.addop(e,tp,eg,ep,ev,re,r,rp)
  local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1ff,3)
	end
end
--Avoid destruction by removing 1 Necro counter
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
	return not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x1ff,1,REASON_COST) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		c:RemoveCounter(tp,0x1ff,1,REASON_COST)
		return true
	else return false end
end