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

let clientId = document.getElementById('client-id').content;
let teamName = document.getElementById('team-name').content;
// console.log(clientId);
var elmDiv = document.getElementById('elm-app-lives-here');
var app = Elm.Main.embed(elmDiv, {teamName: teamName});

let userAgent = window.navigator.userAgent;
let iOS = !!userAgent.match(/iPad/i) || !!userAgent.match(/iPhone/i);

// var audio = new Audio('/audio/start1.mp3')
let user = window.location.pathname.split('/')[1];

let socket = new Socket("/socket", {
  params: {
    user: user
  }
})
socket.connect()

let presences = {}

let formatTimestamp = (timestamp) => {
  let date = new Date(timestamp)
  return date.toLocaleTimeString()
}

let listBy = (user, {metas: metas}) => {
  // let listBy = (user, params) => {
  // return {
  //   user: user,
  //   onlineAt: formatTimestamp(metas[0].online_at),
  //   teamName: metas[0].team_name
  // }
  // console.log(metas);
  return metas[0].team_name
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
  return Presence.list(presences, listBy)
}

// Channels
let lobby = socket.channel("room:lobby")
lobby.on("presence_state", state => {
  presences = Presence.syncState(presences, state)
  // render(presences)
  sendToElm(presences)
})

lobby.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff)
  // render(presences)
  sendToElm(presences)
})

lobby.join()

let team_room = socket.channel("room:" + user);

team_room.on("team_state", state => {
  // console.log("incoming state:");
  // console.log(state);
  app.ports.teamState.send(state);
})

team_room.join();

app.ports.playAudio.subscribe(function(uri) {
  // console.log('in playAudio');
  try {
    // console.log("in alarm.subscribe");
    var audio = new Audio(uri);

    audio.play();
  } catch (e) {
    document.getElementById('alarm').play();
  }
  // socket.sendStatus("foo");
});

app.ports.notify.subscribe(function(obj) {
  // console.log('Notify port called with: ');
  // console.log(obj);
  desktopNotify(obj);
})

app.ports.teamStatus.subscribe(function(arg) {
  // console.log(arg);
  socket.params.teamName = arg.team.name;
  let teamName = arg.team.name;
  // console.log(socket);
  lobby.push("update", teamName, 1000);
  team_room.push("team_state", arg, 1000);
});

document.addEventListener('DOMContentLoaded', function() {
  if (iOS) return;

  if (!('Notification' in window)) {
    alert('Desktop notifications not available in your browser. Try another browser?');
  } else if (Notification.permission !== "granted")
    Notification.requestPermission();
  }
);

function desktopNotify(obj) {
  if (!('Notification' in window) || iOS) {
    return;
  }

  if (Notification.permission !== "granted") {
    Notification.requestPermission();
  } else {
    var body = 'Iteration or cooldown just ended!';
    if (obj.nick) {
        body = 'Next up: ' + obj.nick;
    }

    let title = obj.nick ? 'Mobbur: ' + obj.nick + obj.titleMessage : 'Mobbur';

    var notification = new Notification(title, {
      icon: 'https://cdn3.iconfinder.com/data/icons/auto-racing/423/Stopwatch_Timer-512.png',
      body: obj.message
    });

    window.setTimeout(function() {
      notification.close();
    }, 5000);
  }
}
