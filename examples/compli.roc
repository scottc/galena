app [
    FrontendModel,
    BackendModel,
    ToFrontendMsg,
    FrontendMsg,
    ToBackendMsg,
    frontendApp,
    backendApp,
] {
    galena: platform "../platform/main.roc",
    rand: "https://github.com/lukewilliamboswell/roc-random/releases/download/0.5.0/yDUoWipuyNeJ-euaij4w_ozQCWtxCsywj68H0PlJAdE.tar.br",
}

import galena.Backend as Backend exposing [Backend]
import galena.Frontend as Frontend exposing [Frontend]
import galena.Html as Html
import rand.Random as Random

# ========== TYPES ==========

Player : {
    id : Str,
    name : Str,
    score : U32,
    current_code : Str,
    challenge_completed : Bool,
    last_activity : U64,
    color : Str,
}
Challenge : {
    id : Str,
    title : Str,
    description : Str,
    test_cases : List { input : Str, expected_output : Str },
    starter_code : Str,
    difficulty : [Easy, Medium, Hard],
    time_limit_seconds : U32,
}

GameRoom : {
    id : Str,
    challenge : Challenge,
    players : Dict Str Player,
    start_time : U64,
    is_active : Bool,
    winner : Result Str [NoWinner],
}

GameRoomTx : {
    id : Str,
    challenge : Challenge,
    players : List (Str, Player),
    start_time : U64,
    is_active : Bool,
    winner : Result Str [NoWinner],
}

FrontendModel : {
    player_id : Str,
    player_name : Str,
    current_room : Result Str [NotInRoom],
    current_code : Str,
    game_state : Result GameRoom [Loading],
    error_message : Result Str [NoError],
    code_execution_result : Result Str [NoResult],
    show_leaderboard : Bool,
    cursor_position : U32,
    typing_indicator : Bool,
}

BackendModel : {
    rooms : Dict Str GameRoom,
    available_challenges : List Challenge,
    global_leaderboard : Dict Str U32,
    active_players : Dict Str { room_id : Str, last_seen : U64 },
}

ToFrontendMsg : [
    GameStateUpdate GameRoomTx,
    PlayerJoined { player_id : Str, player_name : Str },
    PlayerLeft Str,
    CodeUpdate { player_id : Str, code : Str, cursor_pos : U32 },
    ChallengeCompleted { player_id : Str, completion_time : U32 },
    GameEnded { winner_id : Str, final_scores : List (Str, U32) },
    ErrorMsg Str,
    RoomCreated Str,
    CodeExecutionResult { player_id : Str, result : Str, success : Bool },
    TypingIndicator { player_id : Str, is_typing : Bool },
    LeaderboardUpdate (List (Str, U32)),
]

FrontendMsg : [
    JoinRoom Str,
    CreateRoom,
    UpdateCode Str,
    SubmitSolution,
    LeaveRoom,
    UpdatePlayerName Str,
    SetCursorPosition U32,
    ToggleLeaderboard,
    StartTyping,
    StopTyping,
    SelectChallenge Str,
    ExecuteCode,
    LeavePage,
    NoOp,
]

ToBackendMsg : [
    JoinRoomRequest { player_id : Str, player_name : Str, room_id : Str },
    CreateRoomRequest { player_id : Str, player_name : Str, challenge_id : Str },
    CodeUpdateMsg { player_id : Str, room_id : Str, code : Str, cursor_pos : U32 },
    ExecuteCodeRequest { player_id : Str, room_id : Str, code : Str },
    SubmitSolutionRequest { player_id : Str, room_id : Str, code : Str },
    LeaveRoomRequest { player_id : Str, room_id : Str },
    TypingUpdate { player_id : Str, room_id : Str, is_typing : Bool },
    GetLeaderboard,
    HeartBeat { player_id : Str, room_id : Str },
]

BackendMsg : [
    ProcessJoinRoom { player_id : Str, player_name : Str, room_id : Str, client_id : Str },
    ProcessCreateRoom { player_id : Str, player_name : Str, challenge_id : Str, client_id : Str },
    ProcessCodeUpdate { player_id : Str, room_id : Str, code : Str, cursor_pos : U32, client_id : Str },
    ProcessExecuteCode { player_id : Str, room_id : Str, code : Str, client_id : Str },
    ProcessSubmitSolution { player_id : Str, room_id : Str, code : Str, client_id : Str },
    ProcessLeaveRoom { player_id : Str, room_id : Str, client_id : Str },
    ProcessTypingUpdate { player_id : Str, room_id : Str, is_typing : Bool, client_id : Str },
    ProcessHeartBeat { player_id : Str, room_id : Str, client_id : Str },
    CleanupInactivePlayers,
]

# ========== CHALLENGE DATA ==========

