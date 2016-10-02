module Types.App exposing (..)

import Date exposing (Date, now)
import Components.Timer as Timer
import Components.Iterations as Iterations
import Components.Comm as Comm
import Keyboard exposing (KeyCode)
import Types.Team as Team


type alias Model =
    { workTimer : Timer.Model
    , breakTimer : Timer.Model
    , activeTimer : ActiveTimer
    , useBreakTimer : Bool
    , autoRestart : Bool
    , autoRotateTeam : Bool
    , team : Team.Model
    , currentView : Page
    , today : Date
    , iterations : Iterations.Model
    , globalTeams : Comm.Model
    }


type Page
    = MainView
    | SettingsView


type ActiveTimer
    = BreakTimer
    | WorkTimer


type Msg
    = Noop
    | BreakTimerMsg Timer.Msg
    | TeamMsg Team.Msg
    | KeyPress KeyCode
    | WorkTimerMsg Timer.Msg
    | SetCurrentDate Date
    | UpdateAutoRestart Bool
    | UpdateAutoRotateTeam Bool
    | UpdateUseBreakTimer Bool
    | UpdateView Page
    | CommMsg Comm.Msg
