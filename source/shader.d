import derelict.opengl3.gl3;
import std.stdio;
import std.string;

import gl3n.linalg;

alias Vector!(float, 2) Vec2f;
alias Vector!(float, 3) Vec3f;
alias Vector!(float, 4) Vec4f;
alias Matrix!(float, 4, 4) Mat4f;

class Shader
{
private:
    GLuint[] shaders;
    bool linked;

    GLint[string] uniforms;

public:
    GLuint ID;

    this()
    {
        ID = glCreateProgram();
    }

    ~this()
    {
        glDeleteProgram(ID);
    }

    bool attachShader(string shaderSource, GLenum type)
    {
        if(linked)
        {
            writeln("Trying to attach shader to already linked program!");
            return false;
        }

        auto shader = compileShader(shaderSource, type);
        glAttachShader(ID, shader);

        shaders ~= shader;
        return true;
    }

    bool link()
    {
        if(linked)
        {
            writeln("Shader program is already linked!");
            return false;
        }

        if(shaders.length == 0)
        {
            writeln("Trying to link shader program with no attached shaders!");
            return false;
        }

        glLinkProgram(ID);
        glValidateProgram(ID);
        checkError(ID, GL_LINK_STATUS, true, "Failed to link. Invalid program:");

        foreach(shader; shaders)
        {
            glDetachShader(ID, shader);
            glDeleteShader(shader);
        }

        linked = true;
        return true;
    }

    void bind()
    {
        glUseProgram(ID);
    }

    void unbind()
    {
        glUseProgram(0);
    }

    void setFloat(string uniform, float value, bool bind = false)
    {
        if(bind) glUseProgram(ID);

        if(uniform in uniforms)
        {
            glUniform1f(uniforms[uniform], value);
        }
        else
        {
            GLuint uniLoc = glGetUniformLocation(ID, uniform.toStringz());
            uniforms[uniform] = uniLoc;

            glUniform1f(uniLoc, value);
        }
    }

    void setInt(string uniform, int value, bool bind = false)
    {
        if(bind) glUseProgram(ID);

        if(uniform in uniforms)
        {
            glUniform1i(uniforms[uniform], value);
        }
        else
        {
            GLuint uniLoc = glGetUniformLocation(ID, uniform.toStringz());
            uniforms[uniform] = uniLoc;

            glUniform1i(uniLoc, value);
        }
    }

    void setVector2f(string uniform, Vec2f value, bool bind = false)
    {
        if(bind) glUseProgram(ID);

        if(uniform in uniforms)
        {
            glUniform2fv(uniforms[uniform], 1, value.value_ptr);
        }
        else
        {
            GLuint uniLoc = glGetUniformLocation(ID, uniform.toStringz());
            uniforms[uniform] = uniLoc;

            glUniform2fv(uniLoc, 1, value.value_ptr);
        }
    }

    void setVector3f(string uniform, Vec3f value, bool bind = false)
    {
        if(bind) glUseProgram(ID);

        if(uniform in uniforms)
        {
            glUniform3fv(uniforms[uniform], 1, value.value_ptr);
        }
        else
        {
            GLuint uniLoc = glGetUniformLocation(ID, uniform.toStringz());
            uniforms[uniform] = uniLoc;

            glUniform3fv(uniLoc, 1, value.value_ptr);
        }
    }

    void setVector4f(string uniform, Vec4f value, bool bind = false)
    {
        if(bind) glUseProgram(ID);

        if(uniform in uniforms)
        {
            glUniform4fv(uniforms[uniform], 1, value.value_ptr);
        }
        else
        {
            GLuint uniLoc = glGetUniformLocation(ID, uniform.toStringz());
            uniforms[uniform] = uniLoc;

            glUniform4fv(uniLoc, 1, value.value_ptr);
        }
    }

    void setMatrix4(string uniform, Mat4f value, bool bind = false)
    {
        if(bind) glUseProgram(ID);

        if(uniform in uniforms)
        {
            glUniformMatrix4fv(uniforms[uniform], 1, GL_TRUE, value.value_ptr);
        }
        else
        {
            GLuint uniLoc = glGetUniformLocation(ID, uniform.toStringz());
            uniforms[uniform] = uniLoc;

            glUniformMatrix4fv(uniLoc, 1, GL_TRUE, value.value_ptr);
        }
    }

private:
    GLuint compileShader(string sourceCode, GLenum shaderType)
    {
        auto shaderID = glCreateShader(shaderType);
        auto src = toStringz(sourceCode);
        glShaderSource(shaderID, 1, &src, cast(GLint*)0);
        glCompileShader(shaderID);

        checkError(shaderID, GL_COMPILE_STATUS, false, "Failed to compile shader:\n"~sourceCode);

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
            writeln("\t"~fromStringz(error.ptr));
        }
    }
}
