---@param spriteBank SpriteBank
return function(spriteBank)
  -- NOTE: We set sprites used in the UI to the top left

  -- inventory panels
  local spriteBuilder = spriteBank.createSpriteBuilder()
  spriteBuilder:setSpriteSheet('inventory_panel')

  -- construct nine patch textures
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 1, 1, 'green_ui_9_patch')
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 4, 1, 'yellow_ui_9_patch')
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 7, 1, 'red_ui_9_patch')

  -- inventory cursors
  spriteBuilder:setSpriteSheet('inventory_cursors')
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(3, 1, -6, 0, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(4, 1, 16, 0, 0, 0))
  spriteBank.registerSprite('inventory_cursor_equipped', spriteBuilder:buildCompositeSprite())

  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(5, 1, -6, 0, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(6, 1, 16, 0, 0, 0))
  spriteBank.registerSprite('inventory_cursor_hover', spriteBuilder:buildCompositeSprite())

  -- spriteBank.registerSprite('item_panel_9', spriteBuilder:buildNinePatchSprite(greenNinePatch, 160, 192, 1))
  -- spriteBank.registerSprite('item_details_panel_9', spriteBuilder:buildNinePatchSprite(yellowNinePatch, 96, 96, 1))

  -- status bars
  spriteBuilder:setSpriteSheet('ui_bars_border_9')

  -- register bar nine patch texture
  spriteBank.createThreePatchTextureAsNine(spriteBuilder:getSpriteSheet(), 1, 1, true, 'hud_bar_border')



  -- HUD equipment section
  spriteBuilder:setSpriteSheet('ui_small')
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(5, 5, -6, 0, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(5, 6, -6, 8, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(6, 5, 16, 0, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(6, 6, 16, 8, 0, 0))
  local hudEquipmentSlot = spriteBuilder:buildCompositeSprite(0, -1, 0, 0)
  spriteBank.registerSprite('hud_equipment_slot', hudEquipmentSlot)

  -- HUD equipment slot button icons
  -- heart icons
  spriteBank.registerSprite('heart_empty', spriteBuilder:buildSprite(1, 7, 0, 0, 0, 0))
  spriteBank.registerSprite('heart_quarter', spriteBuilder:buildSprite(2, 7, 0, 0, 0, 0))
  spriteBank.registerSprite('heart_half', spriteBuilder:buildSprite(3, 7, 0, 0, 0, 0))
  spriteBank.registerSprite('heart_three_quarters', spriteBuilder:buildSprite(4, 7, 0, 0, 0, 0))
  spriteBank.registerSprite('heart_full', spriteBuilder:buildSprite(5, 7, 0, 0, 0, 0))

  -- keyboard
  spriteBank.registerSprite('pc_b_slot_button', spriteBuilder:buildSprite(2, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('pc_x_slot_button', spriteBuilder:buildSprite(5, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('pc_y_slot_button', spriteBuilder:buildSprite(1, 1, 0, 0, 0, 1))

  -- xbox
  spriteBank.registerSprite('xbox_b_slot_button', spriteBuilder:buildSprite(3, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('xbox_x_slot_button', spriteBuilder:buildSprite(5, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('xbox_y_slot_button', spriteBuilder:buildSprite(4, 1, 0, 0, 0, 1))

  -- playstation
  spriteBank.registerSprite('playstation_b_slot_button', spriteBuilder:buildSprite(6, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('playstation_x_slot_button', spriteBuilder:buildSprite(8, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('playstation_y_slot_button', spriteBuilder:buildSprite(7, 1, 0, 0, 0, 1))

  -- nintendo
  -- TODO swap the A and B button configuration for Baton on startup when a Nintendo controller is detected
  spriteBank.registerSprite('nintendo_b_slot_button', spriteBuilder:buildSprite(9, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('nintendo_x_slot_button', spriteBuilder:buildSprite(4, 1, 0, 0, 0, 1))
  spriteBank.registerSprite('nintendo_y_slot_button', spriteBuilder:buildSprite(5, 1, 0, 0, 0, 1))


  -- buttons
  spriteBuilder:setSpriteSheet('buttons_xbox')
  spriteBank.registerSprite('xbox_a_button', spriteBuilder:buildSprite(1, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_b_button', spriteBuilder:buildSprite(1, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_x_button', spriteBuilder:buildSprite(1, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_y_button', spriteBuilder:buildSprite(1, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_alt_a_button', spriteBuilder:buildSprite(2, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_alt_b_button', spriteBuilder:buildSprite(2, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_alt_x_button', spriteBuilder:buildSprite(2, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_alt_y_button', spriteBuilder:buildSprite(2, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_left_trigger_button', spriteBuilder:buildSprite(3, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_right_trigger_button', spriteBuilder:buildSprite(3, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_left_shoulder_button', spriteBuilder:buildSprite(3, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_right_shoulder_button', spriteBuilder:buildSprite(3, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_select_button', spriteBuilder:buildSprite(4, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('xbox_start_button', spriteBuilder:buildSprite(4, 2, 0, 0, 0, 0))

  spriteBuilder:setSpriteSheet('buttons_playstation')
  spriteBank.registerSprite('playstation_a_button', spriteBuilder:buildSprite(1, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_b_button', spriteBuilder:buildSprite(1, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_x_button', spriteBuilder:buildSprite(1, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_y_button', spriteBuilder:buildSprite(1, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_alt_a_button', spriteBuilder:buildSprite(2, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_alt_b_button', spriteBuilder:buildSprite(2, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_alt_x_button', spriteBuilder:buildSprite(2, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_alt_y_button', spriteBuilder:buildSprite(2, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_left_trigger_button', spriteBuilder:buildSprite(3, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_right_trigger_button', spriteBuilder:buildSprite(3, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_left_shoulder_button', spriteBuilder:buildSprite(3, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_right_shoulder_button', spriteBuilder:buildSprite(3, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_select_button', spriteBuilder:buildSprite(4, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('playstation_start_button', spriteBuilder:buildSprite(4, 2, 0, 0, 0, 0))

  spriteBuilder:setSpriteSheet('buttons_kbm')
  spriteBank.registerSprite('pc_a_button', spriteBuilder:buildSprite(1, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_b_button', spriteBuilder:buildSprite(1, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_x_button', spriteBuilder:buildSprite(1, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_y_button', spriteBuilder:buildSprite(1, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_alt_a_button', spriteBuilder:buildSprite(2, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_alt_b_button', spriteBuilder:buildSprite(2, 4, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_alt_x_button', spriteBuilder:buildSprite(2, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_alt_y_button', spriteBuilder:buildSprite(2, 3, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_left_trigger_button', spriteBuilder:buildSprite(3, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_right_trigger_button', spriteBuilder:buildSprite(3, 2, 0, 0, 0, 0))
  
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(3, 3, 0, 0, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(4, 3, 16, 0, 0, 0))
  spriteBank.registerSprite('pc_left_shoulder_button', spriteBuilder:buildCompositeSprite(0, 0))

  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(3, 4, 0, 0, 0, 0))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(4, 4, 16, 0, 0, 0))
  spriteBank.registerSprite('pc_right_shoulder_button', spriteBuilder:buildCompositeSprite(0, 0))

  spriteBank.registerSprite('pc_select_button', spriteBuilder:buildSprite(4, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('pc_start_button', spriteBuilder:buildSprite(4, 2, 0, 0, 0, 0))



  -- inventory icons
  spriteBuilder:setSpriteSheet('inventory_icons_small')
  spriteBank.registerSprite('icon_sword_1', spriteBuilder:buildSprite(1, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('icon_sword_2', spriteBuilder:buildSprite(2, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('icon_sword_3', spriteBuilder:buildSprite(3, 1, 0, 0, 0, 0))

  spriteBank.registerSprite('icon_shield_1', spriteBuilder:buildSprite(4, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('icon_shield_2', spriteBuilder:buildSprite(5, 1, 0, 0, 0, 0))
  spriteBank.registerSprite('icon_shield_3', spriteBuilder:buildSprite(6, 1, 0, 0, 0, 0))

  spriteBank.registerSprite('icon_boomerang_1', spriteBuilder:buildSprite(5, 2, 0, 0, 0, 0))
  spriteBank.registerSprite('icon_boomerang_2', spriteBuilder:buildSprite(6, 2, 0, 0, 0, 0))
end