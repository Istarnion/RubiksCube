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

        this(Mat4f mvp)
        {
            for(int i=0; i<cubes.length; ++i)
            {
                cubes[i].init(mvp);
            }

            init();
            update(mvp);
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

        void update(Mat4f mvp)
        {
            for(int i=0; i<cubes.length; ++i)
            {
                cubes[i].update(mvp);
            }
        }
}

