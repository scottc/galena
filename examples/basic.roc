app [
    FrontendModel,
    BackendModel,
    ToFrontendMsg,
    FrontendMsg,
    ToBackendMsg,
    frontendApp,
    backendApp,
] { galena: platform "../platform/main.roc" }

import galena.Backend as Backend exposing [Backend]
import galena.Frontend as Frontend exposing [Frontend]
import galena.Html as Html

FrontendModel : U32
BackendModel : {}

ToFrontendMsg : {}
ToBackendMsg : {}
FrontendMsg : [OnClick, NoOp]

frontendApp : Frontend FrontendModel FrontendMsg ToFrontendMsg ToBackendMsg
frontendApp = Frontend.frontend {
    init!: 0,
    update!: frontend_update!,
    view: |model|
        Html.div
            []
            [
                Html.p [] [Html.text "Count ${Num.to_str model}"],
                Html.button
                    [
                        Html.on_click(|_| OnClick),
                        Html.style "background: blue;",
                    ]
                    [Html.text "Increment"],
            ],
    updateFromBackend: |_| NoOp,
}

frontend_update! : FrontendMsg, FrontendModel => (FrontendModel, Result ToBackendMsg [NoOp])
frontend_update! = |msg, model|
    when msg is
        OnClick -> (model + 1, Err NoOp)
        NoOp -> (model, Err NoOp)

backendApp : Backend BackendModel {} ToFrontendMsg ToBackendMsg
backendApp = Backend.backend {
    init!: {},
    update!: |_, model| (model, Err NoOp),
    update_from_frontend: update_from_frontend,
}

update_from_frontend : Str, Str, toBackendMsg -> {}
update_from_frontend = |_, _, _| {}

