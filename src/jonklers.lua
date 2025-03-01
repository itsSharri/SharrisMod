local mod = SMODS.current_mod
SMODS.Atlas({key = "sharrijokers", path = "sharrijokers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()

local function contains(table_, value)
    for _, v in pairs(table_) do
        if v == value then
            return true
        end
    end

    return false
end
local function sum_levels()
    return ((G.GAME.hands['High Card'].level)+(G.GAME.hands['Pair'].level)+(G.GAME.hands['Two Pair'].level)+(G.GAME.hands['Three of a Kind'].level)+(G.GAME.hands['Straight'].level)+(G.GAME.hands['Flush'].level)+(G.GAME.hands['Full House'].level )+(G.GAME.hands['Four of a Kind'].level)+(G.GAME.hands['Straight Flush'].level)+(G.GAME.hands['Five of a Kind'].level)+(G.GAME.hands['Flush House'].level)+(G.GAME.hands['Flush Five'].level))
end

SMODS.Joker{ -- Pink Joker
    name = "Pink Joker",
    key = "j_sha_pinkjoker",
    config = {
        extra = {
            mult = 0,
            m_gain = 2
        }
    },
    loc_txt = {
        ['name'] = 'Pink Joker',
        ['text'] = {
            [1] = 'This Joker gains {C:mult}+#2#{} Mult for each',
            [2] = 'hand remaining at end of round',
            [3] = '{C:inactive}(Currently {}{C:mult}+#1#{C:inactive} Mult)'
        }
    },
    pos = {x = 0, y = 0},
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.mult, card.ability.extra.m_gain}}
    end,

    calculate = function(self, card, context)

        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
            if (G.GAME.current_round.hands_left > 0) then
                card.ability.extra.mult = card.ability.extra.mult + G.GAME.current_round.hands_left*card.ability.extra.m_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED
                }
            end
        
        elseif context.cardarea == G.jokers and context.joker_main and context.scoring_hand and card.ability.extra.mult > 1 then
            return{
                colour = G.C.RED,
                message = "+"..card.ability.extra.mult.." Mult",
                mult_mod = card.ability.extra.mult,
            }
        end
    end
}

SMODS.Joker{ --Quick Buck
    name = "Quick Buck",
    key = "j_sha_quickbuck",
    config = {
        extra = {
            money = 0
        }
    },
    loc_txt = {
        ['name'] = 'Quick Buck',
        ['text'] = {
            [1] = 'If {C:attention}Blind{} is defeated in only',
            [2] = '{C:attention}1{} hand, gives money equal to {C:attention}double{}',
            [3] = 'earned from {C:attention}interest{} and {C:attention}hands{}',
        }
    },
    pos = {x = 1, y = 0},
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.money}}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition then
            if (G.GAME.current_round.hands_played == 1) then
                local total_dollars = G.GAME.dollars + (G.GAME.dollar_buffer or 0)
                local base_interest = math.floor(total_dollars/5)
                if G.GAME.modifiers.no_interest == true then --for Green Deck
                    card.ability.extra.money = G.GAME.current_round.hands_left*4
                end
                if base_interest >= 1 then
                    if total_dollars > G.GAME.interest_cap then
                        card.ability.extra.money = G.GAME.current_round.hands_left*2 + math.floor(G.GAME.interest_cap/5)*2
                    else
                        card.ability.extra.money = G.GAME.current_round.hands_left*2 + base_interest*2
                    end
                else
                    card.ability.extra.money = G.GAME.current_round.hands_left*2
                end
            else
                card.ability.extra.money = 0
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        if card.ability.extra.money > 0 then
            return card.ability.extra.money
        end
    end
}


SMODS.Joker{ --Stage Lights
    name = "Stage Lights",
    key = "j_sha_stagelights",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Stage Lights',
        ['text'] = {
            [1] = 'Played cards which are {C:attention}unscored',
            [2] = 'become {V:1}#1#{} cards,',
            [3] = "{s:0.8}suit changes at end of round"
        }
    },
    pos = {x = 2, y = 0},
    cost = 5,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.GAME.current_round.stagelights_card.suit, 'suits_singular'), colours = {G.C.SUITS[G.GAME.current_round.stagelights_card.suit]}}}
    end,

    calculate = function(self, card, context)
        local is_scored = false
        if context.before and not context.blueprint then
            for k, v in ipairs(context.full_hand) do
                if context.scoring_hand then
                    for _, scored_card in ipairs(context.scoring_hand) do
                        if v == scored_card then
                            is_scored = true
                            break
                        end
                    end
                end
                if not is_scored then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:change_suit(G.GAME.current_round.stagelights_card.suit)
                            v:juice_up()
                            return true
                        end
                    }))
                end
            end
        end
    end
}