sample_challenges : List Challenge
sample_challenges = [
    {
        id: "fibonacci",
        title: "Fibonacci Sequence",
        description: "Write a function that returns the nth Fibonacci number. F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2)",
        test_cases: [
            { input: "0", expected_output: "0" },
            { input: "1", expected_output: "1" },
            { input: "5", expected_output: "5" },
            { input: "10", expected_output: "55" },
        ],
        starter_code: "fibonacci = |n|\n    # Your code here\n    0",
        difficulty: Easy,
        time_limit_seconds: 300,
    },
    {
        id: "palindrome",
        title: "Palindrome Checker",
        description: "Write a function that checks if a string is a palindrome (reads the same forwards and backwards)",
        test_cases: [
            { input: "\"racecar\"", expected_output: "Bool.true" },
            { input: "\"hello\"", expected_output: "Bool.false" },
            { input: "\"A man a plan a canal Panama\"", expected_output: "Bool.true" },
        ],
        starter_code: "is_palindrome = |text|\n    # Your code here\n    Bool.false",
        difficulty: Medium,
        time_limit_seconds: 450,
    },
    {
        id: "merge_sort",
        title: "Merge Sort Implementation",
        description: "Implement the merge sort algorithm to sort a list of numbers",
        test_cases: [
            { input: "[3, 1, 4, 1, 5, 9]", expected_output: "[1, 1, 3, 4, 5, 9]" },
            { input: "[5, 4, 3, 2, 1]", expected_output: "[1, 2, 3, 4, 5]" },
            { input: "[]", expected_output: "[]" },
        ],
        starter_code: "merge_sort = |list|\n    # Your code here\n    list",
        difficulty: Hard,
        time_limit_seconds: 600,
    },
]

# ========== FRONTEND ==========

frontendApp : Frontend FrontendModel FrontendMsg ToFrontendMsg ToBackendMsg
frontendApp = Frontend.frontend {
    init!: frontend_init!,
    update!: frontend_update!,
    view: view,
    updateFromBackend: update_from_backend,
}

frontend_init! : FrontendModel
frontend_init! =
    # TODO: Implement Browser API for true randomness
    { value } = Random.step (Random.seed 42069) (Random.bounded_u32 1000 9999)
    {
        player_id: "player_" |> Str.concat (Num.to_str (value)),
        player_name: "Anonymous",
        current_room: Err NotInRoom,
        current_code: "",
        game_state: Err Loading,
        error_message: Err NoError,
        code_execution_result: Err NoResult,
        show_leaderboard: Bool.false,
        cursor_position: 0,
        typing_indicator: Bool.false,
    }

frontend_update! : FrontendMsg, FrontendModel => (FrontendModel, Result ToBackendMsg [NoOp])
frontend_update! = |msg, model|
    when msg is
        JoinRoom room_id ->
            updated_model = { model & current_room: Ok room_id, game_state: Err Loading }
            to_backend = JoinRoomRequest {
                player_id: model.player_id,
                player_name: model.player_name,
                room_id: room_id,
            }
            (updated_model, Ok to_backend)

        CreateRoom ->
            # Default to fibonacci challenge for now
            to_backend = CreateRoomRequest {
                player_id: model.player_id,
                player_name: model.player_name,
                challenge_id: "fibonacci",
            }
            (model, Ok to_backend)

        UpdateCode new_code ->
            updated_model = { model &
                current_code: new_code,
                typing_indicator: Bool.true,
            }
            when model.current_room is
                Ok room_id ->
                    to_backend = CodeUpdateMsg {
                        player_id: model.player_id,
                        room_id: room_id,
                        code: new_code,
                        cursor_pos: model.cursor_position,
                    }
                    (updated_model, Ok to_backend)

                Err NotInRoom ->
                    (updated_model, Err NoOp)

        ExecuteCode ->
            when model.current_room is
                Ok room_id ->
                    to_backend = ExecuteCodeRequest {
                        player_id: model.player_id,
                        room_id: room_id,
                        code: model.current_code,
                    }
                    (model, Ok to_backend)

                Err NotInRoom ->
                    (model, Err NoOp)

        SubmitSolution ->
            when model.current_room is
                Ok room_id ->
                    to_backend = SubmitSolutionRequest {
                        player_id: model.player_id,
                        room_id: room_id,
                        code: model.current_code,
                    }
                    (model, Ok to_backend)

                Err NotInRoom ->
                    (model, Err NoOp)

        LeavePage ->
            when model.current_room is
                Ok room_id ->
                    updated_model = { model &
                        current_room: Err NotInRoom,
                        game_state: Err Loading,
                        current_code: "",
                    }
                    to_backend = LeaveRoomRequest {
                        player_id: model.player_id,
                        room_id: room_id,
                    }
                    (updated_model, Ok to_backend)

                Err NotInRoom ->
                    (model, Err NoOp)

        UpdatePlayerName name ->
            updated_model = { model & player_name: name }
            (updated_model, Err NoOp)

        SetCursorPosition pos ->
            updated_model = { model & cursor_position: pos }
            (updated_model, Err NoOp)

        ToggleLeaderboard ->
            updated_model = { model & show_leaderboard: !(model.show_leaderboard) }
            (updated_model, Ok GetLeaderboard)

        StartTyping ->
            when model.current_room is
                Ok room_id ->
                    to_backend = TypingUpdate {
                        player_id: model.player_id,
                        room_id: room_id,
                        is_typing: Bool.true,
                    }
                    (model, Ok to_backend)

                Err NotInRoom ->
                    (model, Err NoOp)

        StopTyping ->
            updated_model = { model & typing_indicator: Bool.false }
            when model.current_room is
                Ok room_id ->
                    to_backend = TypingUpdate {
                        player_id: model.player_id,
                        room_id: room_id,
                        is_typing: Bool.false,
                    }
                    (updated_model, Ok to_backend)

                Err NotInRoom ->
                    (updated_model, Err NoOp)

        SelectChallenge _ ->
            # For future expansion
            (model, Err NoOp)

        # TODO: Do sth here
        LeaveRoom ->
            (model, Err NoOp)

        NoOp ->
            (model, Err NoOp)

