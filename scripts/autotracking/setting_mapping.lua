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
        code = "reveal_hidden_item_setting",
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
    }
}