local igo = Game.init_game_object
function Game:init_game_object()
  local ret = igo(self)
  ret.current_round.stagelights_card = { suit = 'Spades' } 
  return ret
end

function SMODS.current_mod.reset_game_globals(run_start)
    G.GAME.current_round.stagelights_card = { suit = 'Spades' }
    local stagelights_suits = {}
    for k, v in ipairs({'Spades','Hearts','Clubs','Diamonds'}) do
        if v ~= G.GAME.current_round.stagelights_card.suit then -- Abstracted enhancement check for jokers being able to give cards additional enhancements
            stagelights_suits[#stagelights_suits+1] = v
        end
    end
    local stagelights_card = pseudorandom_element(stagelights_suits, pseudoseed('stg'..G.GAME.round_resets.ante))
    G.GAME.current_round.stagelights_card.suit = stagelights_card
end

SMODS.Joker{ --Tesseract
    name = "Tesseract",
    key = "j_sha_tesseract",
    config = {
        extra = {
            xmult = 1.25
        }
    },
    loc_txt = {
        ['name'] = 'Tesseract',
        ['text'] = {
            [1] = 'Each played {C:attention}2{}, {C:attention}4{}, or {C:attention}8{} gives',
            [2] = '{X:mult,C:white}X#1#{} Mult when scored',
        }
    },
    pos = {x = 3, y = 0},
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 2 or context.other_card:get_id() == 4 or context.other_card:get_id() == 8 then
                return {
                    x_mult = card.ability.extra.xmult,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker{ --Kleptomaniac
--shoutout to my 4th grade math teacher whom i stole a deck of cards from
    name = "Kleptomaniac",
    key = "j_sha_klepto",
    config = {
        extra = {
            chips = 0,
            chip_gain = 5,
            steal = -30
        }
    },
    loc_txt = {
        ['name'] = 'Kleptomaniac',
        ['text'] = {
            [1] = 'This Joker gains {C:chips}+#2#{} Chips',
            [2] = 'for each scored {C:attention}Bonus Card{},',
            [3] = '{C:attention}Bonus Cards{} lose their {C:chips}+30{} Chips',
            [4] = '{C:inactive}(Currently {C:chips}+#1#{}{C:inactive} Chips)'
        }
    },
    pos = {x = 4, y = 0},
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        return {vars = {card.ability.extra.chips, card.ability.extra.chip_gain, card.ability.extra.steal}}
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual and not context.blueprint then
            if context.other_card.ability and context.other_card.ability.name == 'Bonus' or (context.other_card.ability.name == 'Mult' and next(find_joker("Bullseye"))) then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                return {
                    chips = card.ability.extra.steal,
                    extra = {message = 'Stolen!', colour = G.C.CHIPS},
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        elseif context.cardarea == G.jokers and context.joker_main then
            return {
                message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips, 
                colour = G.C.CHIPS
            }

        end
    end
}

SMODS.Joker{ --Three-Leaf Clover
    name = "Three-Leaf Clover",
    key = "j_sha_clover",
    config = {
        extra = {
            chips = 0,
            chip_gain = 6
        }
    },
    loc_txt = {
        ['name'] = 'Three-Leaf Clover',
        ['text'] = {
            [1] = 'This Joker gains {C:chips}+#2#{} Chips',
            [2] = 'when a {C:attention}Lucky Card{} or',
            [3] = '{C:tarot}Wheel of Fortune{} {C:red}fails{}',
            [4] = '{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips)'
        }
    },
    pos = {x = 5, y = 0},
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        info_queue[#info_queue+1] = G.P_CENTERS.c_wheel_of_fortune
        return {vars = {card.ability.extra.chips, card.ability.extra.chip_gain}}
    end,

    calculate = function(self, card, context)
        if not context.blueprint and not context.repetition then
            if context.consumeable then
                if context.consumeable.ability.name == "The Wheel of Fortune" and context.consumeable.sha_wheel_nope then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                    return{
                        extra = {focus = card, message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                        card = card
                    }
                end
            elseif context.cardarea == G.play and context.other_card.ability then
                if context.other_card.ability.name == 'Lucky Card' then
                    if not context.other_card.lucky_trigger then
                        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                        return{
                            extra = {focus = card, message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                            card = card
                        }
                    end
                end
            end
        end
        if context.cardarea == G.jokers and context.joker_main then
            return{
                colour = G.C.CHIPS,
                message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
            }
        end
    end

}

SMODS.Joker{ --Retrograde
    name = "Retrograde",
    key = "j_sha_retrograde",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Retrograde',
        ['text'] = {
            [1] = 'When {C:attention}Blind{} is selected,',
            [2] = '{C:red}decrease{} the level of a random',
            [3] = '{C:attention}poker hand{} and create a {C:dark_edition}Negative{}',
            [4] = 'copy of its {C:planet}Planet{} card'
        }
    },
    pos = {x = 6, y = 0},
    cost = 8,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        return {vars = {}}
    end,

    calculate = function(self, card, context)

        if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
            local valid_hands = {}
            for hand_name, hand_data in pairs(G.GAME.hands) do
                if hand_data.level > 1 then
                    table.insert(valid_hands, hand_name)
                end
            end

            if #valid_hands == 0 then
                return true
            end

            local chosen_hand = pseudorandom_element(valid_hands, pseudoseed("retro"))
            local hand_data = G.GAME.hands[chosen_hand]
            
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Level Down!"})
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = localize(chosen_hand, 'poker_hands'), chips = hand_data.chips, mult = hand_data.mult, level = hand_data.level})
            level_up_hand(context.blueprint_card or card, chosen_hand, nil, -1) -- Decrease level by 1
            update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    local planet_key = nil
                    for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                        if v.config.hand_type == chosen_hand then
                            planet_key = v.key
                            break
                        end
                    end

                    if planet_key then
                        local card = create_card("Planet", G.consumeables, nil, nil, nil, nil, planet_key, "retro")
                        card:set_edition("e_negative", true) 
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                return true
                end
            }))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
        end
    end
}

SMODS.Joker{ --Chocolate Bar
    name = "Chocolate Bar",
    key = "j_sha_choco",
    config = {
        extra = {
            tags = 3,
        }
    },
    loc_txt = {
        ['name'] = 'Chocolate Bar',
        ['text'] = {
            [1] = 'Create {C:attention}#1#{} random {C:attention}Tags{}',
            [2] = 'at end of round,',
            [3] = 'reduces by {C:red}1{} every round',
        }
    },
    pos = {x = 7, y = 0},
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.tags}}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            if card.ability.extra.tags <= 0 then
                return
            end
            for i = 1, card.ability.extra.tags do
				local tag = Tag(get_next_tag_key("choco"))
				if tag.name == "Orbital Tag" then
					local _poker_hands = {}
					for k, v in pairs(G.GAME.hands) do
						if v.visible then
							_poker_hands[#_poker_hands + 1] = k
						end
					end
					tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed("choco"))
				end
                if tag.name == "Boss Tag" then
					i = i - 1 --the Cryptid code I refrenced for this said that Boss Tags cause issues so I'm skipping them the same way it did
				else
					add_tag(tag)
				end
            end
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "+"..card.ability.extra.tags.." Tags",
                    colour = G.C.ORANGE,
                card = card,
            })
            if not context.blueprint then
                card.ability.extra.tags = card.ability.extra.tags - 1
                if card.ability.extra.tags <= 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                func = function()
                                        G.jokers:remove_card(card)
                                        card:remove()
                                        card = nil
                                    return true; end})) 
                            return true
                        end
                    })) 
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = localize('k_eaten_ex'),
                            colour = G.C.RED,
                        card = card,
                    })
                elseif card.ability.extra.tags > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "-1 Tag",
                            colour = G.C.RED,
                        card = card,
                    })
                end
            end
        end
    end
}

