# Card3D

This is a simple and handy library for managing 3D cards in Godot. With drag-and-drop support, you can easily move and reorder cards within and between collections. Look and feel inspired by Hearthstone.

This library is designed to be flexible and extendable for any card game. It offers a basic framework that you can easily adapt to suit your specific needs.

## Features

- **Card3D**: Represents an individual card node.
- **CardCollection3D**: Manages a collection of Card3D objects, supporting adding, removing, and reordering of cards.
  - optional different layouts (pile, fan, line)
  - configurable dropzone settings
- **DragController**: Handles the drag-and-drop operations across multiple card collections.

## Screenshots

![Card Collection Overview](https://raw.githubusercontent.com/tdecker91/Card3D/main/screenshots/screenshot_1.png)

![Solitaire Example](https://raw.githubusercontent.com/tdecker91/Card3D/main/screenshots/screenshot_4.png)

![Different Style Example](https://raw.githubusercontent.com/tdecker91/Card3D/main/screenshots/screenshot_6.png)

## Installation

import the project from the Godot asset library

## Usage

1. Create a new scene that inherits from `Card3D` and extend the `Card3D` script. This allows you to create your own card meshes and textures. (You can also use the example textures included.)
2. Add an instance of `DragController` to your scene.
3. Add one or more instances of `CardCollection3D` as children of the `DragController`.
4. Configure the drop settings for the card collections.
5. Add a script that instantiates `Card3D` nodes and adds them to the collections.


## Acknowledgements


- Assets used from [Kenney's Boardgame Pack](https://www.kenney.nl/assets/boardgame-pack)
