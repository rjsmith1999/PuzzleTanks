//
// PuzzleTanks
// Zig version: 0.10.1
// Author: Jackson Smith
// Date: 2023-03-15
//

const rl = @import("raylib");
const math = @import("raylib-math");

// const std = @import("std");
// const assert = std.debug.assert;

const Tank = struct {
    pos: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,
    weapon: Weapon,

    const SIZE = rl.Vector2{ .x = 20, .y = 20 };

    pub fn draw(self: *Tank) void {
        rl.DrawRectangleV(self.pos, SIZE, self.color);
    }

    pub fn input(self: *Tank) void {
        self.speed.x =
            if (rl.IsKeyDown(rl.KeyboardKey.KEY_RIGHT) or rl.IsKeyDown(rl.KeyboardKey.KEY_D)) 2.0 else if (rl.IsKeyDown(rl.KeyboardKey.KEY_LEFT) or rl.IsKeyDown(rl.KeyboardKey.KEY_A)) -2.0 else 0.0;

        self.speed.y =
            if (rl.IsKeyDown(rl.KeyboardKey.KEY_DOWN) or rl.IsKeyDown(rl.KeyboardKey.KEY_S)) 2.0 else if (rl.IsKeyDown(rl.KeyboardKey.KEY_UP) or rl.IsKeyDown(rl.KeyboardKey.KEY_W)) -2.0 else 0.0;

        // Update Weapon
        if (rl.IsMouseButtonPressed(rl.MouseButton.MOUSE_BUTTON_LEFT))
            self.fireIfAvalible();
    }

    fn fireIfAvalible(self: *Tank) void {
        var next = self.weapon.nextAvalible() orelse return;

        next.active = true;
        next.pos = self.pos;

        next.setVelToward(rl.GetMousePosition());
    }

    pub fn update(self: *Tank, game: *Game) void {
        self.pos.x += self.speed.x;
        self.pos.y += self.speed.y;

        // Clip to bounds
        self.pos.x = math.Clamp(self.pos.x, 0, game.screen.x - SIZE.x);
        self.pos.y = math.Clamp(self.pos.y, 0, game.screen.y - SIZE.y);
    }
};

const Weapon = struct {
    // bullets: std.BoundedArray(Bullet, 5),

    pub fn nextAvalible(self: *Weapon) ?*Bullet {
        // for (self.bullets.slice()) |*b| {
        //     if (!b.active) return b;
        // }
        _ = self;
        return null;
    }

    pub fn init(comptime count: usize) Weapon {
        // var bullets = [_]Bullet{.{}} ** count;
        _ = count;
        return .{};
        // return Weapon{
        //     .bullets = std.BoundedArray(Bullet, 5).fromSlice(&bullets) catch unreachable,
        // };
    }
};

const Bullet = struct {
    pos: rl.Vector2 = .{ .x = 0, .y = 0 },
    vel: rl.Vector2 = .{ .x = 0, .y = 0 },
    active: bool = false,

    color: rl.Color = rl.RED,
    speed: f32 = 2.0,

    const SIZE = rl.Vector2{ .x = 2, .y = 2 };

    pub fn draw(self: *Bullet) void {
        if (!self.active) return;
        rl.DrawRectangleV(self.pos, SIZE, self.color);
    }

    pub fn update(self: *Bullet, game: *Game) void {
        if (!self.active) return;
        self.pos.x += self.vel.x;
        self.pos.y += self.vel.y;

        // Clip to bounds
        if (self.pos.x != math.Clamp(self.pos.x, 0, game.screen.x - SIZE.x) or
            self.pos.y != math.Clamp(self.pos.y, 0, game.screen.y - SIZE.y))
            self.active = false;
    }

    pub fn setVelToward(self: *Bullet, target: rl.Vector2) void {
        const ray = math.Vector2Normalize(math.Vector2Subtract(target, self.pos));

        self.vel = math.Vector2Scale(ray, self.speed);
    }
};

const Game = struct {
    player: Tank,
    screen: rl.Vector2,

    pub fn init(screenWidth: f32, screenHeight: f32) Game {
        const player = Tank{
            .pos = rl.Vector2{
                .x = 50,
                .y = 50,
            },
            .speed = rl.Vector2{ .x = 0, .y = 0 },
            .color = rl.BLACK,
            .weapon = Weapon.init(5),
        };

        return Game{
            .player = player,
            .screen = rl.Vector2{ .x = screenWidth, .y = screenHeight },
        };
    }

    fn input(self: *Game) void {
        self.player.input();
    }

    fn update(self: *Game) void {
        self.player.update(self);
    }

    fn draw(self: *Game) void {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.WHITE);

        self.player.draw();
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
