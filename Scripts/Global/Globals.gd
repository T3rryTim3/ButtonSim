extends Node

## The game node; where all playable parts take place.
## This is referenced by many objects, so avoid modifying it.
var game : Control

## Main scene. Kept in globals for organization's sake.
var main : Node

## Node which manages the loading and saving of game data.
var save_manager : Node
