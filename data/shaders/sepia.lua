return function(shaderBank)
  local sepiaShader = love.graphics.newShader([[
    uniform int   u_color   = 0;
    uniform float u_opacity = 0.75;
    
    const vec3 SEPIA[2] = vec3[2](
      vec3(1.2, 1.0, 0.8),
      vec3(1.0, 0.95, 0.82)
    );
    
    vec4 effect(vec4 color, sampler2D texture, vec2 texCoords, vec2 screenCoords) {
      vec4 texColor = texture2D(texture, texCoords);
    
      // NTSC weights
      float grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    
      vec3 sepia = vec3(grey);
      if (u_color == 0 || u_color == 2) {
        sepia *= SEPIA[0];
      } else if (u_color == 1) {
        sepia *= SEPIA[1];
      } 
    
      texColor.rgb = mix(
        texColor.rgb,
        sepia,
        u_opacity
      );
    
      return texColor * color;
    }
  ]])
  -- TODO store in shaderbank
end