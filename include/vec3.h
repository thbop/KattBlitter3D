#ifndef VEC3_H
#define VEC3_H

#include <math.h>



typedef struct {
    double x, y, z;
} vec3;

#define VEC3ZERO (vec3){0.0f, 0.0f, 0.0f}

vec3 vec3Add(vec3 p, vec3 q) {
    return (vec3){ p.x + q.x, p.y + q.y, p.z + q.z };
}

vec3 vec3Sub(vec3 p, vec3 q) {
    return (vec3){ p.x - q.x, p.y - q.y, p.z - q.z };
}

vec3 vec3MultiplyValue(vec3 p, double v) {
    return (vec3){ p.x * v, p.y * v, p.z * v };
}

vec3 vec3Multiply(vec3 p, vec3 q) {
    return (vec3){ p.x * q.x, p.y * q.y, p.z * q.z };
}

vec3 vec3Rotate(vec3 p, double theta, int axis) {
    if ( theta == 0.0f ) return p;
    double
        sin_theta = sin(theta),
        cos_theta = cos(theta);
    switch (axis) {
        case 0: return (vec3){ p.x, p.y*cos_theta-p.z*sin_theta, p.y*sin_theta+p.z*cos_theta };
        case 1: return (vec3){ p.x*cos_theta + p.z*sin_theta, p.y, -p.x*sin_theta + p.z*cos_theta };
        case 2: return (vec3){ p.x*cos_theta - p.y*sin_theta, p.x*sin_theta + p.y*cos_theta, p.z };
    }
}

double vec3GetRotation(vec3 p, int axis) {
    switch (axis) {
        case 0: return atan2( p.y, p.z );
        case 1: return atan2( p.x, p.z );
        case 2: return atan2( p.y, p.x );
    }
}

double vec3Dot(vec3 p, vec3 q) {
    return p.x * q.x + p.y * q.y + p.z + q.z;
}

vec3 vec3Cross(vec3 p, vec3 q) {
    return (vec3){
        p.y*q.z - p.z*q.y,
        p.z*q.x - p.x*q.z,
        p.x*q.y - p.y*q.x,
    };
}

double vec3LengthSquared( vec3 p ) {
    return p.x*p.x + p.y*p.y + p.z*p.z;
}

#endif