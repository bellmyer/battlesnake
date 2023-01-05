# Battlesnake

## 0.1.5 (2023-01-04)

### Added

  - Board
    - #available_neighbors(location) returns neighboring locations available for moving.
    - #flood_fills(location) returns hash of reachable locations by direction

### Changed

  - Board
    - #find_path(from, to, max_distance: nil) skips recursion if manhattan distance is greater than
      max_distance.

## 0.1.4 (2023-01-03)

### Added

  - Board
    - #food?(location) returns true if location is food.

### Changed

  - Board
    - #occupied_locations no longer includes food.

## 0.1.3 (2022-11-07)

### Added

  - Board
    - #on_board?(location) returns true if location is within board boundaries.
    - #paths(from, to) returns all valid paths from one location to the next.
  
### Changed

  - Board
    - #occupied?(location) now only accepts a location object.
    - #available?(location) now only accepts a location object.
    - locations must be both unoccupied AND on_board to be considered available.

## 0.1.2 (2022-11-05)

### Added

  - Class for Game, which deserializes game JSON or hash into object.
  - Board:
    - #occupied_locations returns array of all occupied locations; snakes, food, hazards, etc.
    - #occupied?(location) returns true if location is occupied.
    - #available?(location) returns true if location is available (unoccupied).
    - #available_directions(location) returns directions (up, down, left, right) available for
      moving.
  - Model classes (Game, Board, Location, Snake):
    - now inherit from a Base class.
    - measure equality based on as_json method.

## 0.1.1 (2022-11-04)

### Added

  - Class for Board, which deserializes board JSON or hash into object with Snake and Location
    objects.

## 0.1.0 (2022-11-04)

### Initial Release

  - Class for Location, which deserializes coordinate JSON, hash with (x,y) keys, array of two
    elements, or two parameters into object with helper methods.
  - Class for Snake, which deserializes snake JSON  or hash into object with Location objects and
    helper methods.
  