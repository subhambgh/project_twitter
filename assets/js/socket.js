// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket,Presence} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

const renderPresences = (presences) => {
  const listed_presences = Presence.list(presences, (user, {metas: metas}) => {
    return {
      user: user,
      onlineAt: new Date(parseInt(metas[0].online_at) * 1000)
    }
  })
  document.getElementById('presences').innerHTML = listed_presences
    .map(presence => `<li onclick=""><a><strong>User ${presence.user}</strong> <small>online since ${presence.onlineAt}</small></a></li>`)
    .join("")
}

let presences = {}
const handlePresenceDiff = diff => {
  presences = Presence.syncDiff(presences, diff)
  renderPresences(presences)
}
const handlePresenceState = state => {
  presences = Presence.syncState(presences, state)
  renderPresences(presences)
}

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("user:"+window.userId, {})

channel.on("presence_state", handlePresenceState)
channel.on("presence_diff", handlePresenceDiff)
channel.on(`user:${window.userId}:new_message`, (message) => {
  console.log("message", message)
  renderMessage(message)
});
channel.on("change", tweet => {
  console.log("Change:", tweet);
  const div = document.createElement('div');
  div.className = 'card';
  div.innerHTML = `
    <div class='card-content'>
        <div class=row>
        <span class="card-title grey-text text-darken-4">`+tweet.title+`<i class="material-icons right dropdown-trigger  activator" data-target='dropdown`+tweet.title+`'>more_vert</i></span>
        <ul id='dropdown`+tweet.id+`' class='dropdown-content'>
            <li><!--%= link "Edit", to: Routes.post_path(@conn, :retweet, @post)  %--></li>
        </ul>
        `+tweet.body+`
        <br/>
        <div class="chip right">
            <img src='<%= "https://ui-avatars.com/api/?name=`+tweet.user+`&bold=true&background=512DA8&color=FFF&rounded=true" %>' alt="Contact Person">
            `+tweet.user+`
        </div>
        </div>
    </div>`
    document.getElementById('posts').appendChild(div);
  
})


// Handle messages that are sent to topics that don't have a client side representation
socket.onMessage(({topic, event, payload}) => {
  if (event == "presence_diff" && /^user_presence:\d+$/.test(topic)) {
    handlePresenceDiff(payload)
  }
})


channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket


