workspace "Containers for Unity Card Game" {
    model {
        player = person "Player" "card game player"

        unityCardGame = softwareSystem "Unity Card Game" "System" {
            client = container "Unity Card Game Client" "Provides the UI for the game, allows players to see cards and make moves.\nAutomatically moves cards on computer's turn." "unity, c#, http"
            server = container "Local Card Game Server" "Generates a move strategy \nfor the computer player based on \ntwo AI models" "http, flask, AI, python"
        }

        player -> client "Move cards,\nEnd turn"
        client -> player "Displays card game state"
        client -> server "Sends the board state" "JSON/HTTP"
        server -> client "Responds with data which\ndescribing the movement \nof a card" "JSON/HTTP"
    }

    views {
        container unityCardGame "Containers" {
            include *
            autoLayout
        }
    }
}