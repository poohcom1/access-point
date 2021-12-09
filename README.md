
# Access Point
Open-source isometric shooter for game-off 2021 built in Godot.

[![CC BY 4.0][cc-by-image]][cc-by]

All assets are licensed under a
[Creative Commons Attribution 4.0 International License][cc-by]. You are free to use them in anyway you like as long as you give us credit.
 
## File Structure

### `assets`
All graphical, audio, and font assets. Certain font resources are also stored here.

### `entities`
All objects that inherits from `Entity.gd`, mainly the player and enemies.

### `pickups`
Pickup objects, such as health and weapons.

### `stages`
All scenes that act as stages/levels, including main menus.

### `structures`
All objects that inherits from `Structure.gd`.

### `system`
Autoload singletons and general scripts.

### `ui`
UI components, including loading screens and HUDs.

### `weapons`
All objects that inherits from `Weapon.gd`, as well as modules used by the player.


## Documentation

### Code Structure
Objects are structured by main scripts that are inherited. Scenes are never inherited, and most scripts that require child nodes will create them programmatically. 

### GameManager
[GameManager](system/GameManager.gd) is a singleton that persists in all scenes. It is used for registering important nodes (Players, Navigation, etc.) for ease of access, as well as performing actions for optimization (multithreaded lazy pathfinding, lazy spawning).

### EnemyUnit
All mobile enemies inherits from [`EnemyUnit.gd`](entities/enemies/scripts/EnemyUnit.gd), which deals with multithreaded pathfinding and unit targeting.

### Stages
All stages' root node are Navigation2D nodes for the sake of simplicity. These root node's script inherits from [`StageInit`](stages/scripts/StageInit.gd), which deals with TileMap init and starting the stage from loading screen. It also deals with dialogues if required.
 

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg