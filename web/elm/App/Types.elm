module App.Types exposing (..)

import Date exposing (Date, now)
import Iterations.Types as Iterations
import Comm.Types as Comm
import Keyboard exposing (KeyCode)
import Team.Types as Team
import Timer.Types as Timer


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
    | GlobalView


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