update_from_backend : ToFrontendMsg -> FrontendMsg
update_from_backend = |backend_msg|
    when backend_msg is
        GameStateUpdate _ ->
            # This would need to be handled differently in the real implementation
            NoOp

        PlayerJoined _ -> NoOp
        PlayerLeft _ -> NoOp
        CodeUpdate _ -> NoOp
        ChallengeCompleted _ -> NoOp
        GameEnded _ -> NoOp
        ErrorMsg _ -> NoOp
        RoomCreated _ -> NoOp
        CodeExecutionResult _ -> NoOp
        TypingIndicator _ -> NoOp
        LeaderboardUpdate _ -> NoOp

# ========== VIEW ==========

view : FrontendModel -> Html.Html FrontendMsg
view = |model|
    Html.div
        [
            Html.style
                (
                    Str.join_with
                        [
                            "font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;",
                            "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);",
                            "min-height: 100vh;",
                            "color: #ffffff;",
                            "margin: 0;",
                            "padding: 0;",
                        ]
                        " "
                ),
        ]
        [
            # Header
            Html.header
                [
                    Html.style
                        (
                            Str.join_with
                                [
                                    "background: rgba(0,0,0,0.2);",
                                    "padding: 1rem 2rem;",
                                    "display: flex;",
                                    "justify-content: space-between;",
                                    "align-items: center;",
                                    "backdrop-filter: blur(10px);",
                                ]
                                " "
                        ),
                ]
                [
                    Html.h1
                        [
                            Html.style
                                (
                                    Str.join_with
                                        [
                                            "margin: 0;",
                                            "font-size: 2rem;",
                                            "background: linear-gradient(45deg, #ff6b6b, #4ecdc4);",
                                            "background-clip: text;",
                                            "-webkit-background-clip: text;",
                                            "-webkit-text-fill-color: transparent;",
                                        ]
                                        " "
                                ),
                        ]
                        [Html.text "⚡ Code Battle Arena"],
                    Html.div
                        [Html.style "display: flex; gap: 1rem; align-items: center;"]
                        [
                            Html.input [
                                Html.value model.player_name,
                                Html.placeholder "Enter your name",
                                Html.on_input (|event| UpdatePlayerName event.target.value),
                                Html.style
                                    (
                                        Str.join_with
                                            [
                                                "padding: 0.5rem;",
                                                "border: none;",
                                                "border-radius: 4px;",
                                                "background: rgba(255,255,255,0.1);",
                                                "color: white;",
                                                "backdrop-filter: blur(5px);",
                                            ]
                                            " "
                                    ),
                            ],
                            Html.button
                                [
                                    Html.on_click (|_| ToggleLeaderboard),
                                    Html.style
                                        (
                                            Str.join_with
                                                [
                                                    "padding: 0.5rem 1rem;",
                                                    "background: #ff6b6b;",
                                                    "color: white;",
                                                    "border: none;",
                                                    "border-radius: 4px;",
                                                    "cursor: pointer;",
                                                    "font-weight: bold;",
                                                ]
                                                " "
                                        ),
                                ]
                                [Html.text "🏆 Leaderboard"],
                        ],
                ],

            # Main content
            when model.current_room is
                Err NotInRoom ->
                    render_lobby model

                Ok _ ->
                    when model.game_state is
                        Err Loading ->
                            render_loading

                        Ok room ->
                            render_game_room model room,
        ]

