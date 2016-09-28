// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import {Socket, Presence} from "phoenix"

var elmDiv = document.getElementById('elm-app-lives-here');
var app = Elm.Main.embed(elmDiv);

// var audio = new Audio('/audio/start1.mp3')
let user = window.location.pathname.split('/')[1];

let socket = new Socket("/socket", {params: {user: user}})
socket.connect()

let presences = {}

let formatTimestamp = (timestamp) => {
  let date = new Date(timestamp)
  return date.toLocaleTimeString()
}

let listBy = (user, {metas: metas}) => {
  return {
    user: user,
    onlineAt: formatTimestamp(metas[0].online_at)
  }
}

// let userList = document.getElementById("UserList")
// let render = (presences) => {
//   userList.innerHTML = Presence.list(presences, listBy)
//     .map(presence => `
//       <li>
//         ${presence.user}
//         <br>
//         <small>online since ${presence.onlineAt}</small>
//       </li>
//     `)
//     .join("")
// }

let sendToElm = (presences) => {
  let count = countTeams(presences)
  app.ports.globalStatus.send(count)
}

let countTeams = (presences) => {
  return Presence.list(presences, listBy).length
}

// Channels
let room = socket.channel("room:lobby")
room.on("presence_state", state => {
  presences = Presence.syncState(presences, state)
  // render(presences)
  sendToElm(presences)
})

room.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff)
  // render(presences)
  sendToElm(presences)
})

room.join()

app.ports.alarm.subscribe(function() {
  document.getElementById('alarm').play();
  // socket.sendStatus("foo");
});
