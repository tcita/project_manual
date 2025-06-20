// To render this diagram, you can use the free online tool at https://structurizr.com/dsl
// or use the Structurizr CLI.

workspace "Card Game System" {

    model {
        // Person
        player = person "Player" "A card game player." {
            tags "Person"
        }

        // System 1: Unity Client
        unityCardGameClient = softwareSystem "Unity Card Game Client" "The client-side application for the card game, built with Unity." {
            
            // Container within the Unity Client
            unityClientContainer = container "Unity Card Game Client" "The primary container running the game logic and UI." "Container: Unity" {
                tags "Container"
                
                // Components within the Unity Client Container
                ui = component "UI" "Handles all user interface elements and interactions, including cards, drop zones for cards, buttons, and other necessary interfaces." "Unity" {
                    tags "Component"
                }
                
                gameStateManager = component "GameStateManager" "Maintains the state of all card slots on the game table. Holds references to the collections of the player's hand, the computer's hand, the card deck, and other related sets." "Unity/C#" {
                    tags "Component"
                }

                scoreManager = component "Score Manager" "Detects if card sequence matching, calculates the score obtained from matches after each operation, and accumulates the final scores." "Unity/C#" {
                    tags "Component"
                }

                turnsManager = component "Turns Manager" "Globally tracks turns by subscribing to events, starting and ending turns for both the player and the computer." "Unity/C#" {
                    tags "Component"
                }

                computerPlayerManager = component "Computer Player Manager" "Packages the current game state into JSON, sends it to the server, parses the response, and automatically plays cards based on the returned strategy." "Unity/C#" {
                    tags "Component"
                }

                cardManager = component "Card Manager" "Provides a high-level card framework and customized interaction logic for the cards." "C#/Unity" {
                    tags "Component"
                }
            }
        }

        // System 2: AI Server
        localCardGameServer = softwareSystem "Local Card Game Server" "A local server that provides AI-driven move predictions for the card game." {
            
            // Container within the AI Server
            apiContainer = container "Local Card Game Server" "A container that hosts the prediction API and logic." "Container: Python" {
                tags "Container"
                
                // Components within the AI Server Container
                webApi = component "web API" "Provides basic server functionality. Listens on http://0.0.0.0:5000. Uses the predictor to generate strategy predictions and respond." "AI/HTTP/Server/Python" {
                    tags "Component"
                }

                predictor = component "Predictor" "Integrates the prediction strategy API with Transformer and Genetic Algorithm (GA), using pre-trained models for strategy predictions." "AI/Python" {
                    tags "Component"
                }
            }
        }

        // --- Relationships ---

        // Player Interactions
        player -> ui "Plays card, ends turn"
        ui -> player "Displays game state"

        // UI and Core Logic Interactions
        ui -> turnsManager "Signals end of turn"
        ui -> gameStateManager "Changes game state"
        
        // ui -> gameStateManager "Provides card slots"
        gameStateManager -> ui "Updates UI based on state changes"

        gameStateManager -> ui "Manipulates card GameObjects within UI slots"

        // Turn Management
        turnsManager -> computerPlayerManager "Starts computer's turn"
        computerPlayerManager -> turnsManager "Signals turn completed"

        // Game State and Scoring
        gameStateManager -> scoreManager "Provides card layout for scoring"
        scoreManager -> gameStateManager "Returns match results and score"

        // Card and State Management
        cardManager -> gameStateManager "Provides card object and card data"

        // AI Player Logic
        gameStateManager -> computerPlayerManager "Provides game state"
        computerPlayerManager -> gameStateManager "Executes move based on strategy"

        // Client to Server Communication (HTTP/JSON)
        computerPlayerManager -> webApi "Requests move prediction" "JSON/HTTP"
        webApi -> computerPlayerManager "Responds with move strategy" "JSON/HTTP"

        // Internal Server Communication
        webApi -> predictor "Requests move prediction"
        predictor -> webApi "Returns move prediction"
    }

    views {
        // This single component view recreates the provided diagram by showing components
        // from two different containers in the same view.
        component unityClientContainer "ComponentDiagram" {
            // Include all components of the Unity Client
            include *
            include player
            // include webApi
            // include predictor

            title "C3 - Component Diagram"
            description "Component diagram for the Unity Card Game, showing client and server interaction."
            
            autolayout tb
        }

        // --- Styles ---
        // These styles mimic the colors and shapes from your Draw.io diagram.
        styles {
            element "Person" {
                shape Person
                background #083F75
                color #FFFFFF
                fontSize 24
            }
            element "Container" {
                // This tag is not used in the final view, but defined for completeness
                background #438DD5
                color #FFFFFF
            }
            element "Component" {
                shape RoundedBox
                background #63BEF2
                color #FFFFFF
                stroke #2086C9
                fontSize 22
            }
            relationship "Relationship" {
                fontSize 20
            }
        }
    }
}