render_lobby : FrontendModel -> Html.Html FrontendMsg
render_lobby = |_|
    Html.div
        [
            Html.style
                (
                    Str.join_with
                        [
                            "display: flex;",
                            "flex-direction: column;",
                            "align-items: center;",
                            "justify-content: center;",
                            "min-height: 80vh;",
                            "gap: 2rem;",
                        ]
                        " "
                ),
        ]
        [
            Html.div
                [
                    Html.style
                        (
                            Str.join_with
                                [
                                    "background: rgba(255,255,255,0.1);",
                                    "padding: 3rem;",
                                    "border-radius: 20px;",
                                    "backdrop-filter: blur(20px);",
                                    "text-align: center;",
                                    "max-width: 600px;",
                                ]
                                " "
                        ),
                ]
                [
                    Html.h2
                        [Html.style "font-size: 2.5rem; margin-bottom: 1rem;"]
                        [Html.text "Welcome to the Arena!"],
                    Html.p
                        [Html.style "font-size: 1.2rem; margin-bottom: 2rem; opacity: 0.9;"]
                        [Html.text "Compete with other programmers in real-time coding challenges. See their code as they type, race to solve problems, and climb the leaderboard!"],
                    Html.div
                        [Html.style "display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;"]
                        [
                            Html.button
                                [
                                    Html.on_click (|_| CreateRoom),
                                    Html.style
                                        (
                                            Str.join_with
                                                [
                                                    "padding: 1rem 2rem;",
                                                    "font-size: 1.1rem;",
                                                    "background: linear-gradient(45deg, #4ecdc4, #44a08d);",
                                                    "color: white;",
                                                    "border: none;",
                                                    "border-radius: 10px;",
                                                    "cursor: pointer;",
                                                    "font-weight: bold;",
                                                    "transform: scale(1);",
                                                    "transition: transform 0.2s;",
                                                ]
                                                " "
                                        ),
                                ]
                                [Html.text "🎮 Create New Battle"],
                            Html.div
                                [Html.style "display: flex; gap: 0.5rem;"]
                                [
                                    Html.input [
                                        Html.placeholder "Room ID",
                                        Html.style
                                            (
                                                Str.join_with
                                                    [
                                                        "padding: 1rem;",
                                                        "border: none;",
                                                        "border-radius: 10px;",
                                                        "background: rgba(255,255,255,0.1);",
                                                        "color: white;",
                                                        "backdrop-filter: blur(5px);",
                                                    ]
                                                    " "
                                            ),
                                    ],
                                    Html.button
                                        [
                                            Html.on_click (|_| JoinRoom "demo-room"),
                                            Html.style
                                                (
                                                    Str.join_with
                                                        [
                                                            "padding: 1rem 2rem;",
                                                            "font-size: 1.1rem;",
                                                            "background: linear-gradient(45deg, #ff6b6b, #ee5a6f);",
                                                            "color: white;",
                                                            "border: none;",
                                                            "border-radius: 10px;",
                                                            "cursor: pointer;",
                                                            "font-weight: bold;",
                                                        ]
                                                        " "
                                                ),
                                        ]
                                        [Html.text "⚔️ Join Battle"],
                                ],
                        ],
                ],
        ]

render_loading : Html.Html FrontendMsg
render_loading =
    Html.div
        [
            Html.style
                (
                    Str.join_with
                        [
                            "display: flex;",
                            "justify-content: center;",
                            "align-items: center;",
                            "min-height: 80vh;",
                            "font-size: 1.5rem;",
                        ]
                        " "
                ),
        ]
        [
            Html.div
                [Html.style "text-align: center;"]
                [
                    Html.div
                        [
                            Html.style
                                (
                                    Str.join_with
                                        [
                                            "width: 60px;",
                                            "height: 60px;",
                                            "border: 4px solid rgba(255,255,255,0.3);",
                                            "border-top: 4px solid #4ecdc4;",
                                            "border-radius: 50%;",
                                            "animation: spin 1s linear infinite;",
                                            "margin: 0 auto 1rem;",
                                        ]
                                        " "
                                ),
                        ]
                        [],
                    Html.text "Loading battle arena...",
                ],
        ]

