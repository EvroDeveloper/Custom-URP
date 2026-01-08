// Copyright (c) Valve Corporation, All rights reserved. ======================================================================================================
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles

#ifndef VR_FOG_INCLUDED
#define VR_FOG_INCLUDED

uniform half valveFogEnabled;
uniform half2 gradientFogScaleAdd;
uniform half3 gradientFogLimitColor;
uniform half3 heightFogParams;
uniform half3 heightFogColor;
uniform half4 gradientFogArray[(int)32.0];
uniform half4 gradientStartColor;
uniform half4 gradientEndColor;

//---------------------------------------------------------------------------------------------------------------------------------------------------------
half2 CalculateFogCoords( float3 posWs )
{
	half2 results = 0.0;

	if(valveFogEnabled == 0)
	{
		return results;
	}

	// Gradient fog
	half d = distance( posWs, _WorldSpaceCameraPos );
	results.x = saturate( gradientFogScaleAdd.x * d + gradientFogScaleAdd.y );

	// Height fog
	half3 cameraToPositionRayWs = posWs.xyz - _WorldSpaceCameraPos.xyz;
	half cameraToPositionDist = length( cameraToPositionRayWs.xyz );
	half3 cameraToPositionDirWs = normalize( cameraToPositionRayWs.xyz );
	half h = _WorldSpaceCameraPos.y - heightFogParams.z;

	float A = cameraToPositionDist * heightFogParams.y;
	float y = cameraToPositionDirWs.y;

	float eps = 1e-4;
	float ySafe = (abs(y) < eps) ? (sign(y) * eps) : y;

	// normal computation
	float ratio = (1.0 - exp(-(A * ySafe))) / ySafe;

	// replace with limit exactly at the horizon band
	ratio = (abs(y) < eps) ? A : ratio;

	results.y = heightFogParams.x * exp(-h * heightFogParams.y) * ratio;
	
	//return posWs.xy;
	return saturate( results.xy );
}

half4 FogLinearInterpolation(half ramp)
{	
	half refactoredramp = clamp(ramp * 32, 0, 31) ;	
	half4 interpolated =  lerp(gradientFogArray[refactoredramp],gradientFogArray[refactoredramp+1], frac(refactoredramp) ) ;

	half4 twoInterpolated = lerp(gradientStartColor, gradientEndColor, ramp);
	return interpolated;
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------
half3 ApplyFog( half3 c, half2 fogCoord, float fogMultiplier )
{
	if(valveFogEnabled == 0)
	{
		return c;
	}
	// Apply gradient fog
	//half4 f = tex2D( gradientFogTexture, half2( fogCoord.x, 0.0f ) ).rgba;
	//half4 f = gradientFogArray[ clamp(fogCoord.x * 32 , 0, 31) ].rgba;
	half4 f = FogLinearInterpolation(fogCoord.x);

	c.rgb = lerp( c.rgb, f.rgb * fogMultiplier, f.a );

	// Apply height fog
	c.rgb = lerp( c.rgb, heightFogColor.rgb * fogMultiplier, fogCoord.y );

	return c.rgb;
}

//ALPHA Fog
half4 ApplyFog( half4 c, half2 fogCoord, float fogMultiplier, float ColorMultiplier )
{
	if(valveFogEnabled == 0)
	{
		return c;
	}
	// Apply gradient fog
	//half4 f = tex2D( gradientFogTexture, half2( fogCoord.x, 0.0f ) ).rgba;
	half4 f = FogLinearInterpolation(fogCoord.x);

	c.rgb = lerp( c.rgb, f.rgb * fogMultiplier, f.a );
	
	// Apply height fog
	c.rgb = lerp( c.rgb, heightFogColor.rgb * fogMultiplier, fogCoord.y );

	c.rgb = lerp(c.rgb, half3(ColorMultiplier, ColorMultiplier, ColorMultiplier) , saturate(f.a + fogCoord.y) );

	return half4(c.rgb, (1 - f.a) * c.a);
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------
half3 ApplyFog( half3 c, half2 fogCoord )
{
	return ApplyFog( c.rgb, fogCoord.xy, 1.0 );
}




#endif