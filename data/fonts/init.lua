--NB: developer tool ui elements will load fonts themselves without relying on the AssetManager class
return makeModuleFunction(function(loadFontFunc)
  -- font for base screen on screen print
  loadFontFunc('data/assets/fonts/robotomono.ttf', 'baseScreenDebug', 16)
  loadFontFunc('data/assets/fonts/harvest-moon-fomt.ttf', 'hm-fomt', 12)
end)