SMODS.Joker{ --Blank Slate
    name = "Blank Slate",
    key = "j_sha_blankslate",
    config = {
        extra = {
            mult = 0,
            m_gain = 2,
        }
    },
    loc_txt = {
        ['name'] = 'Blank Slate',
        ['text'] = {
            [1] = 'This Joker gains {C:mult}+#2#{} Mult for',
            [2] = 'each card scored without an',
            [3] = '{C:enhanced}Enhancement{}, {C:dark_edition}Edition{}, or {C:attention}Seal{},',
            [4] = 'resets when {C:attention}Boss Blind{} is defeated',
            [5] = '{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)'
        }
    },
    pos = {x = 8, y = 0},
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.mult, card.ability.extra.m_gain}}
    end,

    calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.ability.name == 'Default Base' and not context.other_card.edition and not context.other_card.seal then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.m_gain
                return{
                    extra = {focus = card, message = localize('k_upgrade_ex'), colour = G.C.RED},
                    card = card
                }
            end

        elseif context.joker_main and card.ability.extra.mult > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }

        elseif context.end_of_round and G.GAME.blind.boss and card.ability.extra.mult > 0 and not context.blueprint then
            card.ability.extra.mult = 0
            return{
                message = localize('k_reset'), 
                colour = G.C.RED,
                card = card
            }
        end
    end

}

