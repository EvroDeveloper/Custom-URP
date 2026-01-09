//AO terms

#ifndef VR_AO_INCLUDED
#define VR_AO_INCLUDED

CBUFFER_START( ZVrAO )

#if 0
int		g_nNumAOSpheres;
float4x4	g_zAOSphere[ 128 ]; // xyz = position , w = radius

int		g_nNumAOPoints;
float4x4	g_zAOPoint[ 128 ]; // xyz = position , w = radius
#endif

float4 aoPoint1;
float4 aoPoint2;
float4 aoPoint3;
float4 aoPoint4;

CBUFFER_END

#if 0
float CalculateSphericalAO(float3 posWs, float3 vNormalWs)
{
	float OcclusionOuts = 1;

	for ( int i = 0; i < g_nNumAOSpheres; i++ )
	{	
		float3	LocalPosW = posWs - g_zAOSphere[i][3].xyz;

		float	ignoreBackfacing = saturate( 1 - dot( normalize(LocalPosW) , vNormalWs) ) ;

		float	SphericalOcclusion = 1 / sqrt( pow (distance (mul(LocalPosW, g_zAOSphere[i]), float3(0,0,0)) , 8) );
		float	OcclusionOutput = 1 - saturate(( SphericalOcclusion * ignoreBackfacing) );
		OcclusionOuts *=  OcclusionOutput ;
	} 

	return saturate(OcclusionOuts);
}
#endif

float CalculatePointAO(float3 posWs, float3 vNormalWs, float3 pointPos, half radius)
{
	if(radius == 0)
	{
		return 1.0;
	}
    float3 LocalPosW = posWs - pointPos;
	float ignoreBackfacing = 1 - ((dot( normalize(LocalPosW) , vNormalWs) * 0.5) + 0.5 ) ;
    
	float PointOcclusion =  saturate(1 - distance( LocalPosW * radius, float3(0,0,0)));

	return saturate(1 - PointOcclusion * ignoreBackfacing);
}

float CalculatePointAO(float3 posWs, float3 vNormalWs, float4x4 spotMatrix)
{
    float3 LocalPosW = posWs - spotMatrix[3].xyz;
	float ignoreBackfacing = 1 - ((dot( normalize(LocalPosW) , vNormalWs) * 0.5) + 0.5 ) ;
    
	float PointOcclusion =  saturate(1 - distance( mul(LocalPosW, spotMatrix), float3(0,0,0) ) );

	return saturate(1 - PointOcclusion * ignoreBackfacing);
}

float CalculatePointAO(float3 posWs, float3 vNormalWs)
{
	float OcclusionOuts = 1;

    OcclusionOuts *= CalculatePointAO(posWs, vNormalWs, aoPoint1.xyz, aoPoint1.w);
    OcclusionOuts *= CalculatePointAO(posWs, vNormalWs, aoPoint2.xyz, aoPoint2.w);
    OcclusionOuts *= CalculatePointAO(posWs, vNormalWs, aoPoint3.xyz, aoPoint3.w);
    OcclusionOuts *= CalculatePointAO(posWs, vNormalWs, aoPoint4.xyz, aoPoint4.w);

#if 0
	for ( int i = 0; i < g_nNumAOPoints; i++ )
	{
		float3 LocalPosW = posWs - g_zAOPoint[i][3].xyz;
		float ignoreBackfacing = 1 - ((dot( normalize(LocalPosW) , vNormalWs) * 0.5) + 0.5 ) ;
        
		float PointOcclusion =  saturate(1 - distance( mul(LocalPosW, g_zAOPoint[i]), float3(0,0,0) ) );

		float OcclusionOutput = saturate(1- PointOcclusion * ignoreBackfacing);
		OcclusionOuts *= OcclusionOutput;
		
	}
#endif
	return saturate(OcclusionOuts);
}

float CalculateShapeAO(float3 posWs, float3 vNormalWs)
{
#if 0
	float AO = 1 * CalculateSphericalAO( posWs, vNormalWs);
	AO *= CalculatePointAO( posWs, vNormalWs);
	return AO;
#else
	return CalculatePointAO( posWs, vNormalWs);
#endif
}

#endif