render_game_room : FrontendModel, GameRoom -> Html.Html FrontendMsg
render_game_room = |model, room|
    Html.div
        [Html.style "display: flex; height: calc(100vh - 80px);"]
        [
            # Left sidebar - Players and challenge info
            Html.div
                [
                    Html.style
                        (
                            Str.join_with
                                [
                                    "width: 300px;",
                                    "background: rgba(0,0,0,0.2);",
                                    "padding: 1rem;",
                                    "overflow-y: auto;",
                                ]
                                " "
                        ),
                ]
                [
                    # Challenge info
                    Html.div
                        [
                            Html.style
                                (
                                    Str.join_with
                                        [
                                            "background: rgba(255,255,255,0.1);",
                                            "padding: 1rem;",
                                            "border-radius: 10px;",
                                            "margin-bottom: 1rem;",
                                        ]
                                        " "
                                ),
                        ]
                        [
                            Html.h3
                                [Html.style "margin: 0 0 0.5rem 0; color: #4ecdc4;"]
                                [Html.text room.challenge.title],
                            Html.p
                                [Html.style "margin: 0 0 1rem 0; font-size: 0.9rem; opacity: 0.8;"]
                                [Html.text room.challenge.description],
                            Html.div
                                [Html.style "font-size: 0.8rem;"]
                                [
                                    Html.span
                                        [Html.style "color: #ff6b6b; font-weight: bold;"]
                                        [Html.text (difficulty_to_string room.challenge.difficulty)],
                                    Html.span
                                        [Html.style "margin-left: 1rem; color: #4ecdc4;"]
                                        [Html.text ("⏱️ " |> Str.concat (Num.to_str room.challenge.time_limit_seconds) |> Str.concat "s")],
                                ],
                        ],

                    # Players list
                    Html.h4
                        [Html.style "margin: 0 0 1rem 0;"]
                        [Html.text "👥 Players"],
                    Html.div
                        []
                        (
                            Dict.to_list room.players
                            |> List.map (|(_, player)| render_player_card player)
                        ),
                ],

            # Main coding area
            Html.div
                [Html.style "flex: 1; display: flex; flex-direction: column;"]
                [
                    # Code editor
                    Html.div
                        [Html.style "flex: 1; padding: 1rem;"]
                        [
                            Html.textarea
                                [
                                    Html.value model.current_code,
                                    Html.on_input (|event| UpdateCode event.target.value),
                                    Html.on_focus (|_| StartTyping),
                                    Html.on_blur (|_| StopTyping),
                                    Html.style
                                        (
                                            Str.join_with
                                                [
                                                    "width: 100%;",
                                                    "height: 100%;",
                                                    "background: rgba(0,0,0,0.3);",
                                                    "color: #ffffff;",
                                                    "border: 2px solid rgba(78, 205, 196, 0.3);",
                                                    "border-radius: 10px;",
                                                    "padding: 1rem;",
                                                    "font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;",
                                                    "font-size: 14px;",
                                                    "line-height: 1.5;",
                                                    "resize: none;",
                                                    "outline: none;",
                                                ]
                                                " "
                                        ),
                                ]
                                [],
                        ],

                    # Bottom controls
                    Html.div
                        [
                            Html.style
                                (
                                    Str.join_with
                                        [
                                            "padding: 1rem;",
                                            "background: rgba(0,0,0,0.2);",
                                            "display: flex;",
                                            "gap: 1rem;",
                                            "align-items: center;",
                                        ]
                                        " "
                                ),
                        ]
                        [
                            Html.button
                                [
                                    Html.on_click (|_| ExecuteCode),
                                    Html.style
                                        (
                                            Str.join_with
                                                [
                                                    "padding: 0.75rem 1.5rem;",
                                                    "background: #4ecdc4;",
                                                    "color: white;",
                                                    "border: none;",
                                                    "border-radius: 6px;",
                                                    "cursor: pointer;",
                                                    "font-weight: bold;",
                                                ]
                                                " "
                                        ),
                                ]
                                [Html.text "▶️ Run Code"],
                            Html.button
                                [
                                    Html.on_click (|_| SubmitSolution),
                                    Html.style
                                        (
                                            Str.join_with
                                                [
                                                    "padding: 0.75rem 1.5rem;",
                                                    "background: #ff6b6b;",
                                                    "color: white;",
                                                    "border: none;",
                                                    "border-radius: 6px;",
                                                    "cursor: pointer;",
                                                    "font-weight: bold;",
                                                ]
                                                " "
                                        ),
                                ]
                                [Html.text "🚀 Submit Solution"],
                            Html.button
                                [
                                    Html.on_click (|_| LeavePage),
                                    Html.style
                                        (
                                            Str.join_with
                                                [
                                                    "padding: 0.75rem 1.5rem;",
                                                    "background: rgba(255,255,255,0.1);",
                                                    "color: white;",
                                                    "border: none;",
                                                    "border-radius: 6px;",
                                                    "cursor: pointer;",
                                                ]
                                                " "
                                        ),
                                ]
                                [Html.text "🚪 Leave Room"],

                            # Execution result
                            when model.code_execution_result is
                                Ok result ->
                                    Html.div
                                        [
                                            Html.style
                                                (
                                                    Str.join_with
                                                        [
                                                            "flex: 1;",
                                                            "padding: 0.5rem;",
                                                            "background: rgba(0,0,0,0.3);",
                                                            "border-radius: 4px;",
                                                            "font-family: monospace;",
                                                            "font-size: 0.9rem;",
                                                        ]
                                                        " "
                                                ),
                                        ]
                                        [Html.text result]

                                Err NoResult ->
                                    Html.div [] [],
                        ],
                ],
        ]

