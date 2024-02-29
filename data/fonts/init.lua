--NB: developer tool ui elements will load fonts themselves without relying on the AssetManager class
return makeModuleFunction(function(loadFontFunc)
  -- font for base screen on screen print
  loadFontFunc('data/assets/fonts/robotomono.ttf', 'base_screen_debug', 16)
  loadFontFunc('data/assets/fonts/harvest-moon-fomt.ttf', 'game_font', 12)
end)