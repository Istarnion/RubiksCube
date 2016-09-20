import std.stdio;
import std.string;
import std.regex;
import std.random;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl3;

import gl3n.linalg;
import gl3n.math;

import cube;
import texture;

alias Matrix!(float, 4, 4) Mat4f;
alias Vector!(float, 3) Vec3f;
alias Vector!(float, 4) Vec4f;

struct RubiksCube
{
    enum Side
    {
        GREEN,
        RED,
        YELLOW,
        ORANGE,
        BLUE,
        WHITE
    }

    Cube*[27] cubes;

    float spacing = 2.0f;;

    Mat4f model;
    Mat4f viewProjection;

    Texture2D diffuseTexture;

    this(Mat4f vp)
    {
        viewProjection = vp;
        model.make_identity();
        for(int i=0; i<cubes.length; ++i)
        {
            cubes[i] = new Cube(vp);
            cubes[i].number = i;
        }

        init();
        for(int i=0; i<cubes.length; ++i)
        {
            cubes[i].update(vp);
        }

        auto surface = IMG_Load("diffuse.png");
        diffuseTexture = new Texture2D();
        diffuseTexture.imageFormat = GL_RGBA;
        diffuseTexture.internalFormat = GL_RGBA;
        diffuseTexture.generate(256, 384, cast(ubyte*)surface.pixels);
        SDL_FreeSurface(surface);
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

    int toIndex(int x, int y, int z) {
        return x*9 + y*3 + z;
    }

    void draw()
    {
        diffuseTexture.bind();

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

    void scramble()
    {
        reset();
        for(int i=0; i<500; ++i)
        {
            int j = uniform(0, 6);
            if(j == 0) rotate(Side.GREEN, true);
            else if(j == 1) rotate(Side.RED, true);
            else if(j == 2) rotate(Side.YELLOW, true);
            else if(j == 3) rotate(Side.ORANGE, true);
            else if(j == 4) rotate(Side.BLUE, true);
            else if(j == 5) rotate(Side.WHITE, true);
        }
    }

    void parseCommand(string input)
    {
        if(input == "reset")
        {
            reset();
        }
        else if(input == "scramble")
        {
            scramble();
        }
        else if(matchFirst(input, "^[gGrRbByYoOwW]{1}[iI]?$")) {
            bool clockwise = input.length < 2;
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
        Cube*[3][3] face;
        switch(side)
        {
            case Side.RED, Side.ORANGE:
                int xindex = side == Side.RED? 2 : 0;

                // Swapping places in the array
                for(int i=0; i<3; ++i)
                {
                    for(int j=0; j<3; ++j)
                    {
                        face[i][j] = cubes[toIndex(xindex, i, j)];
                    }
                }

                rotateMatrix(face, ((side == Side.RED && !clockwise) || (side == Side.ORANGE && clockwise)));

                for(int i=0; i<3; ++i)
                {
                    for(int j=0; j<3; ++j)
                    {
                        cubes[toIndex(xindex, i, j)] = face[i][j];
                    }
                }

                // Rotating the cubes
                Mat4f mvp = viewProjection * model;

                float axis = -1;
                if(side == Side.RED && clockwise) axis = 1;
                else if(side == Side.ORANGE && !clockwise) axis = 1;

                for(int y=0; y<3; ++y)
                {
                    for(int z=0; z<3; ++z)
                    {
                        int index = toIndex(xindex, y, z);
                        cubes[index].transform.rotate(
                                cast(float)(PI/2.0), Vec3f(axis, 0, 0));
                        cubes[index].update(mvp);
                    }
                }
                break;
            case Side.GREEN, Side.BLUE:
                int zindex = side == Side.GREEN? 2 : 0;

                // Swapping places in the array
                for(int i=0; i<3; ++i)
                {
                    for(int j=0; j<3; ++j)
                    {
                        face[i][j] = cubes[toIndex(i, j, zindex)];
                    }
                }

                rotateMatrix(face, ((side == Side.GREEN && !clockwise) || (side == Side.BLUE && clockwise)));

                for(int i=0; i<3; ++i)
                {
                    for(int j=0; j<3; ++j)
                    {
                        cubes[toIndex(i, j, zindex)] = face[i][j];
                    }
                }

                // Rotating the cubes
                Mat4f mvp = viewProjection * model;

                float axis = -1;
                if(side == Side.GREEN && clockwise) axis = 1;
                else if(side == Side.BLUE && !clockwise) axis = 1;

                for(int x=0; x<3; ++x)
                {
                    for(int y=0; y<3; ++y)
                    {
                        int index = toIndex(x, y, zindex);
                        cubes[index].transform.rotate(
                                cast(float)(PI/2.0), Vec3f(0, 0, axis));
                        cubes[index].update(mvp);
                    }
                }
                break;
            case Side.YELLOW, Side.WHITE:
                int yindex = side == Side.WHITE? 2 : 0;

                // Swapping places in the array
                for(int i=0; i<3; ++i)
                {
                    for(int j=0; j<3; ++j)
                    {
                        face[i][j] = cubes[toIndex(i, yindex, j)];
                    }
                }

                rotateMatrix(face, ((side == Side.WHITE && clockwise) || (side == Side.YELLOW && !clockwise)));

                for(int i=0; i<3; ++i)
                {
                    for(int j=0; j<3; ++j)
                    {
                        cubes[toIndex(i, yindex, j)] = face[i][j];
                    }
                }

                // Rotating the cubes
                Mat4f mvp = viewProjection * model;

                float axis = -1;
                if(side == Side.WHITE && clockwise) axis = 1;
                else if(side == Side.YELLOW && !clockwise) axis = 1;

                for(int x=0; x<3; ++x)
                {
                    for(int z=0; z<3; ++z)
                    {
                        int index = toIndex(x, yindex, z);
                        cubes[index].transform.rotate(
                                cast(float)(PI/2.0), Vec3f(0, axis, 0));
                        cubes[index].update(mvp);
                    }
                }
                break;
            default: assert(0);
        }
    }

    void rotateMatrix(ref Cube*[3][3] mat, bool clockwise)
    {
        Cube* temp;
        if(clockwise)
        {
            for(int i=0; i<2; i++)
            {
                temp = mat[0][i];

                mat[0][i] = mat[i][2];

                mat[i][2] = mat[2][2-i];

                mat[2][2-i] = mat[2-i][0];

                mat[2-i][0] = temp;
            }
        }
        else
        {
            for(int i=0; i<2; i++)
            {
                temp = mat[0][i];

                mat[0][i] = mat[2-i][0];

                mat[2-i][0] = mat[2][2-i];

                mat[2][2-i] = mat[i][2];

                mat[i][2] = temp;
            }
        }
    }
}

