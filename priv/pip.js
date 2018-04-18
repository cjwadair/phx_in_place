import socket from "./socket"

let channel = socket.channel("pip:*", {});

function init() {
  addListeners(document);
  console.log(`pip listeners set`);
}

function join_channel(token) {
  channel.join(token)
    .receive("ok", message => {
      addListeners(document);
      console.log(`joining channel: ${message}`);
    })
    .receive("error", resp => {console.warn("Unable to join", resp)});
}

channel.onError(error => console.log("there was an error!", error));

function push_to_channel(name, push_details) {
  return new Promise((resolve, reject) => {
    channel.push(name, push_details)
    .receive("ok", resp => {
      console.log("Channel push successful: ", resp);
      return resolve(resp);
    })
    .receive("error", msg => {
      console.warn("Update Row Error: ", msg)
      return reject(msg);
    });
  });
}

function addListeners(page) {
  console.log("adding listeners");

  page.addEventListener('blur', function(e) {
    if (e.target !== e.currentTarget) {
      if(e.target.classList.contains("pip-input") && e.target.getAttribute('value') != e.target.value){
        // #call to method that updates the record goes here...

        let update_values = {"record_type": e.target.getAttribute("data-struct"), "changes": {[e.target.name]: e.target.value}, "id": e.target.id};

        channel.push('pip_update', update_values)
        .receive("ok", resp => {
          console.log("test update push successful: ", resp);
          // return resolve(resp);
        })
        .receive("error", msg => {
          console.warn("test update Error: ", msg)
          // return reject(msg);
        });

        console.log("emmiting build event");
        e.target.dispatchEvent(buildEvent);
      }
      e.stopPropagation();
    }
  }, true);

  page.addEventListener('focus', function(e){
    if(e.target.classList.contains("pip-input")){

      e.target.style.background = "pink";
    }
  }, true);

  page.addEventListener('blur', function(e){
    if(e.target.classList.contains("pip-input")){
      e.target.style.background = "initial";
    }
  }, true);

  page.addEventListener('keydown',function(e){
    if (e.which == 13 && e.target.classList.contains("pip-input")) {
      e.target.blur();
    }
    if(e.which == 9 && e.target.classList.contains("pip-input")) {
      e.preventDefault();
      e.target.blur();
    }
  }, true);

  var buildEvent = new Event('pip:update', {bubbles: true});

}

export {join_channel, push_to_channel}
