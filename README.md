# bug-game
For game-off 2021

## Documentation

### Classes

#### Entity (KinematicBody2D)
A catch-all class for physic object that moves and has a state machine, with a basic wrapper around the movement.

#### Player (extends Entity)

#### Enemy (extends Entity)
A basic wrapper for enemies that sets up basic configurations, mainly collision layers.

Methods:
 - `on_hit(damage: int)` Method called when hit
 - `on_death()` Virtual method called on death

#### Projectile (KinematicBody2D)
A basic projectile class, containing static helper functions for spawning bullets, bouncing control, and callback for hit events:

Methods:
 - `on_hit(body: Node2D)` Virtual method for collision with a Body.
 
 
 ### Collision Layers
 Godot uses a system of *layers* and *masks* for collision. Essentially, *layer* signifies the location of an object, while *mask* signifies the layer that the object targets. 
 We will take advantage of this system along with the classes to create a basic framework for what objects are allowed to interact with others.
 
 For consistency and ease of change, all universal collision bit setting are set as custom settings in project settings. (Project -> ProjectSettings -> Global)
 
 - TILEMAP_COL_BIT: 0
 - PLAYER_BULLET_COL_BIT: 1
 - ENEMY_BULLET_COL_BIT: 2
