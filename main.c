#include <stdlib.h>
#include <stdio.h>

#include "raylib.h"

#if defined(PLATFORM_WEB)
    #include <emscripten/emscripten.h>
#include "raylib_game.h"
#endif

#define COUNTER_MESSAGE_BUFFER_LENGTH 20

static int RandLimited(int limit) {
    return rand() % limit;
}

static bool HasCollisionHappened(int currentCoord, int maxCoord, int bodyMeasure)
{
    return (currentCoord <= 0) || (currentCoord >= (maxCoord - bodyMeasure));
}

int main(void)
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "DVD interesting game");

    Texture texture = LoadTexture("dvd.png");

    int currentX = RandLimited(screenWidth - texture.width);
    int currentY = RandLimited(screenHeight - texture.height);

    int speedX = 1 + RandLimited(5);
    int speedY = 1 + RandLimited(5);

    unsigned int hitCount = 0;
    unsigned int winCount = 0;

    char hitsMsg[COUNTER_MESSAGE_BUFFER_LENGTH] = { 0 };
    char winsMsg[COUNTER_MESSAGE_BUFFER_LENGTH] = { 0 };

    SetTargetFPS(60);
    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        currentX += speedX;
        currentY += speedY;

        bool xCollision = HasCollisionHappened(currentX, screenWidth, texture.width);
        bool yCollision = HasCollisionHappened(currentY, screenHeight, texture.height);

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

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return EXIT_SUCCESS;
}
