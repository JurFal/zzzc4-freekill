local extension = Package("zzzc4")
--[[local zzzc4_pao = require "packages/zzzc4/zzzc4_pao"
local zzzc4_xue = require "packages/zzzc4/zzzc4_xue"]]
local U = require "packages/utility/utility"


Fk:loadTranslationTable{
    ["zzzc4"] = "班杀",
    ["zzz"] = "紫",
  }



local zzz_youya = General(extension, "zzz_youya", "zzz", 3, 3, General.Female)
--[[
local biyue = fk.CreateTriggerSkill{
  name = "biyue",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local bingzheng = fk.CreateTriggerSkill{
  name = "bingzheng",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      not table.every(player.room:getAlivePlayers(), function(p) return p:getHandcardNum() == p.hp end)
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(table.filter(player.room:getAlivePlayers(), function(p)
      return p:getHandcardNum() ~= p.hp end), Util.IdMapper), 1, 1, "#bingzheng-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choices = {"bingzheng_draw"}
    if not to:isKongcheng() then
      table.insert(choices, 1, "bingzheng_discard")
    end
    local choice = room:askForChoice(player, choices, self.name, "#bingzheng-choice::"..to.id)
    if choice == "bingzheng_draw" then
      to:drawCards(1, self.name)
    else
      room:askForDiscard(to, 1, 1, false, self.name, false)
    end
    if #to.player_cards[Player.Hand] == to.hp then
      player:drawCards(1, self.name)
      if to ~= player then
        local card = room:askForCard(player, 1, 1, true, self.name, true, ".", "#bingzheng-card::"..to.id)
        if #card > 0 then
          room:obtainCard(to, card[1], false, fk.ReasonGive)
        end
      end
    end
  end,
}
local ty__langmie = fk.CreateTriggerSkill{
  name = "ty__langmie",
  mute = true,
  events = {fk.EventPhaseEnd, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player then
      if event == fk.EventPhaseEnd and target.phase == Player.Play then
        local count = {0, 0, 0}
        player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
          local use = e.data[1]
          if use.from == target.id then
            if use.card.type == Card.TypeBasic then
              count[1] = count[1] + 1
            elseif use.card.type == Card.TypeTrick then
              count[2] = count[2] + 1
            elseif use.card.type == Card.TypeEquip then
              count[3] = count[3] + 1
            end
          end
        end, Player.HistoryPhase)
        return table.find(count, function(i) return i > 1 end)
      elseif event == fk.EventPhaseStart and target.phase == Player.Finish and not player:isNude() then
        local n = 0
        player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 999, function(e)
          local damage = e.data[5]
          if damage and target == damage.from then
            n = n + damage.damage
          end
        end, Player.HistoryTurn)
        return n > 1
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.EventPhaseEnd then
      return player.room:askForSkillInvoke(player, self.name, nil, "#ty__langmie-draw")
    elseif event == fk.EventPhaseStart then
      local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#ty__langmie-damage::"..target.id, true)
      if #card > 0 then
        self.cost_data = card
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.EventPhaseEnd then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    elseif event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "offensive")
      room:doIndicate(player.id, {target.id})
      room:throwCard(self.cost_data, self.name, player, player)
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
]]
local zzz_yyouya = fk.CreateTriggerSkill{
    name = "zzz_yyouya",
    anim_type = "drawcard",
    events = {fk.TurnEnd},
    can_trigger = function(self, event, target, player, data)
      return player:hasSkill(self) and player:getHandcardNum() ~= player.hp
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      if not player:hasSkill(self) then return end
      if player:getHandcardNum() < player.hp then
        player:drawCards(1, self.name)
      elseif player:getHandcardNum() > player.hp and player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    end
}
  
zzz_youya:addSkill(zzz_yyouya)
zzz_youya:addSkill("songci")

Fk:loadTranslationTable{
  ["zzz_youya"] = "尤雅",
  ["#zzz_youya"] = "诗画怡红",
  ["designer:zzz_youya"] = "zlc",
	["illustrator:zzz_youya"] = "msh",
	["zzz_yyouya"] = "优雅",
	[":zzz_yyouya"] = "一名角色的回合结束时，若你的手牌数小于体力值，你可以摸一张牌；若你的手牌数大于体力值，你可以回复1点体力。",
}


zzz_zhengyuxiang = General(extension, "zzz_zhengyuxiang", "zzz", 4, 4, General.Male)