render_player_card : Player -> Html.Html FrontendMsg
render_player_card = |player|
    Html.div
        [
            Html.style
                (
                    Str.join_with
                        [
                            "background: rgba(255,255,255,0.1);",
                            "padding: 0.75rem;",
                            "border-radius: 8px;",
                            "margin-bottom: 0.5rem;",
                            "border-left: 4px solid " |> Str.concat player.color |> Str.concat ";",
                        ]
                        " "
                ),
        ]
        [
            Html.div
                [Html.style "display: flex; justify-content: space-between; align-items: center;"]
                [
                    Html.div
                        []
                        [
                            Html.div
                                [Html.style "font-weight: bold;"]
                                [Html.text player.name],
                            Html.div
                                [Html.style "font-size: 0.8rem; opacity: 0.7;"]
                                [Html.text ("Score: " |> Str.concat (Num.to_str player.score))],
                        ],
                    Html.div
                        []
                        [
                            if player.challenge_completed then
                                Html.span
                                    [Html.style "color: #4ecdc4;"]
                                    [Html.text "✅"]
                            else
                                Html.span
                                    [Html.style "color: #ff6b6b;"]
                                    [Html.text "⏳"],
                        ],
                ],
        ]

difficulty_to_string : [Easy, Medium, Hard] -> Str
difficulty_to_string = |diff|
    when diff is
        Easy -> "🟢 Easy"
        Medium -> "🟡 Medium"
        Hard -> "🔴 Hard"

# ========== BACKEND ==========

backendApp : Backend BackendModel BackendMsg ToFrontendMsg ToBackendMsg
backendApp = Backend.backend {
    init!: {
        rooms: Dict.empty {},
        available_challenges: sample_challenges,
        global_leaderboard: Dict.empty {},
        active_players: Dict.empty {},
    },

    update!: backend_update!,
    update_from_frontend: update_from_frontend,
}

