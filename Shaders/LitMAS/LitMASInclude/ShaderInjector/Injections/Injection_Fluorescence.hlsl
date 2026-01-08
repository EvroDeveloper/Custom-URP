//#!INJECT_BEGIN UNIVERSAL_DEFINES 1
#define _SLZ_FLUORESCENCE
//#!INJECT_END

//#!INJECT_BEGIN UNIFORMS 0
TEXTURE2D(_FluorescenceMap);
//#!INJECT_END

//#!INJECT_BEGIN MATERIAL_CBUFFER 0
	half  _Fluorescence;
    half4 _FluorescenceColor;
    half4 _Absorbance;
//#!INJECT_END

//#!INJECT_BEGIN PBR_VALUES 1
    half3 fluorescenceColor = SAMPLE_TEXTURE2D(_FluorescenceMap, sampler_BaseMap, uv_main).rgb * _FluorescenceColor.rgb;
//#!INJECT_END

//#!INJECT_BEGIN PRE_LIGHTING_CALC 1
	SLZSurfDataAddFluorescence(surfData, fluorescenceColor, _Absorbance);
//#!INJECT_END