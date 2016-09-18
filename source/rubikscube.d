import std.stdio;
import std.string;
import std.regex;

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
    Cube[27] cubes;

    float spacing = 2.1f;;

    enum Side
    {
        GREEN,
        RED,
        YELLOW,
        ORANGE,
        BLUE,
        WHITE
    }

    enum Rotation
    {
        PITCH,
        ROLL,
        YAW
    }

    Mat4f model;
    Mat4f viewProjection;

    this(Mat4f vp)
    {
        viewProjection = vp;
        model.make_identity();
        for(int i=0; i<cubes.length; ++i)
        {
            cubes[i].init(vp);
        }

        init();
        for(int i=0; i<cubes.length; ++i)
        {
            cubes[i].update(vp);
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

                    cubes[index].transform.make_identity();
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
        viewProjection = vp;
        Mat4f mvp = vp * model;
        for(int i=0; i<cubes.length; ++i)
        {
            cubes[i].update(mvp);
        }
    }

    void globalRotation(float delta, bool up, bool right, bool left, bool down)
    {
        if(!up && !right && !left && !down) return;

        Mat4f t = Mat4f.identity();

        auto axis = Vec3f(
            (up?1:-1) + (down?-1:1),
            (right?-1:1) + (left?1:-1),
            0);
        t.rotate(7*delta, axis);

        model = t * model;

        update(viewProjection);
    }

    void reset()
    {
        model.make_identity();
        init();
        update(viewProjection);
    }

    void parseCommand(string input)
    {
        if(input == "reset")
        {
            reset();
        }
        else if(matchFirst(input, "[gGrRbByYoOwW]{1}[iI]?")) {
            bool clockwise = input.length == 1;
            char side = toLower(input)[0];

            if(side == 'g') {
                rotate(Side.GREEN, clockwise);
            }
            else if(side == 'r') {
                rotate(Side.RED, clockwise);
            }
            else if(side == 'b') {
                rotate(Side.BLUE, clockwise);
            }
            else if(side == 'y') {
                rotate(Side.YELLOW, clockwise);
            }
            else if(side == 'o') {
                rotate(Side.ORANGE, clockwise);
            }
            else if(side == 'w') {
                rotate(Side.WHITE, clockwise);
            }
        }
    }

    void rotate(Side side, bool clockwise)
    {

    }
}

