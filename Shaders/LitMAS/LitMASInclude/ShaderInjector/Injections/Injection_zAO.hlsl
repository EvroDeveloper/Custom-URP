//#!INJECT_BEGIN INCLUDES 0
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VR_zAO.hlsl"
//#!INJECT_END

//#!INJECT_BEGIN PRE_FRAGDATA 1
ao *= CalculateShapeAO(i.wPos, normalWS);
//#!INJECT_END