// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket,Presence} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
  
socket.connect()

const renderPresences = (presences) => {
  console.log(presences)
  const listed_presences = Presence.list(presences, (user, {metas: metas}) => {
    return {
      user: user,
      onlineAt: new Date(parseInt(metas[0].online_at) * 1000),
      username: metas[0].username
    }
  })
  document.getElementById('presences').innerHTML = listed_presences
    .map(presence => `
      <div class = "card" style="padding: 15px 10px 10px 10px;">
        <li onclick="">
          <a>
            <div class = "row">
              
              <div class ="col s4" style="padding-left: 20px; padding-top: 10px;">
                <img src="https://cdn1.iconfinder.com/data/icons/flat-character-color-1/60/flat-design-character_1-512.png" 
                style="max-width:90%; max-height:90%;">
              </div>

              <div class ="col s8">
                <strong>
                  ${presence.username}
                </strong>
                <br> 
                <small>
                  online since ${presence.onlineAt}
                </small>
              </div>

            </div>        
          </a>
        </li>
      </div>`)
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
  
  const div = document.createElement('div');
  div.className = 'card';
  div.innerHTML = `
    <div class='card-content'>
        <div class=row>
        <span class="card-title grey-text text-darken-4">`+tweet.title+`<i class="material-icons right dropdown-trigger  activator" data-target='dropdown`+tweet.id+`'>more_vert</i></span>
        <ul id='dropdown`+tweet.id+`' class="dropdown-content">
        </ul>
        `+tweet.body+`
        <br/>
        <div id='avatars`+tweet.id+`' class="chip right">
            `+tweet.user+`
        </div>
        </div>
    </div>`

    document.getElementById('posts').appendChild(div);

    var ul =document.getElementById("dropdown"+tweet.id);
    var li = document.createElement("li");
    var a = document.createElement("a");
    a.href = "/retweet?post_id="+tweet.id
    a.appendChild(document.createTextNode("Retweet"));
    li.appendChild(a);
    ul.appendChild(li);
    
    var img = document.createElement("img");
    img.src = "https://ui-avatars.com/api/?name="+tweet.user+"&bold=true&background=512DA8&color=FFF&rounded=true" ;
    var src = document.getElementById("avatars"+tweet.id);
    src.appendChild(img);
  
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


//NAV Bar
document.addEventListener('DOMContentLoaded', function() {
  var elems = document.querySelectorAll('.sidenav');
  var instances = M.Sidenav.init(elems, "");
});

// Initialize collapsible (uncomment the lines below if you use the dropdown variation)
// var collapsibleElem = document.querySelector('.collapsible');
// var collapsibleInstance = M.Collapsible.init(collapsibleElem, options);

// Or with jQuery

$(document).ready(function(){
  $('.sidenav').sidenav();
});
      

