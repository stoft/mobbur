module Comm.NativeToPortConverter exposing (..)

import Comm.Types exposing (Team, Timer, TeamMember, ReplicatedModel)
import App.Types
import Team.Types
import Timer.Types


convertModel : App.Types.Model -> Comm.Types.ReplicatedModel
convertModel model =
    ReplicatedModel (convertTimer model.workTimer)
        (convertTimer model.breakTimer)
        (toString model.activeTimer)
        model.useBreakTimer
        model.autoRestart
        model.autoRotateTeam
        (convertTeam model.team)
        (toString model.currentView)


convertTeam : Team.Types.Model -> Team
convertTeam model =
    Team model.name (List.map convertMember model.members) model.activeMember


convertMember : Team.Types.TeamMember -> TeamMember
convertMember model =
    (TeamMember model.id model.nick)


convertTimer : Timer.Types.Model -> Timer
convertTimer model =
    Timer model.countdown model.interval (toString model.state)