--[[local fenyin = fk.CreateTriggerSkill{
  name = "fenyin",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase < Player.NotActive and self.can_fenyin
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,

  refresh_events = {fk.CardUsing, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.NotActive
    else
      return player.phase < Player.NotActive -- FIXME: this is a bug of FK 0.0.2!!
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:setPlayerMark(player, self.name, 0)
      room:setPlayerMark(player, "@" .. self.name, 0)
    else
      self.can_fenyin = data.card.color ~= player:getMark(self.name) and player:getMark(self.name) ~= 0
      room:setPlayerMark(player, self.name, data.card.color)
      room:setPlayerMark(player, "@" .. self.name, data.card:getColorString())
    end
  end,
}
local shijian = fk.CreateTriggerSkill{
  name = "shijian",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(self) and target.phase == Player.Play and not player:isNude() and not target:hasSkill("yuxu",true) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
        local use = e.data[1]
        return use.from == target.id
      end, Player.HistoryPhase)
      return #events == 2 and events[2].data[1] == data
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#shijian-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    room:handleAddLoseSkills(target, "yuxu")
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(target, "-yuxu")
    end)
  end,
}
local liuzan = General(extension, "ty__liuzan", "wu", 4)
local ty__fenyin = fk.CreateTriggerSkill{
  name = "ty__fenyin",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase ~= Player.NotActive then
      local mark = U.getMark(player, "@fenyin_suits-turn")
      if #mark > 3 then return false end
      local suits = {}
      local suit = ""
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            suit = Fk:getCardById(info.cardId):getSuitString(true)
            if suit ~= "log_nosuit" and not table.contains(mark, suit) then
              table.insertIfNeed(suits, suit)
            end
          end
        end
      end
      if #suits > 0 then
        self.cost_data = suits
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local mark = U.getMark(player, "@fenyin_suits-turn")
    table.insertTable(mark, self.cost_data)
    player.room:setPlayerMark(player, "@fenyin_suits-turn", mark)
    player:drawCards(#self.cost_data, self.name)
  end,
}
local liji = fk.CreateActiveSkill{
  name = "liji",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    local mark = U.getMark(player, "@liji-turn")
    return #mark > 0 and mark[1] > 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local mark = U.getMark(player, "@liji-turn")
    mark[1] = mark[1] - 1
    room:setPlayerMark(player, "@liji-turn", mark)
    room:throwCard(effect.cards, self.name, player, player)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}

local liji_record = fk.CreateTriggerSkill{
  name = "#liji_record",

  refresh_events = {fk.TurnStart, fk.EventPhaseStart, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return player == target
    else
      return player.room.current == player and not player.dead and #U.getMark(player, "@liji-turn") == 5
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      if player:hasSkill(self, true) then
        player.room:setPlayerMark(player, "@liji-turn", {0, "-", 0, "/", #player.room.alive_players < 5 and 4 or 8})
      end
    elseif event == fk.EventPhaseStart then
      local mark = U.getMark(player, "@liji-turn")
      mark[1] = player:getMark("liji_times-turn")
      player.room:setPlayerMark(player, "@liji-turn", mark)
    else
      local mark = U.getMark(player, "@liji-turn")
      local x = mark[3]
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          x = x + #move.moveInfo
        end
      end
      mark[1] = mark[1] + x // mark[5]
      player.room:addPlayerMark(player, "liji_times-turn", x // mark[5])
      mark[3] = x % mark[5]
      player.room:setPlayerMark(player, "@liji-turn", mark)
    end
  end,
]]

zzz_daimeng = fk.CreateTriggerSkill{
	name = "zzz_daimeng",
	frequency = Skill.Compulsory,
	events = {fk.CardUsing},
	can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
        local use = e.data[1]
        return use.from == player.id
      end, Player.HistoryPhase)
      return (#events == 2 and events[2].data[1] == data) or (#events == 1 and events[1].data[1] == data)
    end
  end,
	on_use = function(self, event, player, data, room)
		if player:hasSkill(self) then
      local mark = player:getMark("@zzz_daimeng-turn")
      if mark == 0 then
        player:addMark("@zzz_daimeng-turn", 1)
				player:drawCards(2, self.name)
			else
        player:addMark("@zzz_daimeng-turn", 1)
				player.room:askForDiscard(player, 3, 3, true, self.name, false)
			end
		end
		return false
	end
}

--[[local pingkou = fk.CreateTriggerSkill{
  name = "pingkou",
  mute = true,
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and type(player.skipped_phases) == "table"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, phase in ipairs({Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish}) do
      if player.skipped_phases[phase] then
        n = n + 1
      end
    end
    local targets = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper),
      1, n, "#pingkou-choose:::"..n, self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
local luoying = fk.CreateTriggerSkill{
  name = "luoying",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).suit == Card.Club and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          elseif move.moveReason == fk.ReasonJudge then
            local judge_event = room.logic:getCurrentEvent():findParent(GameEvent.Judge)
            if judge_event and judge_event.data[1].who ~= player then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.Processing and Fk:getCardById(info.cardId).suit == Card.Club and
                room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(self.cost_data)
    if #ids > 1 then
      local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, self.name,
      "#luoying-choose", {"get_all"}, 1, #ids)
      if #cards > 0 then
        ids = cards
      end
    end
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonPrey, self.name)
  end,
}
]]

zzz_qiangzhuang = fk.CreateTriggerSkill{
	name = "zzz_qiangzhuang",
  anim_type = "offensive",
	events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local types = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonDiscard and move.from and move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(types, Fk:getCardById(info.cardId).type)
          end
        end
      end
      if #types == 3 then
        return true
      end
    end
  end,
	on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), Util.IdMapper),
      1, 1, "#zzz_qiangzhuang-choose", self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
	end,
}
zzz_zhengyuxiang:addSkill(zzz_daimeng)
zzz_zhengyuxiang:addSkill(zzz_qiangzhuang)

Fk:loadTranslationTable{
  ["zzz_zhengyuxiang"] = "郑宇翔",
  ["#zzz_zhengyuxiang"] = "菜的一匹",
  ["designer:zzz_zhengyuxiang"] = "yzy",
	["zzz_daimeng"] = "呆萌",
	[":zzz_daimeng"] = "锁定技，你于一名角色的回合内使用第一张牌时摸两张牌，使用本回合内第二张牌时弃置三张牌。",
  ["zzz_qiangzhuang"] = "强壮",
	[":zzz_qiangzhuang"] = "你因弃置失去牌时，若其中包含所有类别的牌，你可以对一名角色造成1点伤害。",
  ["#zzz_qiangzhuang-choose"] = "强壮：请对一名角色造成1点伤害",
}



return {
    extension,
    --[[zzzc4_pao,
    zzzc4_xue,]]
}

