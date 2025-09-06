SLOT_CODES = {
    item_shuffle = {
      code = "sett_mode",
      type = "progressive",
      mapping = {
        [2] = 0, -- All chests and tablets
        [3] = 1  -- All locations
      }
    },
    reveal_hidden_item = {
        code = "reveal_hidden",
        type = "toggle"
    },
    lemurian_ship = {
        code = "lemurian_ship_setting",
        type = "progressive",
        mapping = {
            [0] = 0, -- Vanilla
            [1] = 1, -- Ship door open
            [2] = 2 -- Start with ship available
        }
    },
    start_with_wings = {
        code = "start_with_wings_setting",
        type = "toggle"
    },
    djinn_logic = {
        code = "djinn_logic_count",
        type = "consumable"
    },
    anemos_inner_sanctum_access = {
        code = "anemos_door_setting",
        type = "progressive",
        mapping = {
            [0] = 0, -- require all 72 djinn
            [1] = 1, -- require between 16 and 28 djinn
            [2] = 2 -- open without djinn
        }
    },
    shortcut_mars_lighthouse = {
        code = "mars_lighthouse_shortcut",
        type = "toggle"
    },
    shortcut_magma_rock = {
        code = "magma_rock_shortcut",
        type = "toggle"
    }
    goal = {},
    flags = {},
    counts = {}
}