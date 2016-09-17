import derelict.opengl3.gl3;
import shader;
import texture;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import gl3n.linalg;

import std.stdio;
import std.file;
import std.string;

alias Vector!(float, 2) Vec2f;
alias Vector!(float, 3) Vec3f;

class TextRenderer
{
    Texture2D fontTexture;
    Shader shader;

    Vec2f[4][char] texCoords;
    float glyphWidth, glyphHeight;

    void generate()
    {
        auto surface = IMG_Load("font.png");
        fontTexture = new Texture2D();
        fontTexture.filterMin = GL_NEAREST;
        fontTexture.filterMag = GL_NEAREST;
        fontTexture.generate(128, 128, cast(ubyte*)surface.pixels);
        SDL_FreeSurface(surface);

        shader = new Shader();
        shader.attachShader(cast(string)read("shaders/font.vert"), GL_VERTEX_SHADER);
        shader.attachShader(cast(string)read("shaders/font.frag"), GL_FRAGMENT_SHADER);
        shader.link();

        uint numCols = 16;
        uint numRows = 16;
        glyphWidth = 1.0f / numCols;
        glyphHeight = 1.0f / numRows;

        // Upper case
        int offset = 65;
        for(int i=offset; i<offset+26; ++i)
        {
            int row = i%16;
            int col = i/16;

            float x = col * glyphWidth;
            float y = row * glyphHeight;

            Vec2f[4] glyphCoords = [
                Vec2f(x, y), Vec2f(x, y+glyphHeight),
                Vec2f(x+glyphWidth, y), Vec2f(x+glyphWidth, y+glyphHeight)
            ];

            char glyph = cast(char)('A'+(i-offset));
            texCoords[glyph] = glyphCoords;
        }

        // Lower case
        offset = 97;
        for(int i=offset; i<offset+26; ++i)
        {
            int row = i%16;
            int col = i/16;

            float x = col * glyphWidth;
            float y = row * glyphHeight;

            Vec2f[4] glyphCoords = [
                Vec2f(x, y), Vec2f(x, y+glyphHeight),
                Vec2f(x+glyphWidth, y), Vec2f(x+glyphWidth, y+glyphHeight)
            ];

            char glyph = cast(char)('a'+(i-offset));
            texCoords[glyph] = glyphCoords;
        }

        texCoords[' '] = [
            Vec2f(0, 0), Vec2f(0, 0),
            Vec2f(0, 0), Vec2f(0, 0)
        ];

        texCoords[':'] = [
            Vec2f(3*glyphWidth, 10*glyphHeight), Vec2f(3*glyphWidth, 11*glyphHeight),
            Vec2f(4*glyphWidth, 10*glyphHeight), Vec2f(4*glyphWidth, 11*glyphHeight)
        ];

        // Block
        texCoords['\n'] = [
            Vec2f(13*glyphWidth, 11*glyphHeight), Vec2f(13*glyphWidth, 12*glyphHeight),
            Vec2f(14*glyphWidth, 11*glyphHeight), Vec2f(14*glyphWidth, 12*glyphHeight)
        ];
    }

    void drawText(string text, float x, float y, Vec3f color)
    {
        GLuint VAO;
        GLuint VBO;
        GLuint IBO;

        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        glGenBuffers(1, &IBO);

        glBindVertexArray(VAO);

        GLfloat[] buffer;
        GLuint[] indices;

        for(int i=0; i<text.length; ++i)
        {
            char c = text[i];

            GLfloat xOffset = x + i * glyphWidth;
            GLfloat yOffset = y;
            Vec2f[4] tex = texCoords[c];
            GLfloat[16] glyphBuffer= [
                xOffset,            yOffset,             tex[0].x, tex[0].y,
                xOffset,            yOffset-glyphHeight, tex[1].x, tex[1].y,
                xOffset+glyphWidth, yOffset,             tex[2].x, tex[2].y,
                xOffset+glyphWidth, yOffset-glyphHeight, tex[3].x, tex[3].y
            ];

            buffer ~= glyphBuffer;

            GLuint offset = i * 4;
            indices ~= [offset, offset + 1, offset + 2, offset + 2, offset + 1, offset + 3];
        }

        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, GLfloat.sizeof * buffer.length, buffer.ptr, GL_STREAM_DRAW);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, cast(GLint)(GLfloat.sizeof * 4), cast(GLvoid*)0);

        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, cast(GLint)(GLfloat.sizeof * 4), cast(GLvoid*)(GLfloat.sizeof*2));

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLuint.sizeof * indices.length, indices.ptr, GL_STREAM_DRAW);

        shader.bind();
        shader.setVector3f("color", color);
        fontTexture.bind();

        glDrawElements(GL_TRIANGLES, cast(uint)indices.length, GL_UNSIGNED_INT, cast(GLvoid*)0);

        shader.unbind();
        glBindVertexArray(0);

        glDeleteBuffers(1, &IBO);
        glDeleteBuffers(1, &VBO);
        glDeleteVertexArrays(1, &VAO);
    }
}

