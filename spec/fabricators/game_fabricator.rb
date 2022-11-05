require_relative '../../lib/battlesnake/game'

Fabricator(:game, class_name: 'Battlesnake::Game') do
  transient :id

  initialize_with do |transients|
    payload = transients.transform_keys(&:to_s)

    payload['id'] ||= sprintf('%08x-%04x-%04x-%04x-%012x', rand(256 ** 4), rand(256 ** 2), rand(256 ** 2), rand(256 ** 2), rand(256 ** 6))

    payload.merge!({
      "ruleset" => {
        "name" => "standard",
        "version" => "v1.1.20",
        "settings" => {
          "foodSpawnChance" => 15,
          "minimumFood" => 1,
          "hazardDamagePerTurn" => 14,
          "hazardMap" => "",
          "hazardMapAuthor" => "",
          "royale" => {
            "shrinkEveryNTurns" => 0
          },
          "squad" => {
            "allowBodyCollisions" => false,
            "sharedElimination" => false,
            "sharedHealth" => false,
            "sharedLength" => false
          }
        }
      },
      "map" => "standard",
      "timeout" => 500,
      "source" => "custom"
    })

    resolved_class.new(payload)
  end
end
