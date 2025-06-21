workspace "System Context for Unity Card Game" {
    model {
        player = person "Player" "card game player"
        unityCardGame = softwareSystem "Unity Card Game" "Single-player PvE card game"

        player -> unityCardGame "play cards game"
        unityCardGame -> player "Displays game "
    }

    views {
        systemContext unityCardGame "SystemContext" {
            include *
            autoLayout lr
        }
    }
}