backend_update! : BackendMsg, BackendModel => (BackendModel, Result (Str, ToFrontendMsg) [NoOp])
backend_update! = |msg, model|
    when msg is
        ProcessCreateRoom { player_id, player_name, challenge_id, client_id } ->
            { value } = Random.step (Random.seed 42069) (Random.bounded_u32 1000 9999)
            room_id = "room_" |> Str.concat (Num.to_str value)

            # Find the challenge
            challenge =
                List.find_first model.available_challenges (|c| c.id == challenge_id)
                |> Result.with_default
                    (
                        {
                            id: "fibonacci",
                            title: "Fibonacci Sequence",
                            description: "Write a function that returns the nth Fibonacci number. F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2)",
                            test_cases: [
                                { input: "0", expected_output: "0" },
                                { input: "1", expected_output: "1" },
                                { input: "5", expected_output: "5" },
                                { input: "10", expected_output: "55" },
                            ],
                            starter_code: "fibonacci = |n|\n    # Your code here\n    0",
                            difficulty: Easy,
                            time_limit_seconds: 300,
                        }
                    )

            # Create new player
            new_player = {
                id: player_id,
                name: player_name,
                score: 0,
                current_code: challenge.starter_code,
                challenge_completed: Bool.false,
                last_activity: get_current_timestamp,
                color: get_player_color player_id,
            }

            # Create new room
            new_room = {
                id: room_id,
                challenge: challenge,
                players: Dict.single player_id new_player,
                start_time: get_current_timestamp,
                is_active: Bool.true,
                winner: Err NoWinner,
            }

            updated_model = { model &
                rooms: Dict.insert model.rooms room_id new_room,
                active_players: Dict.insert model.active_players player_id { room_id: room_id, last_seen: get_current_timestamp },
            }

            (updated_model, Ok (client_id, RoomCreated room_id))

        ProcessJoinRoom { player_id, player_name, room_id, client_id } ->
            when Dict.get model.rooms room_id is
                Ok room ->
                    # Create new player
                    new_player = {
                        id: player_id,
                        name: player_name,
                        score: 0,
                        current_code: room.challenge.starter_code,
                        challenge_completed: Bool.false,
                        last_activity: get_current_timestamp,
                        color: get_player_color player_id,
                    }

                    # Add player to room
                    updated_room = { room & players: Dict.insert room.players player_id new_player }
                    updated_model = { model &
                        rooms: Dict.insert model.rooms room_id updated_room,
                        active_players: Dict.insert model.active_players player_id { room_id: room_id, last_seen: get_current_timestamp },
                    }

                    (
                        updated_model,
                        Ok (
                            client_id,
                            GameStateUpdate {
                                id: updated_room.id,
                                challenge: updated_room.challenge,
                                players: Dict.to_list updated_room.players,
                                start_time: updated_room.start_time,
                                is_active: updated_room.is_active,
                                winner: updated_room.winner,
                            },
                        ),
                    )

                Err KeyNotFound ->
                    (model, Ok (client_id, ErrorMsg "Room not found"))

        ProcessCodeUpdate { player_id, room_id, code, cursor_pos, client_id } ->
            when Dict.get model.rooms room_id is
                Ok room ->
                    when Dict.get room.players player_id is
                        Ok player ->
                            # Update player's code
                            updated_player = { player &
                                current_code: code,
                                last_activity: get_current_timestamp,
                            }
                            updated_room = { room &
                                players: Dict.insert room.players player_id updated_player,
                            }
                            updated_model = { model &
                                rooms: Dict.insert model.rooms room_id updated_room,
                            }

                            # Broadcast code update to other players in the room
                            code_update_msg = CodeUpdate {
                                player_id: player_id,
                                code: code,
                                cursor_pos: cursor_pos,
                            }

                            (updated_model, Ok (client_id, code_update_msg))

                        Err KeyNotFound ->
                            (model, Ok (client_id, ErrorMsg "Player not found in room"))

                Err KeyNotFound ->
                    (model, Ok (client_id, ErrorMsg "Room not found"))

        ProcessExecuteCode { player_id, code, client_id } ->
            # Simulate code execution (in real implementation, this would run in a sandbox)
            execution_result = simulate_code_execution code
            result_msg = CodeExecutionResult {
                player_id: player_id,
                result: execution_result.output,
                success: execution_result.success,
            }

            (model, Ok (client_id, result_msg))

        ProcessSubmitSolution { player_id, room_id, code, client_id } ->
            when Dict.get model.rooms room_id is
                Ok room ->
                    when Dict.get room.players player_id is
                        Ok player ->
                            # Check if solution is correct
                            is_correct = validate_solution room.challenge code

                            if is_correct then
                                # Mark player as completed and calculate score
                                completion_time = get_current_timestamp - room.start_time
                                score = calculate_score room.challenge.difficulty completion_time

                                updated_player = { player &
                                    challenge_completed: Bool.true,
                                    score: player.score + score,
                                }
                                updated_room = { room &
                                    players: Dict.insert room.players player_id updated_player,
                                }

                                # Check if this player won
                                is_winner =
                                    Dict.values room.players
                                    |> List.all (|p| p.id == player_id or !p.challenge_completed)

                                final_room =
                                    if is_winner then
                                        { updated_room & winner: Ok player_id, is_active: Bool.false }
                                    else
                                        updated_room

                                updated_model = { model &
                                    rooms: Dict.insert model.rooms room_id final_room,
                                    global_leaderboard: Dict.insert model.global_leaderboard player_id (score + (Dict.get model.global_leaderboard player_id |> Result.with_default 0)),
                                }

                                completion_msg = ChallengeCompleted {
                                    player_id: player_id,
                                    completion_time: Num.to_u32 completion_time,
                                }

                                (updated_model, Ok (client_id, completion_msg))
                            else
                                error_msg = ErrorMsg "Solution incorrect. Keep trying!"
                                (model, Ok (client_id, error_msg))

                        # (model, Err NoOp)
                        Err KeyNotFound ->
                            (model, Ok (client_id, ErrorMsg "Player not found"))

                Err KeyNotFound ->
                    (model, Ok (client_id, ErrorMsg "Room not found"))

        ProcessLeaveRoom { player_id, room_id, client_id } ->
            when Dict.get model.rooms room_id is
                Ok room ->
                    updated_room = { room & players: Dict.remove room.players player_id }
                    updated_model = { model &
                        rooms: Dict.insert model.rooms room_id updated_room,
                        active_players: Dict.remove model.active_players player_id,
                    }

                    left_msg = PlayerLeft player_id
                    (updated_model, Ok (client_id, left_msg))

                Err KeyNotFound ->
                    (model, Err NoOp)

        ProcessTypingUpdate { player_id, is_typing, client_id } ->
            typing_msg = TypingIndicator { player_id: player_id, is_typing: is_typing }
            (model, Ok (client_id, typing_msg))

        ProcessHeartBeat { player_id } ->
            # Update last seen time
            when Dict.get model.active_players player_id is
                Ok player_info ->
                    updated_player_info = { player_info & last_seen: get_current_timestamp }
                    updated_model = { model &
                        active_players: Dict.insert model.active_players player_id updated_player_info,
                    }
                    (updated_model, Err NoOp)

                Err KeyNotFound ->
                    (model, Err NoOp)

        CleanupInactivePlayers ->
            # Remove players who haven't been seen in 60 seconds
            current_time = get_current_timestamp
            cutoff_time = current_time - 60000 # 60 seconds in milliseconds

            active_players = Dict.keep_if model.active_players (|(_, info)| info.last_seen > cutoff_time)

            # Remove inactive players from rooms
            updated_rooms = Dict.map
                model.rooms
                (|_, room|
                    active_room_players = Dict.keep_if
                        room.players
                        (|(player_id, _)|
                            Dict.contains active_players player_id
                        )
                    { room & players: active_room_players }
                )

            updated_model = { model &
                rooms: updated_rooms,
                active_players: active_players,
            }

            (updated_model, Err NoOp)

