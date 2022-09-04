#include <stdlib.h>
#include <stdio.h>

#include "raylib.h"

#if defined(PLATFORM_WEB)
    #include <emscripten/emscripten.h>
#include "raylib_game.h"
#endif

#define COUNTER_MESSAGE_BUFFER_LENGTH 20
#define SCREEN_WIDTH 720
#define SCREEN_HEIGHT 450

static int RandLessThan(int limit)
{
    return rand() % limit;
}

static bool HasCollisionHappened(int currentCoord, int maxCoord, int bodyMeasure)
{
    return (currentCoord <= 0) || (currentCoord >= (maxCoord - bodyMeasure));
}

static int currentX, currentY, speedX, speedY;
static unsigned int hitCount = 0, winCount = 0;
static Texture texture;
static bool xCollision, yCollision;

char hitsMsg[COUNTER_MESSAGE_BUFFER_LENGTH] = { 0 };
char winsMsg[COUNTER_MESSAGE_BUFFER_LENGTH] = { 0 };

static void UpdateDrawFrame(void)
{
    // Update
    currentX += speedX;
    currentY += speedY;

    xCollision = HasCollisionHappened(currentX, SCREEN_WIDTH, texture.width);
    yCollision = HasCollisionHappened(currentY, SCREEN_HEIGHT, texture.height);

    if (xCollision || yCollision) {
        ++hitCount;
        if (xCollision && yCollision) { ++winCount; }
        if (xCollision) { speedX *= -1; }
        if (yCollision) { speedY *= -1; }
    }

    snprintf(hitsMsg, COUNTER_MESSAGE_BUFFER_LENGTH, "Hits: %d", hitCount);
    snprintf(winsMsg, COUNTER_MESSAGE_BUFFER_LENGTH, "Wins: %d", winCount);

    // Draw
    //----------------------------------------------------------------------------------
    BeginDrawing();

    ClearBackground(RAYWHITE);
    DrawText(hitsMsg, 10, 10, 20, GRAY);
    DrawText(winsMsg, 10, 30, 20, GRAY);
    DrawTexture(texture, currentX, currentY, WHITE);

    EndDrawing();
    //----------------------------------------------------------------------------------
}

int main(void)
{
    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "DVD interesting game");

    texture = LoadTexture("dvd.png");

    currentX = RandLessThan(SCREEN_WIDTH - texture.width);
    currentY = RandLessThan(SCREEN_HEIGHT - texture.height);

    speedX = 1 + RandLessThan(5);
    speedY = 1 + RandLessThan(5);

#if defined(PLATFORM_WEB)
    emscripten_set_main_loop(UpdateDrawFrame, 0, 1);  // TODO: UpdateDrawFrame
#else
    SetTargetFPS(60);
    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        UpdateDrawFrame();
    }
#endif
    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return EXIT_SUCCESS;
}
