import std.stdio;
import std.file;
import std.string;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import gl3n.linalg;

alias Matrix!(float, 4, 4) Mat4f;

class Shader
{
    private:
        GLuint programID = 0;
        GLuint MVP_ID = 0;

        enum
        {
            VERTEX_SHADER,
            FRAGMENT_SHADER,
            NUM_SHADERS
        }

        GLuint[NUM_SHADERS] shaders;

    public:
        this(string vertShader, string fragShader)
        {
            shaders[VERTEX_SHADER] = compileShader(vertShader, GL_VERTEX_SHADER);
            shaders[FRAGMENT_SHADER] = compileShader(fragShader, GL_FRAGMENT_SHADER);

            programID = glCreateProgram();
            foreach(GLuint shader; shaders)
            {
                glAttachShader(programID, shader);
            }

            glLinkProgram(programID);
            glValidateProgram(programID);

            checkError(programID, GL_LINK_STATUS, true, "Failed to link. Invalid program:");

            MVP_ID = glGetUniformLocation(programID, "MVP");
        }

        ~this()
        {
            foreach(GLuint shader; shaders)
            {
                glDetachShader(programID, shader);
                glDeleteShader(shader);
            }
            glDeleteProgram(programID);
        }

        void bind()
        {
            glUseProgram(programID);
        }

        void unbind()
        {
            glUseProgram(0);
        }

        void setMVP(Mat4f mvp)
        {
            glUniformMatrix4fv(MVP_ID, 1, GL_TRUE, mvp.value_ptr);
        }

    private:
        int compileShader(string sourceCode, int shaderType)
        {
            auto shaderID = glCreateShader(shaderType);
            auto src = toStringz(sourceCode);
            glShaderSource(shaderID, 1, &src, cast(GLint*)0);
            glCompileShader(shaderID);

            checkError(shaderID, GL_COMPILE_STATUS, false, "Failed to compile shader:");

            return shaderID;
        }

        void checkError(GLuint id, GLuint flag, bool isProgram, string errorMessage)
        {
            GLint success = 0;

            if(isProgram)
            {
                glGetProgramiv(id, flag, &success);
            }
            else
            {
                glGetShaderiv(id, flag, &success);
            }

            if(success == GL_FALSE)
            {
                GLchar[1024] error;

                if(isProgram)
                {
                    glGetProgramInfoLog(id, cast(GLint)error.sizeof, null, error.ptr);
                }
                else
                {
                    glGetShaderInfoLog(id, cast(GLint)error.sizeof, null, error.ptr);
                }

                writeln(errorMessage);
                writeln("\t"~error);
            }
        }
}

Shader loadShader(string vertShader, string fragShader)
{
    string vShaderSource = cast(string)read(vertShader);
    string fShaderSource = cast(string)read(fragShader);

    return new Shader(vShaderSource, fShaderSource);
}

