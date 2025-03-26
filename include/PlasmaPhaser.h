#ifndef PLASMAPHASER_H
#define PLASMAPHASER_H

// idk either tbh... who comes up with these names?

#include "stdlib.h"
#include "vec3.h"
#include "quaternion.h"

typedef struct {
    int id0, id1, id2;
} Triangle;

typedef struct {
    size_t vertBufferSize;
    vec3 *vertBuffer;
    size_t triBufferSize;
    Triangle *triBuffer;
} Mesh;

typedef struct {
    Mesh *mesh;
    // Material *material;

    vec3 position, scale;
    quat rotation;

    // struct Object *parent;
    // struct Object *children;
    struct Object *prev, *next;
} Object;

typedef struct {
    Object *objects;
} Scene;


#endif