update_from_frontend : Str, Str, ToBackendMsg -> BackendMsg
update_from_frontend = |client_id, _, to_backend_msg|
    when to_backend_msg is
        JoinRoomRequest { player_id, player_name, room_id } ->
            ProcessJoinRoom { player_id, player_name, room_id, client_id }

        CreateRoomRequest { player_id, player_name, challenge_id } ->
            ProcessCreateRoom { player_id, player_name, challenge_id, client_id }

        CodeUpdateMsg { player_id, room_id, code, cursor_pos } ->
            ProcessCodeUpdate { player_id, room_id, code, cursor_pos, client_id }

        ExecuteCodeRequest { player_id, room_id, code } ->
            ProcessExecuteCode { player_id, room_id, code, client_id }

        SubmitSolutionRequest { player_id, room_id, code } ->
            ProcessSubmitSolution { player_id, room_id, code, client_id }

        LeaveRoomRequest { player_id, room_id } ->
            ProcessLeaveRoom { player_id, room_id, client_id }

        TypingUpdate { player_id, room_id, is_typing } ->
            ProcessTypingUpdate { player_id, room_id, is_typing, client_id }

        GetLeaderboard ->
            # Would send leaderboard data back
            ProcessHeartBeat { player_id: "", room_id: "", client_id }

        HeartBeat { player_id, room_id } ->
            ProcessHeartBeat { player_id, room_id, client_id }

# ========== UTILITY FUNCTIONS ==========

get_current_timestamp : U64
get_current_timestamp =
    # In real implementation, this would get actual timestamp
    1234567890000

get_player_color : Str -> Str
get_player_color = |player_id|
    colors = ["#ff6b6b", "#4ecdc4", "#45b7d1", "#96ceb4", "#feca57", "#ff9ff3", "#54a0ff"]
    hash = Str.to_utf8 player_id |> List.sum |> Num.to_u64
    index = hash % (List.len colors)
    List.get colors index |> Result.with_default "#ffffff"

simulate_code_execution : Str -> { output : Str, success : Bool }
simulate_code_execution = |code|
    # Simulate code execution - in reality this would use a secure sandbox
    if Str.contains code "fibonacci" then
        { output: "Function executed successfully. fibonacci(5) = 5", success: Bool.true }
    else if Str.contains code "palindrome" then
        { output: "Function executed successfully. is_palindrome(\"racecar\") = Bool.true", success: Bool.true }
    else if Str.contains code "merge_sort" then
        { output: "Function executed successfully. merge_sort([3,1,4]) = [1,3,4]", success: Bool.true }
    else if Str.contains code "crash" or Str.contains code "error" then
        { output: "Runtime Error: Invalid operation", success: Bool.false }
    else
        { output: "Code executed. Add some test calls to see output.", success: Bool.true }

validate_solution : Challenge, Str -> Bool
validate_solution = |challenge, code|
    # Simplified validation - in reality this would run tests against the code
    when challenge.id is
        "fibonacci" ->
            Str.contains code "fibonacci"
            and
            (Str.contains code "+" or Str.contains code "add")
            and
            (Str.contains code "when" or Str.contains code "if")

        "palindrome" ->
            Str.contains code "palindrome"
            and
            (Str.contains code "reverse" or Str.contains code "==")

        "merge_sort" ->
            Str.contains code "merge"
            and
            Str.contains code "sort"
            and
            (Str.contains code "List.split" or Str.contains code "recursive")

        _ -> Bool.false

calculate_score : [Easy, Medium, Hard], U64 -> U32
calculate_score = |difficulty, completion_time_ms|
    base_score =
        when difficulty is
            Easy -> 100
            Medium -> 200
            Hard -> 400

    # Time bonus - faster completion gets more points
    time_bonus =
        if completion_time_ms < 60000 then
            100 # Under 1 minute
        else if completion_time_ms < 180000 then
            50 # Under 3 minutes
        else if completion_time_ms < 300000 then
            25 # Under 5 minutes
        else
            0

    base_score + time_bonus
