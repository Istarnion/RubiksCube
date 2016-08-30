import std.stdio;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import gl3n.linalg;
import gl3n.math;

import cube;

alias Matrix!(float, 4, 4) Mat4f;
alias Vector!(float, 3) Vec3f;
alias Vector!(float, 4) Vec4f;

struct RubiksCube
{
    private:
        Cube[27] cubes;

        float spacing = 2.5f;;

    public:
        Mat4f model;

        this(Mat4f vp)
        {
            model.make_identity();
            Mat4f mvp = vp * model;
            for(int i=0; i<cubes.length; ++i)
            {
                cubes[i].init(mvp);
            }

            init();
            for(int i=0; i<cubes.length; ++i)
            {
                cubes[i].update(mvp);
            }
        }

        void init()
        {
            for(float x=-1; x<=1; ++x)
            {
                for(float y=-1; y<=1; ++y)
                {
                    for(float z=-1; z<=1; ++z)
                    {
                        int index =
                            cast(int)(x+1)*9 +
                            cast(int)(y+1)*3 +
                            cast(int)(z+1);

                        cubes[index].transform.translate(
                                x * spacing,
                                y * spacing,
                                z * spacing);
                    }
                }
            }
        }

        void draw()
        {
            for(int i=0; i<cubes.length; ++i)
            {
                cubes[i].draw();
            }
        }

        void update(Mat4f vp)
        {
            Mat4f mvp = vp * model;
            for(int i=0; i<cubes.length; ++i)
            {
                cubes[i].update(mvp);
            }
        }
/*
    Vec3f v = Vec3f(model[0][0], model[1][0], model[2][0]);
*/
        int pickCube(Vec3f origin, Vec3f dir)
        {
            writeln("Picking cube from "~origin.as_string());
            writeln("Direction: "~dir.as_string());

            float dist;
            float halfSize = spacing+0.5f;
            int index = -1;
            // First, check if we hit the cluster at all
            if(rayVsCube(origin, dir, Vec3f(-halfSize, -halfSize, -halfSize), Vec3f(halfSize, halfSize, halfSize), model, dist))
            {
                writeln("Hit cube");
                // Then we must find what cube we hit
                Mat4f m;
                float shortest = 1000000.0f;
                for(int i=0; i<cubes.length; ++i)
                {
                    /*TEMP*/ cubes[i].transform.scale(1, 1, 1);
                    m = model * cubes[i].transform;
                    if(rayVsCube(origin, dir, Vec3f(-0.5f, -0.5f, -0.5f), Vec3f(0.5f, 0.5f, 0.5f), m, dist))
                    {
                        if(dist < shortest)
                        {
                            index = i;
                            shortest = dist;
                        }
                    }
                }
            }

            writeln(index);
            if(index >= 0)
            {
                cubes[index].transform.scale(1.0f, 1.0f, 1.0f);
            }

            return index;
        }

        bool rayVsCube(Vec3f o, Vec3f d, Vec3f min, Vec3f max, Mat4f model, ref float dist)
        {
            // Intersection method from Real-Time Rendering and Essential Mathematics for Games
            float tMin = 0.0f;
            float tMax = 100000.0f;

            Vec3f worldPos = Vec3f(model[0][3], model[1][3], model[2][3]);

            Vec3f delta = worldPos - o;

            // Test intersection with the 2 planes perpendicular to the OBB's X axis
            {
                Vec3f xaxis = Vec3f(model[0][0], model[1][0], model[2][0]);
                float e = dot(xaxis, delta);
                float f = dot(d, xaxis);

                if(abs(f) > 0.001f) // Standard case
                {
                    float t1 = (e+min.x)/f; // Intersection with the "left" plane
                    float t2 = (e+max.x)/f; // Intersection with the "right" plane
                    // t1 and t2 now contain distances betwen ray origin and ray-plane intersections

                    // We want t1 to represent the nearest intersection, 
                    // so if it's not the case, invert t1 and t2
                    if (t1>t2){
                        // swap t1 and t2
                        float w=t1;
                        t1=t2;
                        t2=w;
                    }

                    // tMax is the nearest "far" intersection (amongst the X,Y and Z planes pairs)
                    if(t2 < tMax)
                    {
                        tMax = t2;
                    }
                    // tMin is the farthest "near" intersection (amongst the X,Y and Z planes pairs)
                    if(t1 > tMin)
                    {
                        tMin = t1;
                    }

                    // And here's the trick :
                    // If "far" is closer than "near", then there is NO intersection.
                    // See the images in the tutorials for the visual explanation.
                    if(tMax < tMin)
                    {
                        return false;
                    }
                }
                else // Rare case : the ray is almost parallel to the planes, so they don't have any "intersection"
                {
                    if(-e+min.x > 0.0f || -e+max.x < 0.0f)
                    {
                        return false;
                    }
                }
            }


            // Test intersection with the 2 planes perpendicular to the OBB's Y axis
            // Exactly the same thing than above.
            {
                Vec3f yaxis = Vec3f(model[0][1], model[1][1], model[2][1]);
                float e = dot(yaxis, delta);
                float f = dot(d, yaxis);

                if(abs(f) > 0.001f)
                {
                    float t1 = (e+min.y)/f;
                    float t2 = (e+max.y)/f;

                    if(t1>t2)
                    {
                        float w=t1;
                        t1=t2;
                        t2=w;
                    }

                    if(t2 < tMax)
                    {
                        tMax = t2;
                    }
                    if(t1 > tMin)
                    {
                        tMin = t1;
                    }
                    if(tMin > tMax)
                    {
                        return false;
                    }
                }
                else
                {
                    if(-e+min.y > 0.0f || -e+max.y < 0.0f)
                    {
                        return false;
                    }
                }
            }


            // Test intersection with the 2 planes perpendicular to the OBB's Z axis
            // Exactly the same thing than above.
            {
                Vec3f zaxis = Vec3f(model[0][2], model[1][2], model[2][2]);
                float e = dot(zaxis, delta);
                float f = dot(d, zaxis);

                if(abs(f) > 0.001f)
                {
                    float t1 = (e+min.z)/f;
                    float t2 = (e+max.z)/f;

                    if(t1>t2)
                    {
                        float w=t1;
                        t1=t2;
                        t2=w;
                    }

                    if(t2 < tMax)
                    {
                        tMax = t2;
                    }
                    if(t1 > tMin)
                    {
                        tMin = t1;
                    }
                    if(tMin > tMax)
                    {
                        return false;
                    }
                }
                else
                {
                    if(-e+min.z > 0.0f || -e+max.z < 0.0f)
                    {
                        return false;
                    }
                }
            }

            dist = tMin;
            return true;
        }
}

