import std.stdio;
import std.file;
import std.math;
import std.random;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl3;

import gl3n.linalg;

import rubikscube;
import camera;
import shader;
import textrenderer;

alias Vector!(float, 2) Vec2f;
alias Vector!(float, 3) Vec3f;
alias Vector!(float, 4) Vec4f;
alias Matrix!(float, 4, 4) Mat4f;

const char BLOCK_CHAR = '\n';

void main()
{
    DerelictSDL2.load();
    DerelictGL3.load();
    DerelictSDL2Image.load();

    if (SDL_Init(SDL_INIT_EVERYTHING))
    {
        writeln("Unable to initialize SDL:\n\t", SDL_GetError());
        return;
    }

    scope(exit)
    {
        SDL_Quit();
    }

    int flags = IMG_INIT_JPG|IMG_INIT_PNG;
    int initted = IMG_Init(flags);
    if((initted & flags) != flags) {
        writeln("Failed to initialize SDL_Image!");
        return;
    }

    scope(exit)
    {
        IMG_Quit();
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 2);

    int width = 512;
    int height = 512;

    auto window = SDL_CreateWindow(
            "Exercise 04",
            SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
            width, height,
            SDL_WINDOW_OPENGL
            );

    if (window is null)
    {
        writeln("Failed to open window:\n\t", SDL_GetError());
        return;
    }

    auto glContext = SDL_GL_CreateContext(window);
    if (glContext is null)
    {
        writeln("Failed to create OpenGL context:\n\t", fromStringz(SDL_GetError()));
        return;
    }

    DerelictGL3.reload();

    auto versionString = glGetString(GL_VERSION);
    writeln(fromStringz(versionString));

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_MULTISAMPLE);

    glClearColor(0.18f, 0.18f, 0.18f, 1);

    Camera cam = Camera(60, width, height, 0.1f, 100.0f);
    cam.view = Mat4f.look_at(
            Vec3f(0, 0, 20),
            Vec3f(0, 0, 0),
            Vec3f(0, 1, 0)
            );
    cam.update();

    RubiksCube rCube = RubiksCube(cam.viewProjection);

    auto textRenderer = new TextRenderer();
    textRenderer.generate();

    float vel = 7.0f;
    Vec2f mouseDrag;
    bool dragging = false;
    bool spaceDown = false;

    string userInput;
    string textToShow;
    float blinkTimer = 0;
    float blinkDuration = 0.4f;
    bool showBlock = true;

    auto now = SDL_GetPerformanceCounter();
    auto last = now;
    float deltaTime = 0;
    bool running = true;
    SDL_Event event;
    SDL_StartTextInput();
    while(running)
    {
        dragging = false;
        last = now;
        now = SDL_GetPerformanceCounter();
        deltaTime = cast(float)(now - last) / SDL_GetPerformanceFrequency();

        while(SDL_PollEvent(&event))
        {
            if(event.type == SDL_QUIT)
            {
                running = false;
                break;
            }
            else if(event.type == SDL_WINDOWEVENT)
            {
                if(event.window.event == SDL_WINDOWEVENT_RESIZED)
                {
                    width = event.window.data1;
                    height = event.window.data2;
                    cam.resize(width, height);
                    rCube.update(cam.viewProjection);
                }
            }
            else if(event.type == SDL_KEYDOWN)
            {
                if(event.key.keysym.sym == SDLK_BACKSPACE)
                {
                    if(userInput.length > 0)
                    {
                        userInput = userInput[0 .. $-1];
                    }
                }
            }
            else if(event.type == SDL_TEXTINPUT)
            {
                char[] input = fromStringz(event.text.text.ptr);
                if(input[0] in textRenderer.texCoords)
                {
                    userInput ~= fromStringz(event.text.text.ptr);
                }
            }
            else if(event.type == SDL_MOUSEMOTION)
            {
                if(event.motion.state & SDL_BUTTON_LMASK)
                {
                    int x = event.motion.x;
                    int y = event.motion.y;
                    int dx = event.motion.xrel;
                    int dy = event.motion.yrel;

                    rotate(rCube, x-dx, y-dy, dx, dy, deltaTime);
                }
            }
            else if(event.type == SDL_MOUSEBUTTONDOWN)
            {
            }
        }
        if(running)
        {
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            rCube.draw();

            blinkTimer += deltaTime;
            if(blinkTimer >= blinkDuration)
            {
                blinkTimer = 0;
                showBlock = !showBlock;
            }

            if(showBlock)
            {
                textToShow = "Input: "~userInput~BLOCK_CHAR;
            }
            else
            {
                textToShow = "Input: "~userInput;
            }
            textRenderer.drawText(
                    textToShow,
                    -0.95f, -0.9f,
                    Vec3f(0, 1, 0));

            SDL_GL_SwapWindow(window);
        }
    }

    SDL_DestroyWindow(window);
}

void rotate(ref RubiksCube rCube, int mousex, int mousey, int movex, int movey, float deltaTime)
{
    //Mat4f transformation = Mat4f.identity();

    //Vec3f delta = Vec3f(movey, movex, 0);
    //delta.normalize();
    //transformation.rotate(vel*deltaTime, delta);

    //rCube.model = transformation * rCube.model;

    //rCube.update(cam.viewProjection);
}
