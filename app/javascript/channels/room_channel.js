import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connected to the room......")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("disconnected.......")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("dataaaaaaaaa", data);
    $('#container').empty();


    var headers = Object.keys(JSON.parse(data.content)[0]);

    for(var i = 0; i < JSON.parse(data.content).length; i++) {
      var tr = document.createElement('tr');

        for(var j = 0; j < headers.length; j++) {
          var td = document.createElement('td');
          td.appendChild(document.createTextNode(JSON.parse(data.content)[i][headers[j]]));
          tr.appendChild(td)
        }
        $('#container').append(tr);
    }
}
})
