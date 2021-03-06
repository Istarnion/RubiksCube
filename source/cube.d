import std.stdio;
import std.file;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import gl3n.linalg;

import shader;

alias Matrix!(float, 4, 4) Mat4f;

/*
COlORS:
Red     = 0xC41E3A -> (0.77, 0.12, 0.23) RIGHT
Green   = 0x009E60 -> (0.00, 0.62, 0.38) FRONT
Blue    = 0x0052BA -> (0.00, 0.32, 0.73) BACK
Orange  = 0xFF5800 -> (1.00, 0.35, 0.00) LEFT
Yellow  = 0xFFD500 -> (1.00, 0.84, 0.00) DOWN
White   = 0xFFFFFF -> (1.00, 1.00, 1.00) UP
*/

const GLfloat[44*6] vertices = [
//  X     Y     Z      R     G     B    Normals  Tex coords
    // front face
    -1.0, -1.0,  1.0,  0.0,  0.6,  0.4, 0, 0,  1, 0.0f, 0.00f,
     1.0, -1.0,  1.0,  0.0,  0.6,  0.4, 0, 0,  1, 0.5f, 0.00f,
     1.0,  1.0,  1.0,  0.0,  0.6,  0.4, 0, 0,  1, 0.5f, 0.33f,
    -1.0,  1.0,  1.0,  0.0,  0.6,  0.4, 0, 0,  1, 0.0f, 0.33f,

    // right face
     1.0, -1.0,  1.0,  0.8,  0.1,  0.2,  1, 0, 0, 0.5f, 0.33f,
     1.0, -1.0, -1.0,  0.8,  0.1,  0.2,  1, 0, 0, 1.0f, 0.33f,
     1.0,  1.0, -1.0,  0.8,  0.1,  0.2,  1, 0, 0, 1.0f, 0.00f,
     1.0,  1.0,  1.0,  0.8,  0.1,  0.2,  1, 0, 0, 0.5f, 0.00f,

    // back face
     1.0, -1.0, -1.0,  0.0,  0.3,  0.7, 0, 0, -1, 0.5f, 0.33f,
    -1.0, -1.0, -1.0,  0.0,  0.3,  0.7, 0, 0, -1, 1.0f, 0.33f,
    -1.0,  1.0, -1.0,  0.0,  0.3,  0.7, 0, 0, -1, 1.0f, 0.66f,
     1.0,  1.0, -1.0,  0.0,  0.3,  0.7, 0, 0, -1, 0.5f, 0.66f,

    // left face
    -1.0, -1.0, -1.0,  1.0,  0.4,  0.0, -1, 0, 0, 0.0f, 0.33f,
    -1.0, -1.0,  1.0,  1.0,  0.4,  0.0, -1, 0, 0, 0.5f, 0.33f,
    -1.0,  1.0,  1.0,  1.0,  0.4,  0.0, -1, 0, 0, 0.5f, 0.66f,
    -1.0,  1.0, -1.0,  1.0,  0.4,  0.0, -1, 0, 0, 0.0f, 0.66f,

    // top face
    -1.0,  1.0,  1.0,  1.0,  1.0,  1.0, 0,  1, 0, 0.5f, 0.66f,
     1.0,  1.0,  1.0,  1.0,  1.0,  1.0, 0,  1, 0, 1.0f, 0.66f,
     1.0,  1.0, -1.0,  1.0,  1.0,  1.0, 0,  1, 0, 1.0f, 1.00f,
    -1.0,  1.0, -1.0,  1.0,  1.0,  1.0, 0,  1, 0, 0.5f, 1.00f,

    // bottom face
    -1.0, -1.0, -1.0,  1.0,  0.8,  0.0, 0, -1, 0, 0.0f, 1.00f,
     1.0, -1.0, -1.0,  1.0,  0.8,  0.0, 0, -1, 0, 0.5f, 1.00f,
     1.0, -1.0,  1.0,  1.0,  0.8,  0.0, 0, -1, 0, 0.5f, 0.66f,
    -1.0, -1.0,  1.0,  1.0,  0.8,  0.0, 0, -1, 0, 0.0f, 0.66f
];

const GLuint[36] indices = [
    // front
    0, 1, 2,
    0, 2, 3,

    // right
    4, 5, 6,
    4, 6, 7,

    // back
    8, 9, 10,
    8, 10, 11,

    // left
    12, 13, 14,
    12, 14, 15,

    // top
    16, 17, 18,
    16, 18, 19,

    // bottom
    20, 21, 22,
    20, 22, 23
];

struct Cube
{
    private:
        GLuint VAO;
        GLuint VBO;

        GLuint indexBufferObject;;

        GLuint positionAttribute    = 0;
        GLuint colorAttribute       = 1;
        GLuint normalAttribute      = 2;
        GLuint texAttribute         = 3;

    public:
        int number;
        Shader shader;

        Mat4f transform;

        this(Mat4f mvp)
        {
            init(mvp);
        }

        void init(Mat4f mvp)
        {
            shader = new Shader();
            shader.attachShader(readText("shaders/basic.vert"), GL_VERTEX_SHADER);
            shader.attachShader(readText("shaders/basic.frag"), GL_FRAGMENT_SHADER);
            shader.link();

            shader.setMatrix4("MVP", mvp*transform, true);

            glGenVertexArrays(1, &VAO);
            glBindVertexArray(VAO);

            glGenBuffers(1, &VBO);
            glBindBuffer(GL_ARRAY_BUFFER, VBO);
            glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, GL_STATIC_DRAW);

            glEnableVertexAttribArray(positionAttribute);
            glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, cast(GLint)(GLfloat.sizeof*11), cast(GLvoid*)0);

            glEnableVertexAttribArray(colorAttribute);
            glVertexAttribPointer(colorAttribute, 3, GL_FLOAT, GL_FALSE, cast(GLint)(GLfloat.sizeof*11), cast(GLvoid*)(GLfloat.sizeof*3));

            glEnableVertexAttribArray(normalAttribute);
            glVertexAttribPointer(normalAttribute, 3, GL_FLOAT, GL_FALSE, cast(GLint)(GLfloat.sizeof*11), cast(GLvoid*)(GLfloat.sizeof*6));

            glEnableVertexAttribArray(texAttribute);
            glVertexAttribPointer(texAttribute, 2, GL_FLOAT, GL_FALSE, cast(GLint)(GLfloat.sizeof*11), cast(GLvoid*)(GLfloat.sizeof*9));

            glGenBuffers(1, &indexBufferObject);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferObject);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.sizeof, indices.ptr, GL_STATIC_DRAW);

            glBindVertexArray(0);
        }

        void draw()
        {
            shader.bind();
            glBindVertexArray(VAO);

            glDrawElements(GL_TRIANGLES, indices.length, GL_UNSIGNED_INT, cast(GLvoid*)0);

            glBindVertexArray(0);
            shader.unbind();
        }

        void update(Mat4f mvp)
        {
            shader.bind();
            shader.setMatrix4("MVP", mvp * transform);
            shader.unbind();
        }

        ~this()
        {
            glDeleteBuffers(1, &VBO);
            glDeleteBuffers(1, &indexBufferObject);
            glDeleteVertexArrays(1, &VAO);
        }
}

