# Movement panel

Entry point: `bootstrap.lua` on `main`.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kurumitokisaki1012-commits/Flood-Escape-2/main/bootstrap.lua"))()
```

The loader requires a client environment exposing HTTP fetching and loadstring; it is not a normal Roblox Studio LocalScript loader. The script itself can be placed in a Studio LocalScript.

## Controls

- Drag the title bar to move the panel. Use minus/plus to minimize or restore it.
- Select Jump or Teleport in the left sidebar.
- Jump starts off. Enable it, then press Space once per midair boost. Holding Space does not repeat boosts.
- Boost height starts at 7.2 studs, distinct from Humanoid.JumpPower. The panel displays the character's current configured jump settings.
- Boosts preserve horizontal velocity and do not lower stronger upward velocity. No wall proximity detection is used.
- Enable Click Teleport, then left-click a solid surface within 1,500 studs of the camera ray origin. Empty space and panel clicks are ignored.
- Teleport offsets the avatar from the surface, rejects destinations overlapping solid part bounds, and clears velocity on arrival. Clicking a wall can leave the avatar airborne; gravity still applies.
- Re-running the script replaces the panel and disconnects its old listeners.

## Validation limits

Not tested in Roblox or Flood Escape 2. Custom movement controllers and server validation can affect behavior. Destination overlap checks are conservative for parts and do not guarantee clearance from all terrain geometry. Repository updates are fetched when the loader is run again, subject to GitHub caching.