SMODS.Joker{ --Stargazer
    name = "Stargazer",
    key = "j_sha_stargazer",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Stargazer',
        ['text'] = {
            [1] = '{C:attention}Mult Cards{} create random',
            [2] = '{C:planet}Planet{} cards when scored'
        }
    },
    pos = {x = 9, y = 0},
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_mult
        return {vars = {}}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.ability.name == 'Mult' or (context.other_card.ability.name == 'Bonus' and next(find_joker("Bullseye"))) then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                return {
                    extra = {focus = context.blueprint_card or card, message = localize('k_plus_planet'), func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                    local card = create_card('Planet',G.consumeables, nil, nil, nil, nil, nil, 'star')
                                    card:add_to_deck()
                                    G.consumeables:emplace(card)
                                    G.GAME.consumeable_buffer = 0
                                return true
                            end)}))
                    end},
                    colour = G.C.SECONDARY_SET.Tarot,
                    card = card
                }
            end
        end
    end
}



SMODS.Joker{ --Alchemist
    name = "Alchemist",
    key = "j_sha_alchemist",
    config = {
        extra = {
            goldxmult = 1.5,
            steelmoney = 3
        }
    },
    loc_txt = {
        ['name'] = 'Alchemist',
        ['text'] = {
            [1] = '{C:attention}Gold Cards{} and {C:attention}Steel Cards{}',
            [2] = 'share their effects'
        }
    },
    pos = {x = 0, y = 1},
    cost = 7,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        return {vars = {card.ability.extra.goldxmult, card.ability.extra.steelmoney}}
    end,

    calculate = function(self, card, context)
        if context.individual and not context.blueprint then
            if context.cardarea == G.hand and not context.end_of_round then
                if context.other_card.ability and context.other_card.ability.name == 'Gold Card' then
                    return{
                        x_mult = card.ability.extra.goldxmult,
                        colour = G.C.MULT,
                        card = context.other_card
                    }
                end
            end
            if context.cardarea == G.hand and context.end_of_round then
                if context.other_card.ability and context.other_card.ability.name == 'Steel Card' then
                    delay(0.6)
                    ease_dollars(card.ability.extra.steelmoney)
                    return{
                        dollars = card.ability.extra.steelmoney,
                        colour = G.C.MONEY,
                        card = context.other_card
                    }
                end
            end
        end
    end
}

SMODS.Joker{ --Buy in Bulk
    name = "Buy in Bulk",
    key = "j_sha_buyinbulk",
    config = {
        extra = {
            discount = 2
            }
        },
    loc_txt = {
        ['name'] = 'Buy in Bulk',
        ['text'] = {
            [1] = "{C:attention}Booster Packs{} cost {C:money}$#1#{} less"
        }
    },
    pos = {x = 1, y = 1},
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.discount}}
    end
}

SMODS.Joker{ --Comfort Zone
    name = "Comfort Zone",
    key = "j_sha_comfortzone",
    config = {
        extra = {
            increase = 1,
            payout = 0
            }
        },
    loc_txt = {
        ['name'] = 'Comfort Zone',
        ['text'] = {
            [1] = "Earn {C:money}$#2#{} at end of round,",
            [2] = "increases by {C:money}$#1#{} per",
            [3] = "{C:attention}consecutive{} hand played",
            [4] = "while playing your",
            [5] = "most played {C:attention}poker hand"
        }
    },
    pos = {x = 2, y = 1},
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return{vars = {card.ability.extra.increase, card.ability.extra.payout}}
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local reset = false
            local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
            for k, v in pairs(G.GAME.hands) do
                if k ~= context.scoring_name and v.played >= play_more_than and v.visible then
                    reset = true
                end
            end
            if reset then
                if card.ability.extra.payout > 0 then
                    card.ability.extra.payout = 0
                    return {
                        card = card,
                        message = localize('k_reset')
                    }
                end
            else
                card.ability.extra.payout = card.ability.extra.payout + card.ability.extra.increase
                return nil, true
            end
        end
    end,

    calc_dollar_bonus = function(self, card)
        if card.ability.extra.payout > 0 then
            return card.ability.extra.payout
        end
    end
}

