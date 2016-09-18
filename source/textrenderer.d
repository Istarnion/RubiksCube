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

    Vec2f[4][string] texCoords;
    float glyphWidth, glyphHeight;  // Used for tex coords
    float charWidth, charHeight;    // Used for rendering

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
        charWidth = glyphWidth;
        charHeight = glyphHeight;

        /+
        string characters =
            " ☺☻♥♦♣♠\0\0\0\0\0\0\0\0\0"~
            "\0\0\0\0\0§\0\0\0\0\0\0\0\0\0\0"~
            "\0!\"#$%&'()*+,-./"~
            "0123456789:;<=>?"~
            "@ABCDEFGHIJKLMNO"~
            "PQRSTUVWXYZ[\\]^_"~
            "`abcdefghijklmno"~
            "pqrstuvwxyz{¦}~\0"~
            "\0üé\0äàå\0\0ëèï\0ìÄÅ"~
            "\0æÆ\0öò\0ùÿÖÜø£Ø\0\0"~
            "áíóúñÑ\0\0¿®\0½¼¡«»"~
            "\0\0\0\0\0Á\0À©\0\0\0\0\0¥\0"~
            "\0\0\0\0\0\0\0Ã\0\0\0\0\0\0\0\0"~
            "\0\0\0\0\0¹\0\0\0\0\0\0\0\0\0\0"~
            "\0\0\0\0\0\0\0\0\0Ú\0ÙýÝ\0\0"~
            "\0\0\0\0\0§÷\0\0\0\0\0\0\0\0\0";
        +/
        string[] characters = [
            " ","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0",
            "\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0",
            "\0","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/",
            "0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?",
            "@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O",
            "P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_",
            "`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o",
            "p","q","r","s","t","u","v","w","x","y","z","{","¦","}","~","\0",
            "\0","ü","é","\0","ä","à","å","\0","\0","ë","è","ï","\0","ì","Ä","Å",
            "\0","æ","Æ","\0","ö","ò","\0","ù","ÿ","Ö","Ü","ø","£","Ø","\0","\0",
            "á","í","ó","ú","ñ","Ñ","\0","\0","¿","®","\0","½","¼","¡","«","»",
            "\0","\0","\0","\0","\0","Á","\0","À","©","\0","\0","\0","\0","\0","¥","\0",
            "\0","\0","\0","\0","\0","\0","\0","Ã","\0","\0","\0","\0","\0","\0","\0","\0",
            "\0","\0","\0","\0","\0","¹","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0",
            "\0","\0","\0","\0","\0","\0","\0","\0","\0","Ú","\0","Ù","ý","Ý","\0","\0",
            "\0","\0","\0","\0","\0","§","÷","\0","\0","\0","\0","\0","\0","\0","\0","\0"
        ];

        for(int i=0; i<256; ++i)
        {
            string c = characters[i];
            //writeln(c);

            float x = i/16;
            float y = i%16;

            texCoords[c] = [
                Vec2f(x*glyphWidth, y*glyphHeight),
                Vec2f(x*glyphWidth, (y+1)*glyphHeight),
                Vec2f((x+1)*glyphWidth, y*glyphHeight),
                Vec2f((x+1)*glyphWidth, (y+1)*glyphHeight)
            ];
        }

        // Block
        texCoords["\n"] = [
            Vec2f(13*glyphWidth, 11*glyphHeight), Vec2f(13*glyphWidth, 12*glyphHeight),
            Vec2f(14*glyphWidth, 11*glyphHeight), Vec2f(14*glyphWidth, 12*glyphHeight)
        ];
    }

    void drawText(string[] text, float x, float y, Vec3f color)
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
            string c = text[i];
            if(c !in texCoords) continue;

            GLfloat xOffset = x + i * charWidth;
            GLfloat yOffset = y;
            Vec2f[4] tex = texCoords[c];
            GLfloat[16] glyphBuffer= [
                xOffset,            yOffset,             tex[0].x, tex[0].y,
                xOffset,            yOffset-charHeight, tex[1].x, tex[1].y,
                xOffset+charWidth, yOffset,             tex[2].x, tex[2].y,
                xOffset+charWidth, yOffset-charHeight, tex[3].x, tex[3].y
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

