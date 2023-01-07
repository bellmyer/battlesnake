require_relative '../../lib/battlesnake/turn'

Fabricator(:turn, class_name: 'Battlesnake::Turn') do
  transient turn: 0, game: {}

  initialize_with do |transients|
    payload = transients.slice(:turn).transform_keys(&:to_s)

    game = deep_stringify_keys(
      deep_merge(game_template, transients[:game])
    )

    board = Fabricate(:board).as_json

    payload = {
      'game' => game,
      'board' => board,
      'you' => board['snakes'].first
    }

    resolved_class.new(payload)
  end
end

def game_template
  {
    "game": {
      "id": "be3d8a29-c217-4764-9b35-bce99ed6820c",
      "ruleset": {
        "name": "standard",
        "version": "v1.1.20",
        "settings": {
          "foodSpawnChance": 15,
          "minimumFood": 1,
          "hazardDamagePerTurn": 14,
          "hazardMap": "",
          "hazardMapAuthor": "",
          "royale": {
            "shrinkEveryNTurns": 0
          },
          "squad": {
            "allowBodyCollisions": false,
            "sharedElimination": false,
            "sharedHealth": false,
            "sharedLength": false
          }
        }
      },
      "map": "standard",
      "timeout": 500,
      "source": "custom"
    }
  }
end

def deep_merge(struct1, struct2)
  case struct1
  when Hash
    struct1.keys.map do |key|
      if struct2.key?(key)
        [key, deep_merge(struct1[key], struct2[key])]
      else
        [key, struct1[key]]
      end
    end.to_h
  when Array
    struct1.map{ |key| deep_merge(struct1[key], struct2[key]) }
  else
    struct2
  end
end

def deep_stringify_keys(struct)
  case struct
  when Hash
    struct.map{ |k,v| [k.to_s, deep_stringify_keys(v)] }.to_h
  when Array
    struct.map{ |item| deep_stringify_keys(item) }
  else
    struct
  end
end