SMODS.Joker{ --Wild Cowboy
    name = "Wild Cowboy",
    key = "j_sha_cowboy",
    config = {
        extra = {
            odds = 2,
            extrareps = 1
            }
        },
    loc_txt = {
        ['name'] = 'Wild Cowboy',
        ['text'] = {
            [1] = "Retrigger all played {C:attention}Wild{}",
            [2] = "{C:attention}Cards{}, {C:green}#1# in #2#{} chance to",
            [3] = "retrigger {C:attention}#3#{} additional time"
        }
    },
    pos = {x = 3, y = 1},
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_wild
        return {vars = {G.GAME.probabilities.normal, card.ability.extra.odds, card.ability.extra.extrareps}}
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            if context.other_card.ability and context.other_card.ability.name == "Wild Card" then
                if pseudorandom('cowboy') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    return {
                        message = localize("k_again_ex"),
                        repetitions = 1 + card.ability.extra.extrareps,
                        card = card
                    }
                else
                    return {
                        message = localize("k_again_ex"),
                        repetitions = 1,
                        card = card
                    }
                end
            end
        end
    end
}

SMODS.Joker{ --Bullseye
    name = "Bullseye",
    key = "j_sha_bullseye",
    config = {
        extra = {
            multchips = 30,
            bonusmult = 4
            }
        },
    loc_txt = {
        ['name'] = 'Bullseye',
        ['text'] = {
            [1] = '{C:attention}Mult Cards{} and {C:attention}Bonus Cards{}',
            [2] = 'share their effects'
        }
    },
    pos = {x = 4, y = 1},
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_mult
        info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
        return {vars = {}}
    end,

    calculate = function(self, card, context)
        if context.individual and not context.blueprint and context.cardarea == G.play then
            if context.cardarea == G.play then
                if context.other_card.ability and context.other_card.ability.name == 'Mult' then
                    return{
                        chips = card.ability.extra.multchips,
                        colour = G.C.CHIPS,
                        card = context.other_card
                    }
                end
            end
            if context.cardarea == G.play then
                if context.other_card.ability and context.other_card.ability.name == 'Bonus' then
                    return{
                        mult = card.ability.extra.bonusmult,
                        colour = G.C.MULT,
                        card = context.other_card
                    }
                end
            end
        end
    end
}

