---@param spriteBank SpriteBank
return function(spriteBank)
  -- inventory panels
  local spriteBuilder = spriteBank.createSpriteBuilder()
  spriteBuilder:setSpriteSheet('inventory_panel')

  -- construct nine patch textures
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 1, 1, 'green_ui_9_patch')
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 4, 1, 'yellow_ui_9_patch')
  spriteBank.createNinePatchTexture(spriteBuilder:getSpriteSheet(), 7, 1, 'red_ui_9_patch')

  -- spriteBank.registerSprite('item_panel_9', spriteBuilder:buildNinePatchSprite(greenNinePatch, 160, 192, 1))
  -- spriteBank.registerSprite('item_details_panel_9', spriteBuilder:buildNinePatchSprite(yellowNinePatch, 96, 96, 1))

  -- status bars
  spriteBuilder:setSpriteSheet('ui_bars_border_9')

  -- register bar nine patch texture
  spriteBank.createThreePatchTextureAsNine(spriteBuilder:getSpriteSheet(), 1, 1, true, 'ui_bar_border')


  -- HUD equipment section
  spriteBuilder:setSpriteSheet('ui_small')

  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(5, 5, -16, -4))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(5, 6, -16, 4))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(6, 5, 16, -4))
  spriteBuilder:addCompositeSprite(spriteBuilder:buildSprite(6, 6, 16, 4))
  local hudEquipmentSlot = spriteBuilder:buildCompositeSprite()
  hudEquipmentSlot.offsetY = -1
  spriteBank.registerSprite('hud_equipment_slot', hudEquipmentSlot)
end