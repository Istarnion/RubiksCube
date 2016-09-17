import derelict.opengl3.gl3;

import std.stdio;
import std.string;

class Texture2D
{

    GLuint ID;

    uint width, height;

    GLuint internalFormat;
    GLuint imageFormat;

    GLuint wrapS, wrapT;
    GLuint filterMin, filterMag;

    this()
    {
        width = 0;
        height = 0;

        internalFormat = GL_RGB;
        imageFormat = GL_RGB;

        wrapS = GL_REPEAT;
        wrapT = GL_REPEAT;

        filterMin = GL_LINEAR;
        filterMag = GL_LINEAR;

        glGenTextures(1, &ID);
    }

    void generate(uint width, uint height, ubyte* data)
    {
        this.width = width;
        this.height = height;

        glBindTexture(GL_TEXTURE_2D, ID);
        glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, width, height, 0, imageFormat, GL_UNSIGNED_BYTE, data);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterMin);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterMag);

        glBindTexture(GL_TEXTURE_2D, 0);
    }

    void bind()
    {
        glBindTexture(GL_TEXTURE_2D, ID);
    }
}