--[[SMODS.Joker{ --Feste
    name = "Feste",
    key = "j_sha_feste",
    config = {
        extra = {
            foilchips = 50,
            holomult = 10,
            polychromexmult = 1.5,
            bonuschips = 30,
            multmult = 4,
            glassxmult = 2,
            lucky = 20,
            goldmoney = 3,
            ticketmoney = 4,
            reps = 1
        }
    },
    loc_txt = {
        ['name'] = 'Feste',
        ['text'] = {
            [1] = '{C:attention}Repeats{} the effects of all',
            [2] = '{C:enhanced}Enhancements{}, {C:dark_edition}Editions{},',
            [3] = 'and {C:attention}Seals{} on {C:attention}playing cards',
        }
    },
    pos = {x = 9, y = 2},
    soul_pos = {x = 9, y = 3},
    cost = 20,
    rarity = 4,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sharrijokers',

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.foilchips,
            card.ability.extra.holomult,
            card.ability.extra.polychromexmult,
            card.ability.extra.bonuschips,
            card.ability.extra.multmult,
            card.ability.extra.glassxmult,
            card.ability.extra.goldmoney,
            card.ability.extra.ticketmoney,
            card.ability.extra.reps
        } }
    end,

    calculate = function(self, card, context)
        local result = {card = card}
        local effect_found = false
        if context.individual and not context.blueprint then
            if context.cardarea == G.play then
                if context.other_card.ability then
                    if context.other_card.ability.name == 'Bonus' and not next(find_joker("Kleptomaniac")) then
                        result.chips = (result.chips or 0) + card.ability.extra.bonuschips
                        result.colour = G.C.CHIPS
                        print("bonus")
                        effect_found = true
                    elseif context.other_card.ability.name == 'Stone Card' then
                        result.chips = (result.chips or 0) + card.ability.extra.foilchips
                        result.colour = G.C.CHIPS
                        print("stone")
                        effect_found = true
                    elseif context.other_card.ability.name == 'Mult' then
                        result.mult = (result.mult or 0) + card.ability.extra.multmult
                        result.colour = G.C.MULT
                        print("mult")
                        effect_found = true
                    elseif context.other_card.ability.name == 'Glass Card' then
                        result.x_mult = (result.x_mult or 1) * card.ability.extra.glassxmult
                        result.colour = G.C.MULT
                        print("glass")
                        effect_found = true
                    elseif context.other_card.ability.name == 'Lucky Card' then
                        if context.other_card.sha_lucky_mult then
                            result.mult = (result.mult or 0) + card.ability.extra.lucky
                            result.colour = G.C.MULT
                            print("lucky mult")
                            effect_found = true
                        end
                        if context.other_card.sha_lucky_money then
                            result.dollars = (result.dollars or 0) + card.ability.extra.lucky
                            result.colour = G.C.MONEY
                            print("lucky money")
                            effect_found = true
                        end
                    elseif next(find_joker("Golden Ticket")) and context.other_card.ability.name == 'Gold Card' then
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.ticketmoney
                        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                        result.dollars = card.ability.extra.ticketmoney
                        result.colour = G.C.MONEY
                        print("gold w/ golden ticket")
                        effect_found = true
                    end
                end

                if context.other_card.edition then
                    if context.other_card.edition.foil == true then
                        result.chips = (result.chips or 0) + card.ability.extra.foilchips
                        result.colour = G.C.CHIPS
                        print("foil")
                            effect_found = true
                    elseif context.other_card.edition.holo == true then
                        result.mult = (result.mult or 0) + card.ability.extra.holomult
                        result.colour = G.C.MULT
                        print("holo")
                        effect_found = true
                    elseif context.other_card.edition.polychrome == true then
                        result.x_mult = (result.x_mult or 1) * card.ability.extra.polychromexmult
                        result.colour = G.C.MULT
                        print("polychrome")
                        effect_found = true
                    end
                end

                if context.other_card.seal and not context.repetition then
                    if context.other_card.seal == 'Gold' then
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.goldmoney
                        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                        result.dollars = card.ability.extra.goldmoney
                        result.color = G.C.MONEY
                        print("gold seal")
                        effect_found = true
                    end
                elseif context.other_card.seal and context.repetition and not context.repetition_only then
                    if context.other_card.seal == 'Red' then
                        result.message = localize('k_again_ex')
                        result.repetitions = card.ability.extra.reps
                        print("red seal")
                        effect_found = true
                    end
                end

            elseif context.cardarea == G.hand and not context.end_of_round then
                if context.other_card.ability then
                    if context.other_card.ability.name == 'Steel Card' then
                        result.x_mult = (result.x_mult or 1) * card.ability.extra.polychromexmult
                        result.colour = G.C.MULT
                        print("steel")
                        effect_found = true
                    end
                end

            elseif context.cardarea == G.hand and context.end_of_round then
                if context.other_card.ability then
                    if context.other_card.ability.name == 'Gold Card' then
                        ease_dollars(card.ability.extra.goldmoney)
                        result.dollars = card.ability.extra.goldmoney
                        result.color = G.C.MONEY
                        print("gold")
                        effect_found = true
                    end
                end

                if context.repetition then
                    if context.other_card.seal then
                        if context.other_card.seal == 'Blue' then
                            result.message = localize('k_again_ex')
                            result.repetitions = card.ability.extra.reps
                            card = self
                            print("blue seal")
                            effect_found = true
                        end
                    end
                end

            elseif context.discard then
                if context.other_card.seal then
                    if context.other_card.seal == 'Purple' then
                        result.message = localize('k_plus_tarot')
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({func = (function()
                            local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'fes')
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                        result.colour = G.C.SECONDARY_SET.Tarot
                        print("purple seal")
                        effect_found = true
                    end
                end
            end
        end
        if effect_found then
            return result
        end
	end
}]]
--G.P_CENTERS.j_sha_testjoker = 
--[[SMODS.Back{
    name = "Testing Deck",
    key = "testing",
    pos = {x = 1, y = 3},
    config = {testing = true},
    loc_txt = {
        name = "Testing Deck",
        text ={
            "Start with whatever {C:attention}Joker",
            "I'm currently testing"
        },
    },
    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.jokers then
                    if G.P_CENTERS then
                        local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_sha_testjoker")
                        card:add_to_deck()
                        card:start_materialize()
                        G.jokers:emplace(card)
                    end
                    return true
                end
            end
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    G.playing_cards[i]:set_ability(G.P_CENTERS.m_wild)
                    G.playing_cards[i]:set_edition({polychrome = true}, true, true)
                end
                return true
            end
        }))
    end
}]]
