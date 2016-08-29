import std.stdio;

import derelict.opengl3.gl3;

import gl3n.linalg;
import gl3n.math;

alias Vector!(float, 2) Vec2f;
alias Vector!(float, 3) Vec3f;
alias Vector!(float, 4) Vec4f;
alias Matrix!(float, 4, 4) Mat4f;

struct Camera
{
    Mat4f projection;
    Mat4f view;

    Mat4f viewProjection;

    Mat4f invView;
    Mat4f invProj;

    int width;
    int height;

    float fov;
    float near;
    float far;

    this(float fov, int width, int height, float near, float far)
    {
        this.width = width;
        this.height = height;
        this.fov = fov;
        this.near = near;
        this.far = far;

        view.make_identity();
        projection = Mat4f.perspective(
                width,
                height,
                fov,
                near,
                far
                );

        viewProjection = projection * view;
        invView = view.inverse();
        invProj = projection.inverse();
    }

    void update()
    {
        viewProjection = projection * view;
        invView = view.inverse();
        invProj = projection.inverse();
    }

    void resize(int width, int height)
    {
        this.width = width;
        this.height = height;

        projection = Mat4f.perspective(
                width,
                height,
                fov,
                near,
                far
                );

        update();

        glViewport(0, 0, width, height);
    }

    Vec3f mouseToRay(int mousex, int mousey)
    {
        Vec3f v;
        v.x = (2.0f * mousex) / width - 1.0f;
        v.y = 1.0f - (2.0f * mousey) / height;
        v.z = -1.0f;

        auto ray = invProj * Vec4f(v.xyz, 1);
        ray.z = -1;
        ray.w = 0;
        ray = invView * ray;
        ray.normalize();

        return ray.xyz;
    }

    Mat4f calcMVP(Mat4f model)
    {
        return viewProjection * model;
    }
}

