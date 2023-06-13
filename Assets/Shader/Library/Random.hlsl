#ifndef CUSTOM_RANDOM_INCLUDED
#define CUSTOM_RANDOM_INCLUDED

float rand (float2 seed)
{
    return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
}

#endif