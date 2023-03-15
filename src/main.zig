//
// PuzzleTanks
// Zig version: 0.10.1
// Author: Jackson Smith
// Date: 2023-03-15
//

const rl = @import("raylib");
const math = @import("raylib-math");

const Player = struct {
    pos: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,

    const SIZE = rl.Vector2 { .x=20, .y=20 };

    pub fn draw(self: *Player) void {
        rl.DrawRectangleV(self.pos, SIZE, self.color);
    }

    pub fn input(self: *Player) void {
        self.speed.x = 
            if (rl.IsKeyDown(rl.KeyboardKey.KEY_RIGHT) or rl.IsKeyDown(rl.KeyboardKey.KEY_D)) 2.0
            else if (rl.IsKeyDown(rl.KeyboardKey.KEY_LEFT) or rl.IsKeyDown(rl.KeyboardKey.KEY_A)) -2.0
            else 0.0;

        self.speed.y = 
            if (rl.IsKeyDown(rl.KeyboardKey.KEY_DOWN) or rl.IsKeyDown(rl.KeyboardKey.KEY_S)) 2.0
            else if (rl.IsKeyDown(rl.KeyboardKey.KEY_UP) or rl.IsKeyDown(rl.KeyboardKey.KEY_W)) -2.0
            else 0.0;
    }

    pub fn update(self: *Player, game: *Game) void {
        self.pos.x += self.speed.x;
        self.pos.y += self.speed.y;

        // Clip to bounds
        self.pos.x = math.Clamp(self.pos.x, 0, game.screen.x - SIZE.x); 
        self.pos.y = math.Clamp(self.pos.y, 0, game.screen.y - SIZE.y); 
    }
};

const Bullet = struct {
    pos: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,
    active: bool,

    const SIZE = rl.Vector2 { .x=2, .y=2 };

    pub fn draw(self: *Bullet) void {
        if (!self.active) return;
        rl.DrawRectangleV(self.pos, SIZE, self.color);
    }

    pub fn input(self: *Bullet) void {
        if (!self.active and rl.IsMouseButtonPressed(rl.MouseButton.MOUSE_BUTTON_LEFT)) {
            self.active = true;
            self.pos = rl.GetMousePosition();
        }
    }

    pub fn update(self: *Bullet, game: *Game) void {
        if (!self.active) return;
        self.pos.x += self.speed.x;
        self.pos.y += self.speed.y;

        // Clip to bounds
        self.pos.x = math.Clamp(self.pos.x, 0, game.screen.x - SIZE.x); 
        self.pos.y = math.Clamp(self.pos.y, 0, game.screen.y - SIZE.y); 
    }
};

const Game = struct {
    player: Player,
    bullet: Bullet,
    screen: rl.Vector2,

    pub fn init(screenWidth: f32, screenHeight: f32) Game {
        const player = Player {
            .pos = rl.Vector2 { .x=50, .y=50, },
            .speed = rl.Vector2 { .x=0, .y=0 },
            .color = rl.BLACK,
        };

        const bullet = Bullet {
            .pos = rl.Vector2 { .x=0, .y=0 },
            .speed = rl.Vector2 { .x=0, .y=0 },
            .color = rl.RED,
            .active = false,
        };

        return Game {
            .player = player,
            .bullet = bullet,
            .screen = rl.Vector2 {.x=screenWidth, .y=screenHeight},
        };
    }

    fn input(self: *Game) void {
        self.player.input();
        self.bullet.input();
    }

    fn update(self: *Game) void {
        self.player.update(self);
        self.bullet.update(self);
    }

    fn draw(self: *Game) void {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.WHITE);

        self.player.draw();
        self.bullet.draw();
    }
};


pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "Puzzle Tanks");
    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    
    var game = Game.init(screenWidth, screenHeight);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.WindowShouldClose()) { // Detect window close button or ESC key
        game.input();
        game.update();
        game.draw();
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    rl.CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
